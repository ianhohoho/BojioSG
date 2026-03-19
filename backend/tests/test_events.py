"""Tests for event endpoints — listing, detail, creation, joining, approval, removal, and leaving."""

from tests.conftest import auth_header, login


class TestListEvents:
    def test_unauthenticated_returns_events(self, client, seed_events):
        r = client.get("/events")
        assert r.status_code == 200
        events = r.json()
        assert len(events) == 4

    def test_unauthenticated_has_organizer_username(self, client, seed_events):
        events = client.get("/events").json()
        for e in events:
            assert e["organizer_username"] is not None
            assert isinstance(e["organizer_username"], str)

    def test_unauthenticated_has_no_user_fields(self, client, seed_events):
        events = client.get("/events").json()
        for e in events:
            assert e["is_organizer"] is None
            assert e["join_status"] is None
            assert e["participants"] is None

    def test_authenticated_shows_is_organizer(self, client, seed_users, seed_events):
        token = login(client, "alice")
        events = client.get("/events", headers=auth_header(token)).json()
        tennis = next(e for e in events if e["title"] == "Sunday Tennis")
        assert tennis["is_organizer"] is True

        pickleball = next(e for e in events if e["title"] == "Pickleball Doubles")
        assert pickleball["is_organizer"] is False

    def test_authenticated_shows_join_status(self, client, seed_users, seed_events):
        token = login(client, "alice")
        events = client.get("/events", headers=auth_header(token)).json()
        pickleball = next(e for e in events if e["title"] == "Pickleball Doubles")
        assert pickleball["join_status"] == "approved"

        basketball = next(e for e in events if e["title"] == "Basketball Pickup")
        assert basketball["join_status"] == "approved"

    def test_non_participant_join_status_null(self, client, seed_users, seed_events):
        token = login(client, "diana")
        events = client.get("/events", headers=auth_header(token)).json()
        pickleball = next(e for e in events if e["title"] == "Pickleball Doubles")
        assert pickleball["join_status"] is None

    def test_organizer_sees_participants(self, client, seed_users, seed_events):
        token = login(client, "alice")
        events = client.get("/events", headers=auth_header(token)).json()
        tennis = next(e for e in events if e["title"] == "Sunday Tennis")
        assert tennis["participants"] is not None
        usernames = {p["username"] for p in tennis["participants"]}
        assert usernames == {"admin", "bob", "charlie", "diana"}
        # All seeded participants have status approved
        for p in tennis["participants"]:
            assert p["status"] == "approved"

    def test_non_organizer_no_participants(self, client, seed_users, seed_events):
        token = login(client, "charlie")
        events = client.get("/events", headers=auth_header(token)).json()
        tennis = next(e for e in events if e["title"] == "Sunday Tennis")
        assert tennis["participants"] is None


class TestGetEvent:
    def test_get_event_detail(self, client, seed_events):
        event_id = seed_events["Pickleball Doubles"].id
        r = client.get(f"/events/{event_id}")
        assert r.status_code == 200
        assert r.json()["title"] == "Pickleball Doubles"
        assert r.json()["organizer_username"] == "admin"

    def test_get_event_not_found(self, client, seed_events):
        r = client.get("/events/9999")
        assert r.status_code == 404

    def test_get_event_authenticated_organizer(self, client, seed_users, seed_events):
        token = login(client, "admin")
        event_id = seed_events["Pickleball Doubles"].id
        r = client.get(f"/events/{event_id}", headers=auth_header(token))
        data = r.json()
        assert data["is_organizer"] is True
        assert data["participants"] is not None
        assert len(data["participants"]) == 3


class TestCreateEvent:
    def test_create_event(self, client, seed_users):
        token = login(client, "alice")
        event_data = {
            "title": "New Event",
            "description": "A test event",
            "sport_type": "tennis",
            "location": "Test Court",
            "date_time": "2026-04-01T10:00:00",
            "price": 20.0,
            "max_participants": 10,
        }
        r = client.post("/events", json=event_data, headers=auth_header(token))
        assert r.status_code == 201
        data = r.json()
        assert data["title"] == "New Event"
        assert data["organizer_username"] == "alice"
        assert data["is_organizer"] is True

    def test_create_event_unauthenticated(self, client):
        r = client.post("/events", json={"title": "Fail"})
        assert r.status_code == 403


