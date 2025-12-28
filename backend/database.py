from flask_sqlalchemy import SQLAlchemy

# Shared SQLAlchemy instance for the Flask app.
db = SQLAlchemy()


def init_db(app) -> None:
	"""Attach the db to the app and create tables."""
	db.init_app(app)
	with app.app_context():
		db.create_all()
