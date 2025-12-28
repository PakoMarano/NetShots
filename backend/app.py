import os
from typing import Any, Dict, Tuple

import firebase_admin
from flask import Flask, abort, jsonify, request
from firebase_admin import auth, credentials

from database import db, init_db
from models import UserProfile


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
        profile = UserProfile.query.get(uid)
        if not profile:
            abort(404, description="Profile not found")
        return jsonify(profile.to_dict())

    @app.get("/api/profiles/<uid>")
    def get_profile(uid: str):
        _require_user()  # ensure token is valid even for public fetch
        profile = UserProfile.query.get(uid)
        if not profile:
            abort(404, description="Profile not found")
        return jsonify(profile.to_dict())

    @app.post("/api/profiles")
    def create_or_update_profile():
        uid, email = _require_user()
        payload = _get_payload()
        profile = UserProfile.query.get(uid)

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
        profile = UserProfile.query.get(uid)
        if not profile:
            abort(404, description="Profile not found")

        try:
            profile.update_from_payload(payload, email_from_token=email)
            db.session.commit()
        except ValueError as exc:
            db.session.rollback()
            abort(400, description=str(exc))

        return jsonify(profile.to_dict())


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


app = create_app()


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