class TestJoinEvent:
    def test_join_creates_pending(self, client, seed_users, seed_events):
        token = login(client, "diana")
        event_id = seed_events["Pickleball Doubles"].id
        r = client.post(f"/events/{event_id}/join", headers=auth_header(token))
        assert r.status_code == 200
        data = r.json()
        assert data["status"] == "pending"
        assert "request" in data["message"].lower() or "pending" in data["message"].lower()

        # Verify join_status is pending
        events = client.get("/events", headers=auth_header(token)).json()
        pickleball = next(e for e in events if e["title"] == "Pickleball Doubles")
        assert pickleball["join_status"] == "pending"
        # Pending should NOT count toward current_participants
        assert pickleball["current_participants"] == 3

    def test_join_already_requested(self, client, seed_users, seed_events):
        token = login(client, "alice")
        event_id = seed_events["Pickleball Doubles"].id
        r = client.post(f"/events/{event_id}/join", headers=auth_header(token))
        assert r.status_code == 400
        assert "already" in r.json()["detail"].lower()

    def test_organizer_cannot_join_own_event(self, client, seed_users, seed_events):
        token = login(client, "admin")
        event_id = seed_events["Pickleball Doubles"].id
        r = client.post(f"/events/{event_id}/join", headers=auth_header(token))
        assert r.status_code == 400
        assert "organizer" in r.json()["detail"].lower()

    def test_join_event_unauthenticated(self, client, seed_events):
        event_id = seed_events["Pickleball Doubles"].id
        r = client.post(f"/events/{event_id}/join")
        assert r.status_code == 403

    def test_join_event_not_found(self, client, seed_users):
        token = login(client, "alice")
        r = client.post("/events/9999/join", headers=auth_header(token))
        assert r.status_code == 404


class TestApproveParticipant:
    def test_organizer_approves(self, client, seed_users, seed_events):
        # Diana joins (pending), then admin approves
        diana_token = login(client, "diana")
        event_id = seed_events["Pickleball Doubles"].id
        client.post(f"/events/{event_id}/join", headers=auth_header(diana_token))

        admin_token = login(client, "admin")
        diana_id = seed_users["diana"].id
        r = client.put(
            f"/events/{event_id}/participants/{diana_id}/approve",
            headers=auth_header(admin_token),
        )
        assert r.status_code == 200
        assert "approved" in r.json()["message"].lower()

        # Verify diana is now approved
        events = client.get("/events", headers=auth_header(diana_token)).json()
        pickleball = next(e for e in events if e["title"] == "Pickleball Doubles")
        assert pickleball["join_status"] == "approved"
        assert pickleball["current_participants"] == 4

    def test_non_organizer_cannot_approve(self, client, seed_users, seed_events):
        # Diana joins, then alice (non-organizer) tries to approve
        diana_token = login(client, "diana")
        event_id = seed_events["Pickleball Doubles"].id
        client.post(f"/events/{event_id}/join", headers=auth_header(diana_token))

        alice_token = login(client, "alice")
        diana_id = seed_users["diana"].id
        r = client.put(
            f"/events/{event_id}/participants/{diana_id}/approve",
            headers=auth_header(alice_token),
        )
        assert r.status_code == 403

    def test_already_approved_fails(self, client, seed_users, seed_events):
        admin_token = login(client, "admin")
        event_id = seed_events["Pickleball Doubles"].id
        alice_id = seed_users["alice"].id
        r = client.put(
            f"/events/{event_id}/participants/{alice_id}/approve",
            headers=auth_header(admin_token),
        )
        assert r.status_code == 400
        assert "already approved" in r.json()["detail"].lower()

    def test_approve_full_event_fails(self, client, seed_users, seed_events):
        """When event is at capacity, approving another pending user should fail."""
        # Create a tiny event with max=1
        token_bob = login(client, "bob")
        event_data = {
            "title": "Tiny Event",
            "description": "Only 1 spot",
            "sport_type": "pickleball",
            "location": "Test",
            "date_time": "2026-04-01T10:00:00",
            "price": 5.0,
            "max_participants": 1,
        }
        r = client.post("/events", json=event_data, headers=auth_header(token_bob))
        tiny_id = r.json()["id"]

        # Both alice and charlie join (pending) while event has 0 approved
        alice_token = login(client, "alice")
        charlie_token = login(client, "charlie")
        client.post(f"/events/{tiny_id}/join", headers=auth_header(alice_token))
        client.post(f"/events/{tiny_id}/join", headers=auth_header(charlie_token))

        # Bob approves alice — now at capacity
        alice_id = seed_users["alice"].id
        r = client.put(
            f"/events/{tiny_id}/participants/{alice_id}/approve",
            headers=auth_header(token_bob),
        )
        assert r.status_code == 200

        # Bob tries to approve charlie, but event is full
        charlie_id = seed_users["charlie"].id
        r = client.put(
            f"/events/{tiny_id}/participants/{charlie_id}/approve",
            headers=auth_header(token_bob),
        )
        assert r.status_code == 400
        assert "full" in r.json()["detail"].lower()


