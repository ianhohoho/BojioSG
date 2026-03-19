"""Seed script to populate sample events for BojioSG."""

from datetime import datetime, timedelta, timezone

from database import Base, SessionLocal, engine
from models import Event, EventParticipant, User
from auth import hash_password

# Create tables
Base.metadata.create_all(bind=engine)

db = SessionLocal()


def get_or_create_user(username: str, password: str = "password123", nickname: str | None = None) -> User:
    user = db.query(User).filter(User.username == username).first()
    if not user:
        user = User(
            username=username,
            password_hash=hash_password(password),
            nickname=nickname,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        print(f"Created user: {username} (id={user.id}, nickname={nickname})")
    else:
        print(f"User already exists: {username} (id={user.id})")
    return user


# Create users (password = username for all)
admin = get_or_create_user("admin", "admin", nickname="Admin")
alice = get_or_create_user("alice", "alice", nickname="Alice Tan")
bob = get_or_create_user("bob", "bob", nickname="Bobby")
charlie = get_or_create_user("charlie", "charlie", nickname="Charlie Lim")
diana = get_or_create_user("diana", "diana", nickname="Diana")

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
        "organizer": admin,
    },
    {
        "title": "Competitive Badminton Singles",
        "description": "Singles badminton session for intermediate to advanced players. Bring your own racket. Shuttlecocks provided.",
        "sport_type": "badminton",
        "location": "Clementi Sports Hall, Court 5",
        "date_time": now + timedelta(days=5, hours=19),
        "price": 12.00,
        "max_participants": 6,
        "organizer": admin,
    },
    {
        "title": "Beginner Pickleball Workshop",
        "description": "New to pickleball? Join this beginner-friendly workshop! Learn the basics, rules, and strategies. All equipment provided.",
        "sport_type": "pickleball",
        "location": "Bishan ActiveSG, Courts 3-4",
        "date_time": now + timedelta(days=7, hours=10),
        "price": 15.00,
        "max_participants": 12,
        "organizer": admin,
    },
    {
        "title": "Friday Night Badminton",
        "description": "End your week with some badminton! Mixed doubles format. All levels welcome. Light refreshments included.",
        "sport_type": "badminton",
        "location": "Tampines Hub, Badminton Hall",
        "date_time": now + timedelta(days=4, hours=20),
        "price": 10.00,
        "max_participants": 8,
        "organizer": admin,
    },
    {
        "title": "Pickleball Tournament - Round Robin",
        "description": "Mini round-robin tournament! Teams will be drawn randomly. Prizes for top 3 teams. Registration includes lunch.",
        "sport_type": "pickleball",
        "location": "Kallang ActiveSG, Courts 1-4",
        "date_time": now + timedelta(days=10, hours=8),
        "price": 25.00,
        "max_participants": 16,
        "organizer": admin,
    },
    {
        "title": "Lunchtime Badminton Session",
        "description": "Quick lunchtime badminton session for working professionals. 1.5 hours of play. Shower facilities available.",
        "sport_type": "badminton",
        "location": "Toa Payoh Sports Centre, Court 2",
        "date_time": now + timedelta(days=2, hours=12),
        "price": 6.00,
        "max_participants": 4,
        "organizer": admin,
    },
    {
        "title": "Sunday Tennis Social",
        "description": "Relaxed tennis session for all levels. We rotate partners every set. Balls provided. Great way to meet fellow tennis enthusiasts!",
        "sport_type": "tennis",
        "location": "Bukit Timah Tennis Centre, Courts 3-4",
        "date_time": now + timedelta(days=6, hours=8),
        "price": 14.00,
        "max_participants": 8,
        "organizer": alice,
    },
    {
        "title": "3v3 Basketball Pickup",
        "description": "Half-court 3v3 basketball. Intermediate level. Teams formed on the spot. Bring your own water bottle!",
        "sport_type": "basketball",
        "location": "Jurong East ActiveSG, Outdoor Court",
        "date_time": now + timedelta(days=4, hours=17),
        "price": 5.00,
        "max_participants": 12,
        "organizer": bob,
    },
    {
        "title": "Weeknight Tennis Drills",
        "description": "Structured drill session focusing on serves and volleys. Coach-led warmup included. Intermediate to advanced players.",
        "sport_type": "tennis",
        "location": "Kallang Tennis Centre, Court 1",
        "date_time": now + timedelta(days=3, hours=19),
        "price": 18.00,
        "max_participants": 6,
        "organizer": alice,
    },
]

# Create events
event_objects = {}
created_count = 0
for event_data in sample_events:
    title = event_data["title"]
    existing = db.query(Event).filter(Event.title == title).first()
    if not existing:
        org = event_data.pop("organizer")
        event = Event(organizer_id=org.id, **event_data)
        db.add(event)
        db.commit()
        db.refresh(event)
        event_objects[title] = event
        created_count += 1
    else:
        event_data.pop("organizer", None)
        event_objects[title] = existing

print(f"Seeded {created_count} events (skipped {len(sample_events) - created_count} existing)")

# Seed participants
participant_assignments = [
    ("Weekend Pickleball Doubles", [alice, bob, charlie]),
    ("Competitive Badminton Singles", [alice, diana]),
    ("Friday Night Badminton", [bob, charlie, diana]),
    ("Beginner Pickleball Workshop", [bob, diana]),
    ("Sunday Tennis Social", [admin, bob, charlie, diana]),
    ("3v3 Basketball Pickup", [alice, charlie, diana]),
    ("Weeknight Tennis Drills", [bob, charlie]),
]

participant_count = 0
for event_title, users in participant_assignments:
    event = event_objects.get(event_title)
    if not event:
        continue
    for user in users:
        existing = (
            db.query(EventParticipant)
            .filter(
                EventParticipant.event_id == event.id,
                EventParticipant.user_id == user.id,
            )
            .first()
        )
        if not existing:
            p = EventParticipant(event_id=event.id, user_id=user.id, status="approved")
            db.add(p)
            participant_count += 1

db.commit()
db.close()

print(f"Seeded {participant_count} participant records")
