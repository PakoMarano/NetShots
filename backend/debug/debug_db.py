"""
Debug script to display database contents.
Usage: python -m debug.debug_db (from backend directory)
"""
import os
import sys

# Add parent directory to path to import backend modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app import create_app
from models import UserProfile, Match
from database import db


def display_profiles():
    """Display all user profiles in the database."""
    profiles = UserProfile.query.all()
    
    print("\n" + "="*80)
    print(f"USER PROFILES ({len(profiles)} records)")
    print("="*80)
    
    if not profiles:
        print("No profiles found.")
        return
    
    for profile in profiles:
        print(f"\nUID: {profile.uid}")
        print(f"  Email: {profile.email}")
        print(f"  Name: {profile.first_name} {profile.last_name}")
        print(f"  Birth Date: {profile.birth_date}")
        print(f"  Gender: {profile.gender.value}")
        print(f"  Profile Picture: {profile.profile_picture or 'None'}")
        print(f"  Victories: {profile.victories}")
        print(f"  Losses: {profile.losses}")
        print(f"  Pictures: {len(profile.pictures)} items")
        print(f"  Created: {profile.created_at}")
        print(f"  Updated: {profile.updated_at}")


def display_matches():
    """Display all matches in the database."""
    matches = Match.query.all()
    
    print("\n" + "="*80)
    print(f"MATCHES ({len(matches)} records)")
    print("="*80)
    
    if not matches:
        print("No matches found.")
        return
    
    for match in matches:
        print(f"\nMatch ID: {match.id}")
        print(f"  User ID: {match.user_id}")
        print(f"  Victory: {match.is_victory}")
        print(f"  Date: {match.date}")
        print(f"  Picture: {match.picture}")
        print(f"  Notes: {match.notes or 'None'}")
        print(f"  Latitude: {match.latitude or 'None'}")
        print(f"  Longitude: {match.longitude or 'None'}")
        print(f"  Temperature: {match.temperature or 'None'}")
        print(f"  Weather: {match.weather_description or 'None'}")
        print(f"  Created: {match.created_at}")


def display_stats():
    """Display database statistics."""
    profile_count = UserProfile.query.count()
    match_count = Match.query.count()
    
    print("\n" + "="*80)
    print("DATABASE STATISTICS")
    print("="*80)
    print(f"Total Profiles: {profile_count}")
    print(f"Total Matches: {match_count}")
    
    if profile_count > 0:
        total_victories = db.session.query(db.func.sum(UserProfile.victories)).scalar() or 0
        total_losses = db.session.query(db.func.sum(UserProfile.losses)).scalar() or 0
        print(f"Total Victories (across all users): {total_victories}")
        print(f"Total Losses (across all users): {total_losses}")


def main():
    """Main function to display all database contents."""
    # Create app context
    app = create_app()
    
    with app.app_context():
        print("\n" + "="*80)
        print("DATABASE DEBUG VIEWER")
        print("="*80)
        print(f"Database: {app.config['SQLALCHEMY_DATABASE_URI']}")
        
        display_stats()
        display_profiles()
        display_matches()
        
        print("\n" + "="*80)
        print("END OF DATABASE CONTENTS")
        print("="*80 + "\n")


if __name__ == "__main__":
    main()