class TestRemoveParticipant:
    def test_organizer_removes_approved(self, client, seed_users, seed_events):
        admin_token = login(client, "admin")
        event_id = seed_events["Pickleball Doubles"].id
        alice_id = seed_users["alice"].id
        r = client.delete(
            f"/events/{event_id}/participants/{alice_id}",
            headers=auth_header(admin_token),
        )
        assert r.status_code == 200
        assert "removed" in r.json()["message"].lower()

        # Verify participant count decreased
        events = client.get("/events", headers=auth_header(admin_token)).json()
        pickleball = next(e for e in events if e["title"] == "Pickleball Doubles")
        assert pickleball["current_participants"] == 2

    def test_organizer_removes_pending(self, client, seed_users, seed_events):
        # Diana joins (pending), admin removes
        diana_token = login(client, "diana")
        event_id = seed_events["Pickleball Doubles"].id
        client.post(f"/events/{event_id}/join", headers=auth_header(diana_token))

        admin_token = login(client, "admin")
        diana_id = seed_users["diana"].id
        r = client.delete(
            f"/events/{event_id}/participants/{diana_id}",
            headers=auth_header(admin_token),
        )
        assert r.status_code == 200

    def test_non_organizer_cannot_remove(self, client, seed_users, seed_events):
        alice_token = login(client, "alice")
        event_id = seed_events["Pickleball Doubles"].id
        bob_id = seed_users["bob"].id
        r = client.delete(
            f"/events/{event_id}/participants/{bob_id}",
            headers=auth_header(alice_token),
        )
        assert r.status_code == 403


class TestLeaveEvent:
    def test_approved_user_leaves(self, client, seed_users, seed_events):
        alice_token = login(client, "alice")
        event_id = seed_events["Pickleball Doubles"].id
        r = client.delete(f"/events/{event_id}/leave", headers=auth_header(alice_token))
        assert r.status_code == 200
        assert "left" in r.json()["message"].lower()

        # Verify join_status is now null
        events = client.get("/events", headers=auth_header(alice_token)).json()
        pickleball = next(e for e in events if e["title"] == "Pickleball Doubles")
        assert pickleball["join_status"] is None
        assert pickleball["current_participants"] == 2

    def test_pending_user_withdraws(self, client, seed_users, seed_events):
        diana_token = login(client, "diana")
        event_id = seed_events["Pickleball Doubles"].id
        client.post(f"/events/{event_id}/join", headers=auth_header(diana_token))

        r = client.delete(f"/events/{event_id}/leave", headers=auth_header(diana_token))
        assert r.status_code == 200

    def test_non_participant_gets_400(self, client, seed_users, seed_events):
        diana_token = login(client, "diana")
        event_id = seed_events["Pickleball Doubles"].id
        r = client.delete(f"/events/{event_id}/leave", headers=auth_header(diana_token))
        assert r.status_code == 400
        assert "not a participant" in r.json()["detail"].lower()
