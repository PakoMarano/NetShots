import datetime as dt
import enum
import json
from typing import Any, Dict, Iterable, List, Optional

from sqlalchemy import Text
from sqlalchemy.types import TypeDecorator

from database import db


class Gender(enum.Enum):
	male = "male"
	female = "female"
	other = "other"


class StringList(TypeDecorator):
	"""Store Python lists as JSON strings in a TEXT column."""

	impl = Text
	cache_ok = True

	def process_bind_param(self, value: Optional[Iterable[str]], dialect) -> str:
		if value is None:
			return json.dumps([])
		return json.dumps(list(value))

	def process_result_value(self, value: Optional[str], dialect) -> List[str]:
		if not value:
			return []
		try:
			parsed = json.loads(value)
			return list(parsed) if isinstance(parsed, list) else []
		except json.JSONDecodeError:
			return []


class UserProfile(db.Model):
	__tablename__ = "user_profiles"

	# Firebase UID is the primary key to align with Firebase Auth.
	uid = db.Column(db.String(128), primary_key=True)
	email = db.Column(db.String(255), unique=True, nullable=False)
	first_name = db.Column(db.String(120), nullable=False)
	last_name = db.Column(db.String(120), nullable=False)
	birth_date = db.Column(db.Date, nullable=False)
	gender = db.Column(db.Enum(Gender), nullable=False)
	profile_picture = db.Column(db.String(500))
	victories = db.Column(db.Integer, nullable=False, default=0)
	losses = db.Column(db.Integer, nullable=False, default=0)
	pictures = db.Column(StringList, nullable=False, default=list)
	created_at = db.Column(db.DateTime, nullable=False, default=dt.datetime.utcnow)
	updated_at = db.Column(
		db.DateTime, nullable=False, default=dt.datetime.utcnow, onupdate=dt.datetime.utcnow
	)

	def to_dict(self) -> Dict[str, Any]:
		"""Map to the contract expected by the Flutter model."""
		return {
			"userId": self.uid,
			"email": self.email,
			"firstName": self.first_name,
			"lastName": self.last_name,
			"birthDate": self.birth_date.isoformat(),
			"gender": self.gender.value,
			"profilePicture": self.profile_picture,
			"victories": self.victories,
			"losses": self.losses,
			"pictures": list(self.pictures or []),
		}

	@classmethod
	def from_payload(
		cls, *, uid: str, payload: Dict[str, Any], email_from_token: Optional[str] = None
	) -> "UserProfile":
		birth_date = _parse_birth_date(payload.get("birthDate"))
		gender = _parse_gender(payload.get("gender"))
		pictures = _parse_pictures(payload.get("pictures"))

		email_value = (email_from_token or payload.get("email") or "").strip()
		if not email_value:
			raise ValueError("email is required")

		first_name = payload.get("firstName", "").strip()
		last_name = payload.get("lastName", "").strip()
		if not first_name or not last_name:
			raise ValueError("firstName and lastName are required")

		return cls(
			uid=uid,
			email=email_value,
			first_name=first_name,
			last_name=last_name,
			birth_date=birth_date,
			gender=gender,
			profile_picture=_normalize_profile_picture(payload.get("profilePicture")),
			victories=_parse_int(payload.get("victories"), default=0),
			losses=_parse_int(payload.get("losses"), default=0),
			pictures=pictures,
		)

	def update_from_payload(self, payload: Dict[str, Any], *, email_from_token: Optional[str] = None) -> None:
		if "email" in payload or email_from_token:
			self.email = (email_from_token or payload.get("email") or self.email).strip()

		if "firstName" in payload:
			self.first_name = payload.get("firstName", self.first_name).strip()
		if "lastName" in payload:
			self.last_name = payload.get("lastName", self.last_name).strip()
		if "birthDate" in payload and payload.get("birthDate"):
			self.birth_date = _parse_birth_date(payload.get("birthDate")) or self.birth_date
		if "gender" in payload and payload.get("gender"):
			self.gender = _parse_gender(payload.get("gender")) or self.gender
		if "profilePicture" in payload:
			self.profile_picture = _normalize_profile_picture(payload.get("profilePicture"))
		if "victories" in payload:
			self.victories = _parse_int(payload.get("victories"), default=self.victories)
		if "losses" in payload:
			self.losses = _parse_int(payload.get("losses"), default=self.losses)
		if "pictures" in payload:
			self.pictures = _parse_pictures(payload.get("pictures"))


