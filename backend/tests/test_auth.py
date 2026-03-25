"""Tests for authentication and profile endpoints."""

from tests.conftest import auth_header, create_test_token, login


class TestProfile:
    def test_get_profile(self, client, seed_users):
        token = login(client, "admin")
        r = client.get("/auth/me", headers=auth_header(token))
        assert r.status_code == 200
        data = r.json()
        assert data["email"] == "admin@test.com"
        assert data["id"] == seed_users["admin"].id
        assert "nickname" in data
        assert "phone_number" in data
        assert "created_at" in data

    def test_get_profile_unauthenticated(self, client):
        r = client.get("/auth/me")
        assert r.status_code == 403

    def test_update_nickname(self, client, seed_users):
        token = login(client, "alice")
        r = client.put("/auth/me", headers=auth_header(token), json={"nickname": "Ali"})
        assert r.status_code == 200
        assert r.json()["nickname"] == "Ali"

        # Verify it persisted
        r = client.get("/auth/me", headers=auth_header(token))
        assert r.json()["nickname"] == "Ali"

    def test_update_phone_number(self, client, seed_users):
        token = login(client, "bob")
        r = client.put("/auth/me", headers=auth_header(token), json={"phone_number": "+6591234567"})
        assert r.status_code == 200
        assert r.json()["phone_number"] == "+6591234567"

    def test_update_both_fields(self, client, seed_users):
        token = login(client, "charlie")
        r = client.put(
            "/auth/me",
            headers=auth_header(token),
            json={"nickname": "Chuck", "phone_number": "+6598765432"},
        )
        assert r.status_code == 200
        data = r.json()
        assert data["nickname"] == "Chuck"
        assert data["phone_number"] == "+6598765432"

    def test_nickname_shown_in_events(self, client, seed_events, seed_users):
        """Organizer nickname should appear as organizer_username in event responses."""
        seed_users["admin"].nickname = "The Admin"
        r = client.get("/events")
        assert r.status_code == 200
        admin_events = [e for e in r.json() if e["organizer_id"] == seed_users["admin"].id]
        assert len(admin_events) > 0
        for event in admin_events:
            assert event["organizer_username"] == "The Admin"

    def test_nickname_shown_in_participants(self, client, seed_events, seed_users):
        """Participant nickname should appear in participant list."""
        seed_users["alice"].nickname = "Ali"
        token = login(client, "admin")
        # Pickleball Doubles is organized by admin, alice is a participant
        event = seed_events["Pickleball Doubles"]
        r = client.get(f"/events/{event.id}", headers=auth_header(token))
        assert r.status_code == 200
        data = r.json()
        alice_p = next(p for p in data["participants"] if p["id"] == seed_users["alice"].id)
        assert alice_p["username"] == "Ali"


class TestAutoProvisioning:
    def test_new_user_auto_created(self, client, db_session):
        """A new Supabase user should be auto-provisioned on first API call."""
        new_uid = "bbbbbbbb-0000-0000-0000-000000000001"
        token = create_test_token(new_uid, email="newuser@example.com")
        r = client.get("/auth/me", headers=auth_header(token))
        assert r.status_code == 200
        data = r.json()
        assert data["email"] == "newuser@example.com"
        assert data["nickname"] == "newuser"  # email prefix

    def test_invalid_jwt_rejected(self, client):
        """An invalid JWT should be rejected."""
        r = client.get("/auth/me", headers=auth_header("invalid-token"))
        assert r.status_code == 401
