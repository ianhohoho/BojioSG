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
    # --- Today (day 0) ---
    {
        "title": "Evening Pickleball Quickplay",
        "description": "Last-minute pickleball session tonight! Casual play, all levels. Paddles available to borrow.",
        "sport_type": "pickleball",
        "location": "Queenstown CC, Courts 1-2",
        "date_time": at(0, 20, 0),
        "price": 6.00,
        "max_participants": 8,  # plenty of room (2/8)
        "organizer": admin,
    },
    {
        "title": "Late Night Basketball Run",
        "description": "Full-court 5v5 pickup game. Intermediate to advanced. Bring your own ball if you have one.",
        "sport_type": "basketball",
        "location": "Jurong East ActiveSG, Indoor Court",
        "date_time": at(0, 21, 30),
        "price": 5.00,
        "max_participants": 6,  # 2 spots left (4/6)
        "organizer": bob,
    },
    # --- Tomorrow (day 1) ---
    {
        "title": "Morning Badminton Warmup",
        "description": "Early bird badminton session. Perfect way to start your day. Shuttlecocks provided.",
        "sport_type": "badminton",
        "location": "Toa Payoh Sports Centre, Court 2",
        "date_time": at(1, 7, 30),
        "price": 5.00,
        "max_participants": 4,  # FULL (4/4)
        "organizer": alice,
    },
    {
        "title": "Afternoon Tennis Hitout",
        "description": "Casual rally session. All levels welcome. Balls provided. Just bring your racket and water!",
        "sport_type": "tennis",
        "location": "Kallang Tennis Centre, Court 3",
        "date_time": at(1, 15, 0),
        "price": 10.00,
        "max_participants": 4,  # 1 spot left (3/4)
        "organizer": charlie,
    },
    {
        "title": "Pickleball Social Night",
        "description": "Friendly round-robin format. Great way to meet other players. Paddles and balls provided.",
        "sport_type": "pickleball",
        "location": "Bishan ActiveSG, Courts 1-2",
        "date_time": at(1, 19, 30),
        "price": 8.00,
        "max_participants": 6,  # 2 spots left (4/6)
        "organizer": admin,
    },
    # --- Day 2 ---
    {
        "title": "Weekend Pickleball Doubles",
        "description": "Casual doubles pickleball session for all skill levels. Paddles and balls provided. Come make new friends!",
        "sport_type": "pickleball",
        "location": "Bishan ActiveSG, Courts 3-4",
        "date_time": at(2, 9, 0),
        "price": 8.00,
        "max_participants": 8,  # plenty of room (3/8)
        "organizer": admin,
    },
    {
        "title": "3v3 Basketball Pickup",
        "description": "Half-court 3v3 basketball. Intermediate level. Teams formed on the spot. Bring your own water bottle!",
        "sport_type": "basketball",
        "location": "Jurong East ActiveSG, Outdoor Court",
        "date_time": at(2, 17, 0),
        "price": 5.00,
        "max_participants": 5,  # 1 spot left (4/5)
        "organizer": bob,
    },
    # --- Day 3 ---
    {
        "title": "Competitive Badminton Singles",
        "description": "Singles badminton for intermediate to advanced players. Bring your own racket. Shuttlecocks provided.",
        "sport_type": "badminton",
        "location": "Clementi Sports Hall, Court 5",
        "date_time": at(3, 19, 30),
        "price": 12.00,
        "max_participants": 4,  # FULL (4/4)
        "organizer": admin,
    },
    {
        "title": "Sunset Tennis Doubles",
        "description": "Mixed doubles under the lights. Rotating partners every set. Balls provided.",
        "sport_type": "tennis",
        "location": "Bukit Timah Tennis Centre, Courts 1-2",
        "date_time": at(3, 17, 30),
        "price": 14.00,
        "max_participants": 6,  # plenty of room (2/6)
        "organizer": alice,
    },
    # --- Day 4 ---
    {
        "title": "Friday Night Badminton",
        "description": "End your week with some badminton! Mixed doubles format. All levels welcome. Light refreshments included.",
        "sport_type": "badminton",
        "location": "Tampines Hub, Badminton Hall",
        "date_time": at(4, 20, 30),
        "price": 10.00,
        "max_participants": 6,  # 2 spots left (4/6)
        "organizer": admin,
    },
    # --- Day 5 ---
    {
        "title": "Beginner Pickleball Workshop",
        "description": "New to pickleball? Learn the basics, rules, and strategies. All equipment provided.",
        "sport_type": "pickleball",
        "location": "Bishan ActiveSG, Courts 3-4",
        "date_time": at(5, 10, 0),
        "price": 15.00,
        "max_participants": 12,  # plenty of room (2/12)
        "organizer": admin,
    },
    {
        "title": "Basketball Skills Clinic",
        "description": "Coached session covering shooting form, ball handling, and defensive footwork. All skill levels.",
        "sport_type": "basketball",
        "location": "Hougang ActiveSG, Indoor Court",
        "date_time": at(5, 14, 30),
        "price": 12.00,
        "max_participants": 4,  # 1 spot left (3/4)
        "organizer": charlie,
    },
    # --- Day 6 ---
    {
        "title": "Weeknight Tennis Drills",
        "description": "Structured drill session focusing on serves and volleys. Coach-led warmup. Intermediate to advanced.",
        "sport_type": "tennis",
        "location": "Kallang Tennis Centre, Court 1",
        "date_time": at(6, 19, 0),
        "price": 18.00,
        "max_participants": 6,  # plenty of room (3/6)
        "organizer": alice,
    },
    # --- Day 7+ ---
    {
        "title": "Sunday Tennis Social",
        "description": "Relaxed tennis for all levels. We rotate partners every set. Balls provided.",
        "sport_type": "tennis",
        "location": "Bukit Timah Tennis Centre, Courts 3-4",
        "date_time": at(8, 8, 30),
        "price": 14.00,
        "max_participants": 8,
        "organizer": alice,
    },
    {
        "title": "Pickleball Tournament - Round Robin",
        "description": "Mini round-robin tournament! Teams drawn randomly. Prizes for top 3. Registration includes lunch.",
        "sport_type": "pickleball",
        "location": "Kallang ActiveSG, Courts 1-4",
        "date_time": at(12, 8, 0),
        "price": 25.00,
        "max_participants": 16,
        "organizer": admin,
    },
    {
        "title": "Badminton Inter-Club Friendly",
        "description": "Friendly match between local clubs. Mixed doubles and singles. Post-match dinner included!",
        "sport_type": "badminton",
        "location": "OCBC Arena, Hall 3",
        "date_time": at(18, 13, 30),
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
# Capacity targets (organizers excluded from their own events):
# Full (0 left):     Morning Badminton (4/4), Competitive Badminton (4/4)
# 1 spot left:       Afternoon Tennis (3/4), 3v3 Basketball (4/5), Basketball Skills (3/4)
# 2 spots left:      Late Night Basketball (4/6), Pickleball Social (4/6), Friday Night Badminton (4/6)
# Plenty of room:    Evening Pickleball (2/8), Weekend Pickleball (3/8), Sunset Tennis (2/6),
#                    Beginner Pickleball (2/12), Weeknight Tennis (3/6), etc.
participant_assignments = [
    ("Evening Pickleball Quickplay", [alice, bob]),                     # 2/8 — plenty
    ("Late Night Basketball Run", [admin, alice, charlie, diana]),      # 4/6 — 2 left
    ("Morning Badminton Warmup", [admin, bob, charlie, diana]),         # 4/4 — FULL
    ("Afternoon Tennis Hitout", [admin, alice, bob]),                   # 3/4 — 1 left
    ("Pickleball Social Night", [alice, bob, charlie, diana]),          # 4/6 — 2 left
    ("Weekend Pickleball Doubles", [alice, bob, charlie]),              # 3/8 — plenty
    ("3v3 Basketball Pickup", [admin, alice, charlie, diana]),          # 4/5 — 1 left
    ("Competitive Badminton Singles", [alice, bob, charlie, diana]),    # 4/4 — FULL
    ("Sunset Tennis Doubles", [admin, bob]),                           # 2/6 — plenty
    ("Friday Night Badminton", [alice, bob, charlie, diana]),           # 4/6 — 2 left
    ("Beginner Pickleball Workshop", [alice, bob]),                     # 2/12 — plenty
    ("Basketball Skills Clinic", [admin, alice, bob]),                  # 3/4 — 1 left
    ("Weeknight Tennis Drills", [admin, bob, charlie]),                 # 3/6 — plenty
    ("Sunday Tennis Social", [admin, bob, charlie, diana]),             # 4/8 — plenty
    ("Pickleball Tournament - Round Robin", [alice]),                   # 1/16 — plenty
    ("Badminton Inter-Club Friendly", [alice, charlie]),                # 2/16 — plenty
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
