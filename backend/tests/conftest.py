"""Shared fixtures for backend tests."""

import os
import uuid

import pytest
from fastapi.testclient import TestClient
from jose import jwt
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from database import Base, get_db
from main import app
from models import Event, EventParticipant, User

from datetime import datetime, timedelta, timezone

TEST_JWT_SECRET = "test-supabase-jwt-secret-for-unit-tests"
os.environ["SUPABASE_JWT_SECRET"] = TEST_JWT_SECRET


def create_test_token(supabase_uid: str, email: str = "test@example.com") -> str:
    """Mint a Supabase-format JWT for testing."""
    payload = {
        "sub": supabase_uid,
        "email": email,
        "aud": "authenticated",
        "role": "authenticated",
        "exp": datetime.now(timezone.utc) + timedelta(hours=1),
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, TEST_JWT_SECRET, algorithm="HS256")


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


# Pre-generated UUIDs for test users
TEST_UUIDS = {
    "admin": "aaaaaaaa-0000-0000-0000-000000000001",
    "alice": "aaaaaaaa-0000-0000-0000-000000000002",
    "bob": "aaaaaaaa-0000-0000-0000-000000000003",
    "charlie": "aaaaaaaa-0000-0000-0000-000000000004",
    "diana": "aaaaaaaa-0000-0000-0000-000000000005",
}


@pytest.fixture
def seed_users(db_session):
    """Create test users with supabase_uid and email."""
    users = {}
    for name in ["admin", "alice", "bob", "charlie", "diana"]:
        user = User(
            supabase_uid=TEST_UUIDS[name],
            email=f"{name}@test.com",
            nickname=name.capitalize() if name != "admin" else None,
        )
        db_session.add(user)
    db_session.commit()
    for name in ["admin", "alice", "bob", "charlie", "diana"]:
        users[name] = db_session.query(User).filter(User.supabase_uid == TEST_UUIDS[name]).first()
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
    """Return a test JWT for the given user (no backend call needed)."""
    uid = TEST_UUIDS[username]
    return create_test_token(uid, email=f"{username}@test.com")


def auth_header(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}
