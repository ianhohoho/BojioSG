"""Seed script to populate sample events for BojioSG."""

from datetime import datetime, timedelta, timezone

from database import Base, SessionLocal, engine
from models import Event, User
from auth import hash_password

# Create tables
Base.metadata.create_all(bind=engine)

db = SessionLocal()

# Create a demo organizer if not exists
organizer = db.query(User).filter(User.username == "organizer").first()
if not organizer:
    organizer = User(
        username="organizer",
        password_hash=hash_password("password123"),
    )
    db.add(organizer)
    db.commit()
    db.refresh(organizer)
    print(f"Created organizer user (id={organizer.id})")

# Sample events
now = datetime.now(timezone.utc)
sample_events = [
    {
        "title": "Weekend Pickleball Doubles",
        "description": "Casual doubles pickleball session for all skill levels. Paddles and balls provided. Come make new friends and enjoy the game!",
        "sport_type": "pickleball",
        "location": "Queenstown CC, Courts 1-2",
        "date_time": now + timedelta(days=3, hours=9),
        "price": 8.00,
        "max_participants": 8,
    },
    {
        "title": "Competitive Badminton Singles",
        "description": "Singles badminton session for intermediate to advanced players. Bring your own racket. Shuttlecocks provided.",
        "sport_type": "badminton",
        "location": "Clementi Sports Hall, Court 5",
        "date_time": now + timedelta(days=5, hours=19),
        "price": 12.00,
        "max_participants": 6,
    },
    {
        "title": "Beginner Pickleball Workshop",
        "description": "New to pickleball? Join this beginner-friendly workshop! Learn the basics, rules, and strategies. All equipment provided.",
        "sport_type": "pickleball",
        "location": "Bishan ActiveSG, Courts 3-4",
        "date_time": now + timedelta(days=7, hours=10),
        "price": 15.00,
        "max_participants": 12,
    },
    {
        "title": "Friday Night Badminton",
        "description": "End your week with some badminton! Mixed doubles format. All levels welcome. Light refreshments included.",
        "sport_type": "badminton",
        "location": "Tampines Hub, Badminton Hall",
        "date_time": now + timedelta(days=4, hours=20),
        "price": 10.00,
        "max_participants": 8,
    },
    {
        "title": "Pickleball Tournament - Round Robin",
        "description": "Mini round-robin tournament! Teams will be drawn randomly. Prizes for top 3 teams. Registration includes lunch.",
        "sport_type": "pickleball",
        "location": "Kallang ActiveSG, Courts 1-4",
        "date_time": now + timedelta(days=10, hours=8),
        "price": 25.00,
        "max_participants": 16,
    },
    {
        "title": "Lunchtime Badminton Session",
        "description": "Quick lunchtime badminton session for working professionals. 1.5 hours of play. Shower facilities available.",
        "sport_type": "badminton",
        "location": "Toa Payoh Sports Centre, Court 2",
        "date_time": now + timedelta(days=2, hours=12),
        "price": 6.00,
        "max_participants": 4,
    },
]

created_count = 0
for event_data in sample_events:
    # Check if event with same title already exists
    existing = db.query(Event).filter(Event.title == event_data["title"]).first()
    if not existing:
        event = Event(organizer_id=organizer.id, **event_data)
        db.add(event)
        created_count += 1

db.commit()
db.close()

print(f"Seeded {created_count} events (skipped {len(sample_events) - created_count} existing)")