class Match(db.Model):
	__tablename__ = "matches"

	id = db.Column(db.String(128), primary_key=True)
	user_id = db.Column(db.String(128), db.ForeignKey("user_profiles.uid"), nullable=False, index=True)
	is_victory = db.Column(db.Boolean, nullable=False, default=False)
	date = db.Column(db.DateTime, nullable=False)
	picture = db.Column(db.String(500), nullable=False)
	notes = db.Column(db.Text)
	created_at = db.Column(db.DateTime, nullable=False, default=dt.datetime.utcnow)

	user = db.relationship("UserProfile", backref=db.backref("matches", lazy=True))

	def to_dict(self) -> Dict[str, Any]:
		return {
			"id": self.id,
			"userId": self.user_id,
			"isVictory": self.is_victory,
			"date": self.date.isoformat(),
			"picture": self.picture,
			"notes": self.notes,
		}

	@classmethod
	def from_payload(cls, *, payload: Dict[str, Any], user_id: str, match_id: str) -> "Match":
		date = _parse_datetime(payload.get("date"))
		picture = _parse_picture(payload.get("picture"))
		is_victory = _parse_bool(payload.get("isVictory"))

		return cls(
			id=match_id,
			user_id=user_id,
			is_victory=is_victory,
			date=date,
			picture=picture,
			notes=_parse_optional_str(payload.get("notes")),
		)

	def update_from_payload(self, payload: Dict[str, Any]) -> None:
		if "isVictory" in payload:
			self.is_victory = _parse_bool(payload.get("isVictory"), default=self.is_victory)
		if "date" in payload:
			self.date = _parse_datetime(payload.get("date"))
		if "picture" in payload:
			self.picture = _parse_picture(payload.get("picture"))
		if "notes" in payload:
			self.notes = _parse_optional_str(payload.get("notes"))


def _parse_birth_date(value: Any) -> dt.date:
	if isinstance(value, dt.date):
		return value
	if isinstance(value, str):
		try:
			return dt.date.fromisoformat(value.split("T")[0])
		except ValueError:
			pass
	raise ValueError("birthDate must be an ISO date (YYYY-MM-DD)")


def _parse_gender(value: Any) -> Gender:
	if isinstance(value, Gender):
		return value
	if isinstance(value, str):
		normalized = value.lower()
		for g in Gender:
			if g.value == normalized:
				return g
	raise ValueError("gender must be one of: male, female, other")


def _parse_pictures(value: Any) -> List[str]:
	if value is None:
		return []
	if isinstance(value, list):
		return [str(item) for item in value if isinstance(item, (str, bytes)) and str(item).strip()]
	return []


def _normalize_profile_picture(value: Any) -> Optional[str]:
	if value is None:
		return None
	if isinstance(value, str) and value.strip():
		return value.strip()
	return None


def _parse_int(value: Any, *, default: int = 0) -> int:
	try:
		return int(value)
	except (TypeError, ValueError):
		return default


def _parse_bool(value: Any, *, default: bool = False) -> bool:
	if isinstance(value, bool):
		return value
	if isinstance(value, str):
		if value.lower() in {"true", "1", "yes"}:
			return True
		if value.lower() in {"false", "0", "no"}:
			return False
	try:
		return bool(int(value))
	except Exception:
		return default


def _parse_datetime(value: Any) -> dt.datetime:
	if isinstance(value, dt.datetime):
		return value
	if isinstance(value, str):
		try:
			return dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
		except ValueError:
			pass
	raise ValueError("date must be an ISO datetime string")


def _parse_picture(value: Any) -> str:
	if isinstance(value, str) and value.strip():
		return value.strip()
	raise ValueError("picture is required")


def _parse_optional_str(value: Any) -> Optional[str]:
	if value is None:
		return None
	if isinstance(value, str):
		return value.strip() or None
	return str(value)
