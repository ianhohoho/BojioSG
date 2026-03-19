"""Seed script to populate sample events for BojioSG."""

from datetime import datetime, timedelta, timezone

from database import Base, SessionLocal, engine
from models import Event, EventParticipant, Notification, User
from auth import hash_password

# Create tables
Base.metadata.create_all(bind=engine)

db = SessionLocal()


def get_or_create_user(username: str, password: str = "password123", nickname: str | None = None, phone_number: str | None = None) -> User:
    user = db.query(User).filter(User.username == username).first()
    if not user:
        user = User(
            username=username,
            password_hash=hash_password(password),
            nickname=nickname,
            phone_number=phone_number,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        print(f"Created user: {username} (id={user.id}, nickname={nickname})")
    else:
        print(f"User already exists: {username} (id={user.id})")
    return user


# Create users (password = username for all)
admin = get_or_create_user("admin", "admin", nickname="Admin", phone_number="91234567")
alice = get_or_create_user("alice", "alice", nickname="Alice Tan", phone_number="98765432")
bob = get_or_create_user("bob", "bob", nickname="Bobby", phone_number="81112222")
charlie = get_or_create_user("charlie", "charlie", nickname="Charlie Lim", phone_number="83334444")
diana = get_or_create_user("diana", "diana", nickname="Diana", phone_number="85556666")

# Sample events
now = datetime.now(timezone.utc)


def at(days: int, hour: int, minute: int = 0) -> datetime:
    """Return a future datetime with a clean hour:minute."""
    base = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
    return base + timedelta(days=days)


sample_events = [
    # --- Within 24 hours ---
    {
        "title": "Evening Pickleball Quickplay",
        "description": "Last-minute pickleball session tonight! Casual play, all levels. Paddles available to borrow.",
        "sport_type": "pickleball",
        "location": "Queenstown CC, Courts 1-2",
        "date_time": at(0, 20, 0),
        "price": 6.00,
        "max_participants": 8,
        "organizer": admin,
    },
    {
        "title": "Morning Badminton Warmup",
        "description": "Early bird badminton session. Perfect way to start your day. Shuttlecocks provided.",
        "sport_type": "badminton",
        "location": "Toa Payoh Sports Centre, Court 2",
        "date_time": at(1, 7, 30),
        "price": 5.00,
        "max_participants": 4,
        "organizer": alice,
    },
    # --- Within 1 week (2-6 days) ---
    {
        "title": "Weekend Pickleball Doubles",
        "description": "Casual doubles pickleball session for all skill levels. Paddles and balls provided. Come make new friends and enjoy the game!",
        "sport_type": "pickleball",
        "location": "Bishan ActiveSG, Courts 3-4",
        "date_time": at(2, 9, 0),
        "price": 8.00,
        "max_participants": 8,
        "organizer": admin,
    },
    {
        "title": "Competitive Badminton Singles",
        "description": "Singles badminton session for intermediate to advanced players. Bring your own racket. Shuttlecocks provided.",
        "sport_type": "badminton",
        "location": "Clementi Sports Hall, Court 5",
        "date_time": at(3, 19, 30),
        "price": 12.00,
        "max_participants": 6,
        "organizer": admin,
    },
    {
        "title": "3v3 Basketball Pickup",
        "description": "Half-court 3v3 basketball. Intermediate level. Teams formed on the spot. Bring your own water bottle!",
        "sport_type": "basketball",
        "location": "Jurong East ActiveSG, Outdoor Court",
        "date_time": at(4, 17, 0),
        "price": 5.00,
        "max_participants": 12,
        "organizer": bob,
    },
    {
        "title": "Friday Night Badminton",
        "description": "End your week with some badminton! Mixed doubles format. All levels welcome. Light refreshments included.",
        "sport_type": "badminton",
        "location": "Tampines Hub, Badminton Hall",
        "date_time": at(5, 20, 30),
        "price": 10.00,
        "max_participants": 8,
        "organizer": admin,
    },
    {
        "title": "Weeknight Tennis Drills",
        "description": "Structured drill session focusing on serves and volleys. Coach-led warmup included. Intermediate to advanced players.",
        "sport_type": "tennis",
        "location": "Kallang Tennis Centre, Court 1",
        "date_time": at(6, 19, 0),
        "price": 18.00,
        "max_participants": 6,
        "organizer": alice,
    },
    # --- Within 1 month (8-25 days) ---
    {
        "title": "Sunday Tennis Social",
        "description": "Relaxed tennis session for all levels. We rotate partners every set. Balls provided. Great way to meet fellow tennis enthusiasts!",
        "sport_type": "tennis",
        "location": "Bukit Timah Tennis Centre, Courts 3-4",
        "date_time": at(10, 8, 30),
        "price": 14.00,
        "max_participants": 8,
        "organizer": alice,
    },
    {
        "title": "Beginner Pickleball Workshop",
        "description": "New to pickleball? Join this beginner-friendly workshop! Learn the basics, rules, and strategies. All equipment provided.",
        "sport_type": "pickleball",
        "location": "Bishan ActiveSG, Courts 3-4",
        "date_time": at(14, 10, 0),
        "price": 15.00,
        "max_participants": 12,
        "organizer": admin,
    },
    {
        "title": "Basketball Skills Clinic",
        "description": "Coached session covering shooting form, ball handling, and defensive footwork. All skill levels welcome.",
        "sport_type": "basketball",
        "location": "Hougang ActiveSG, Indoor Court",
        "date_time": at(20, 14, 30),
        "price": 12.00,
        "max_participants": 10,
        "organizer": charlie,
    },
    # --- Beyond 1 month ---
    {
        "title": "Pickleball Tournament - Round Robin",
        "description": "Mini round-robin tournament! Teams will be drawn randomly. Prizes for top 3 teams. Registration includes lunch.",
        "sport_type": "pickleball",
        "location": "Kallang ActiveSG, Courts 1-4",
        "date_time": at(35, 8, 0),
        "price": 25.00,
        "max_participants": 16,
        "organizer": admin,
    },
    {
        "title": "Badminton Inter-Club Friendly",
        "description": "Friendly match between local clubs. Mixed doubles and singles formats. Post-match dinner included!",
        "sport_type": "badminton",
        "location": "OCBC Arena, Hall 3",
        "date_time": at(45, 13, 30),
        "price": 20.00,
        "max_participants": 16,
        "organizer": bob,
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
    ("Evening Pickleball Quickplay", [admin, alice, bob]),
    ("Morning Badminton Warmup", [alice, diana]),
    ("Weekend Pickleball Doubles", [admin, alice, bob, charlie]),
    ("Competitive Badminton Singles", [admin, alice, diana]),
    ("3v3 Basketball Pickup", [bob, alice, charlie, diana]),
    ("Friday Night Badminton", [admin, bob, charlie, diana]),
    ("Weeknight Tennis Drills", [alice, bob, charlie]),
    ("Sunday Tennis Social", [alice, admin, bob, charlie, diana]),
    ("Beginner Pickleball Workshop", [admin, bob, diana]),
    ("Basketball Skills Clinic", [charlie, alice, bob]),
    ("Pickleball Tournament - Round Robin", [admin]),
    ("Badminton Inter-Club Friendly", [bob, alice]),
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
