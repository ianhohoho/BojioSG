"""Tests for notification endpoints."""

from models import EventParticipant
from tests.conftest import auth_header, login


def test_remove_with_reason_creates_notification(client, seed_events, seed_users):
    """Removing a participant with a reason creates a notification."""
    token = login(client, "admin")
    event = seed_events["Pickleball Doubles"]
    alice = seed_users["alice"]

    r = client.request(
        "DELETE",
        f"/events/{event.id}/participants/{alice.id}",
        headers=auth_header(token),
        json={"reason": "Skill level mismatch"},
    )
    assert r.status_code == 200

    alice_token = login(client, "alice")
    r = client.get("/notifications", headers=auth_header(alice_token))
    assert r.status_code == 200
    notifications = r.json()
    assert len(notifications) == 1
    n = notifications[0]
    assert n["event_title"] == "Pickleball Doubles"
    assert n["reason"] == "Skill level mismatch"
    assert n["type"] == "removed"
    assert n["is_read"] is False


def test_remove_without_reason_creates_notification(client, seed_events, seed_users):
    """Removing a participant without a reason still creates a notification."""
    token = login(client, "admin")
    event = seed_events["Pickleball Doubles"]
    bob = seed_users["bob"]

    r = client.delete(
        f"/events/{event.id}/participants/{bob.id}",
        headers=auth_header(token),
    )
    assert r.status_code == 200

    bob_token = login(client, "bob")
    r = client.get("/notifications", headers=auth_header(bob_token))
    assert r.status_code == 200
    notifications = r.json()
    assert len(notifications) == 1
    assert notifications[0]["reason"] is None
    assert notifications[0]["event_title"] == "Pickleball Doubles"


def test_empty_notifications_list(client, seed_users):
    """User with no notifications gets empty list."""
    token = login(client, "admin")
    r = client.get("/notifications", headers=auth_header(token))
    assert r.status_code == 200
    assert r.json() == []


def test_approve_creates_notification(client, seed_events, seed_users, db_session):
    """Approving a participant creates a notification."""
    event = seed_events["Pickleball Doubles"]
    diana = seed_users["diana"]

    # Add diana as pending
    p = EventParticipant(event_id=event.id, user_id=diana.id, status="pending")
    db_session.add(p)
    db_session.commit()

    admin_token = login(client, "admin")
    r = client.put(
        f"/events/{event.id}/participants/{diana.id}/approve",
        headers=auth_header(admin_token),
    )
    assert r.status_code == 200

    diana_token = login(client, "diana")
    r = client.get("/notifications", headers=auth_header(diana_token))
    assert r.status_code == 200
    notifications = r.json()
    assert len(notifications) == 1
    n = notifications[0]
    assert n["type"] == "approved"
    assert n["event_title"] == "Pickleball Doubles"
    assert n["is_read"] is False


def test_notifications_unauthenticated(client):
    """Unauthenticated request returns 403."""
    r = client.get("/notifications")
    assert r.status_code == 403


def test_mark_as_read(client, seed_events, seed_users):
    """Mark a notification as read."""
    token = login(client, "admin")
    event = seed_events["Pickleball Doubles"]
    alice = seed_users["alice"]

    client.request(
        "DELETE",
        f"/events/{event.id}/participants/{alice.id}",
        headers=auth_header(token),
        json={"reason": "Full"},
    )

    alice_token = login(client, "alice")
    r = client.get("/notifications", headers=auth_header(alice_token))
    notification_id = r.json()[0]["id"]

    r = client.put(
        f"/notifications/{notification_id}/read",
        headers=auth_header(alice_token),
    )
    assert r.status_code == 200
    assert r.json()["is_read"] is True

    # Verify persisted
    r = client.get("/notifications", headers=auth_header(alice_token))
    assert r.json()[0]["is_read"] is True


def test_cannot_mark_other_users_notification(client, seed_events, seed_users):
    """Cannot mark another user's notification as read."""
    admin_token = login(client, "admin")
    event = seed_events["Pickleball Doubles"]
    alice = seed_users["alice"]

    client.delete(
        f"/events/{event.id}/participants/{alice.id}",
        headers=auth_header(admin_token),
    )

    alice_token = login(client, "alice")
    r = client.get("/notifications", headers=auth_header(alice_token))
    notification_id = r.json()[0]["id"]

    # Bob tries to mark Alice's notification
    bob_token = login(client, "bob")
    r = client.put(
        f"/notifications/{notification_id}/read",
        headers=auth_header(bob_token),
    )
    assert r.status_code == 403


def test_nonexistent_notification(client, seed_users):
    """Marking a nonexistent notification returns 404."""
    token = login(client, "admin")
    r = client.put(
        "/notifications/99999/read",
        headers=auth_header(token),
    )
    assert r.status_code == 404
