"""Shared fixtures for backend tests."""

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from database import Base, get_db
from main import app
from models import Event, EventParticipant, User
from auth import hash_password

from datetime import datetime, timedelta, timezone


@pytest.fixture
def db_session():
    """Create an in-memory SQLite database for each test."""
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)


@pytest.fixture
def client(db_session):
    """TestClient wired to the in-memory database."""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as c:
        yield c
    app.dependency_overrides.clear()


@pytest.fixture
def seed_users(db_session):
    """Create test users: admin, alice, bob, charlie, diana (password = username)."""
    users = {}
    for name in ["admin", "alice", "bob", "charlie", "diana"]:
        user = User(username=name, password_hash=hash_password(name))
        db_session.add(user)
    db_session.commit()
    for name in ["admin", "alice", "bob", "charlie", "diana"]:
        users[name] = db_session.query(User).filter(User.username == name).first()
    return users


@pytest.fixture
def seed_events(db_session, seed_users):
    """Create sample events and participants."""
    now = datetime.now(timezone.utc)
    u = seed_users

    events = {}
    event_defs = [
        ("Pickleball Doubles", "pickleball", u["admin"], 8),
        ("Badminton Singles", "badminton", u["admin"], 6),
        ("Sunday Tennis", "tennis", u["alice"], 8),
        ("Basketball Pickup", "basketball", u["bob"], 12),
    ]
    for title, sport, organizer, max_p in event_defs:
        e = Event(
            title=title,
            description=f"Test {title}",
            sport_type=sport,
            location="Test Location",
            date_time=now + timedelta(days=3),
            price=10.0,
            max_participants=max_p,
            organizer_id=organizer.id,
        )
        db_session.add(e)
        db_session.commit()
        db_session.refresh(e)
        events[title] = e

    # Participants
    joins = [
        ("Pickleball Doubles", ["alice", "bob", "charlie"]),
        ("Badminton Singles", ["alice", "diana"]),
        ("Sunday Tennis", ["admin", "bob", "charlie", "diana"]),
        ("Basketball Pickup", ["alice", "charlie"]),
    ]
    for title, usernames in joins:
        for name in usernames:
            p = EventParticipant(event_id=events[title].id, user_id=u[name].id, status="approved")
            db_session.add(p)
    db_session.commit()

    return events


def login(client: TestClient, username: str) -> str:
    """Login and return the access token."""
    r = client.post("/auth/login", json={"username": username, "password": username})
    assert r.status_code == 200
    return r.json()["access_token"]


def auth_header(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}
