import os
from typing import Any, Dict, Tuple

import firebase_admin
from flask import Flask, abort, jsonify, request
from firebase_admin import auth, credentials

from database import db, init_db
from models import Follow, Match, UserProfile


def create_app() -> Flask:
    app = Flask(__name__)

    basedir = os.path.abspath(os.path.dirname(__file__))
    default_db_uri = "sqlite:///" + os.path.join(basedir, "netshots.db")
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv("DATABASE_URL", default_db_uri)
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    _configure_firebase()
    init_db(app)

    register_routes(app)
    register_error_handlers(app)
    return app


def _configure_firebase() -> None:
    if firebase_admin._apps:
        return

    cred_path = os.getenv("FIREBASE_CREDENTIALS")
    if not cred_path or not os.path.exists(cred_path):
        raise RuntimeError("FIREBASE_CREDENTIALS env var must point to a service account JSON file")

    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)


def register_error_handlers(app: Flask) -> None:
    @app.errorhandler(400)
    @app.errorhandler(401)
    @app.errorhandler(404)
    @app.errorhandler(409)
    def handle_http_error(err):  # type: ignore[override]
        return jsonify({"error": err.description if hasattr(err, "description") else str(err)}), err.code

    @app.errorhandler(Exception)
    def handle_unexpected(err):  # type: ignore[override]
        return jsonify({"error": "Unexpected server error"}), 500


def register_routes(app: Flask) -> None:
    @app.get("/")
    def home():
        return {"status": "NetShots API is running"}

    @app.get("/api/health")
    def health():
        return {"status": "ok"}

    @app.get("/api/profiles/me")
    def get_my_profile():
        uid, _ = _require_user()
        profile = db.session.get(UserProfile, uid)
        if not profile:
            abort(404, description="Profile not found")
        return jsonify(profile.to_dict())

    @app.get("/api/profiles/<uid>")
    def get_profile(uid: str):
        _require_user()  # ensure token is valid even for public fetch
        profile = db.session.get(UserProfile, uid)
        if not profile:
            abort(404, description="Profile not found")
        return jsonify(profile.to_dict())

    @app.post("/api/profiles")
    def create_or_update_profile():
        uid, email = _require_user()
        payload = _get_payload()
        profile = db.session.get(UserProfile, uid)

        try:
            if profile:
                profile.update_from_payload(payload, email_from_token=email)
            else:
                profile = UserProfile.from_payload(uid=uid, payload=payload, email_from_token=email)
                db.session.add(profile)
            db.session.commit()
        except ValueError as exc:
            db.session.rollback()
            abort(400, description=str(exc))

        return jsonify(profile.to_dict())

    @app.put("/api/profiles/me")
    def update_my_profile():
        uid, email = _require_user()
        payload = _get_payload()
        profile = db.session.get(UserProfile, uid)
        if not profile:
            abort(404, description="Profile not found")

        try:
            profile.update_from_payload(payload, email_from_token=email)
            db.session.commit()
        except ValueError as exc:
            db.session.rollback()
            abort(400, description=str(exc))

        return jsonify(profile.to_dict())

    @app.delete("/api/profiles/me")
    def delete_my_profile():
        uid, _ = _require_user()
        profile = db.session.get(UserProfile, uid)
        if not profile:
            abort(404, description="Profile not found")

        # Delete all associated matches first
        Match.query.filter_by(user_id=uid).delete()
        
        # Delete the profile
        db.session.delete(profile)
        db.session.commit()
        return jsonify({"deleted": uid}), 200

    # --- Search ---
    @app.get("/api/search/users")
    def search_users():
        uid, _ = _require_user()
        query = request.args.get("q", "").strip()
        
        if not query:
            return jsonify([])
        
        # Case-insensitive partial match on first name or last name
        search_pattern = f"%{query}%"
        profiles = UserProfile.query.filter(
            db.or_(
                UserProfile.first_name.ilike(search_pattern),
                UserProfile.last_name.ilike(search_pattern)
            ),
            UserProfile.uid != uid  # Exclude current user
        ).all()
        
        # Return simplified user info for search results
        results = []
        for profile in profiles:
            results.append({
                "userId": profile.uid,
                "displayName": f"{profile.first_name} {profile.last_name}",
                "profilePicture": profile.profile_picture
            })
        
        return jsonify(results)

    # --- Follow ---
    @app.post("/api/follow/<target_user_id>")
    def follow_user(target_user_id: str):
        uid, _ = _require_user()
        
        if uid == target_user_id:
            abort(400, description="Cannot follow yourself")
        
        # Check if target user exists
        target_profile = db.session.get(UserProfile, target_user_id)
        if not target_profile:
            abort(404, description="Target user not found")
        
        # Check if already following
        existing = db.session.get(Follow, (uid, target_user_id))
        if existing:
            return jsonify({"status": "already following"}), 200
        
        # Create follow relationship
        follow = Follow(follower_id=uid, following_id=target_user_id)
        db.session.add(follow)
        db.session.commit()
        
        return jsonify({"status": "success"}), 201

    @app.delete("/api/follow/<target_user_id>")
    def unfollow_user(target_user_id: str):
        uid, _ = _require_user()
        
        follow = db.session.get(Follow, (uid, target_user_id))
        if not follow:
            abort(404, description="Not following this user")
        
        db.session.delete(follow)
        db.session.commit()
        
        return jsonify({"status": "success"}), 200

    @app.get("/api/follow/<target_user_id>/is-following")
    def is_following(target_user_id: str):
        uid, _ = _require_user()
        
        follow = db.session.get(Follow, (uid, target_user_id))
        return jsonify({"isFollowing": follow is not None})

    @app.get("/api/follow/<user_id>/followers")
    def get_followers(user_id: str):
        _require_user()
        
        # Get all users who follow this user
        followers = Follow.query.filter_by(following_id=user_id).all()
        follower_ids = [f.follower_id for f in followers]
        
        return jsonify(follower_ids)

    @app.get("/api/follow/<user_id>/following")
    def get_following(user_id: str):
        _require_user()
        
        # Get all users this user follows
        following = Follow.query.filter_by(follower_id=user_id).all()
        following_ids = [f.following_id for f in following]
        
        return jsonify(following_ids)

    # --- Matches ---
    @app.get("/api/matches")
    def get_my_matches():
        uid, _ = _require_user()
        matches = Match.query.filter_by(user_id=uid).all()
        return jsonify([m.to_dict() for m in matches])

    @app.get("/api/matches/user/<uid>")
    def get_matches_for_user(uid: str):
        requester_uid, _ = _require_user()
        if uid != requester_uid:
            abort(403, description="Cannot access other users' matches")
        matches = Match.query.filter_by(user_id=uid).all()
        return jsonify([m.to_dict() for m in matches])

    @app.post("/api/matches")
    def create_match():
        uid, _ = _require_user()
        payload = _get_payload()
        match_id = str(payload.get("id") or _generate_id())

        try:
            match = Match.from_payload(payload=payload, user_id=uid, match_id=match_id)
            db.session.add(match)
            db.session.commit()
        except ValueError as exc:
            db.session.rollback()
            abort(400, description=str(exc))

        return jsonify(match.to_dict())

    @app.delete("/api/matches/<match_id>")
    def delete_match(match_id: str):
        uid, _ = _require_user()
        match = db.session.get(Match, match_id)
        if not match:
            abort(404, description="Match not found")
        if match.user_id != uid:
            abort(403, description="Cannot delete a match you do not own")

        db.session.delete(match)
        db.session.commit()
        return jsonify({"deleted": match_id})


def _require_user() -> Tuple[str, str]:
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        abort(401, description="Missing bearer token")

    token = auth_header.split(" ", 1)[1].strip()
    try:
        decoded = auth.verify_id_token(token)
    except Exception:
        abort(401, description="Invalid Firebase token")

    uid = decoded.get("uid")
    email = decoded.get("email", "")
    if not uid:
        abort(401, description="Token missing uid")
    return uid, email


def _get_payload() -> Dict[str, Any]:
    payload = request.get_json(silent=True) or {}
    if not isinstance(payload, dict):
        abort(400, description="Payload must be a JSON object")
    return payload


def _generate_id() -> str:
    return os.urandom(12).hex()


app = create_app()


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
