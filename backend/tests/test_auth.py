"""Tests for authentication endpoints."""

from tests.conftest import auth_header, login


class TestRegister:
    def test_register_success(self, client):
        r = client.post("/auth/register", json={"username": "newuser", "password": "secret123"})
        assert r.status_code == 200
        data = r.json()
        assert data["access_token"]
        assert data["token_type"] == "bearer"
        assert data["user_id"]
        assert data["username"] == "newuser"
        assert data["nickname"] == "newuser"

    def test_register_duplicate_username(self, client, seed_users):
        r = client.post("/auth/register", json={"username": "admin", "password": "anything"})
        assert r.status_code == 400
        assert "already taken" in r.json()["detail"]

    def test_register_short_password(self, client):
        r = client.post("/auth/register", json={"username": "newuser", "password": "short"})
        assert r.status_code == 400


class TestLogin:
    def test_login_success(self, client, seed_users):
        r = client.post("/auth/login", json={"username": "admin", "password": "admin"})
        assert r.status_code == 200
        data = r.json()
        assert data["access_token"]
        assert data["token_type"] == "bearer"
        assert data["user_id"] == seed_users["admin"].id
        assert data["username"] == "admin"

    def test_login_includes_nickname(self, client, seed_users):
        """Login response includes nickname when user has one."""
        # Set a nickname on admin
        seed_users["admin"].nickname = "The Admin"
        token = login(client, "admin")
        r = client.post("/auth/login", json={"username": "admin", "password": "admin"})
        assert r.status_code == 200
        assert r.json()["nickname"] == "The Admin"

    def test_login_all_users(self, client, seed_users):
        """Every seeded user can log in with password = username."""
        for name in ["admin", "alice", "bob", "charlie", "diana"]:
            r = client.post("/auth/login", json={"username": name, "password": name})
            assert r.status_code == 200, f"Login failed for {name}"
            assert r.json()["username"] == name

    def test_login_wrong_password(self, client, seed_users):
        r = client.post("/auth/login", json={"username": "admin", "password": "wrong"})
        assert r.status_code == 401

    def test_login_nonexistent_user(self, client):
        r = client.post("/auth/login", json={"username": "ghost", "password": "ghost"})
        assert r.status_code == 401


class TestProfile:
    def test_get_profile(self, client, seed_users):
        token = login(client, "admin")
        r = client.get("/auth/me", headers=auth_header(token))
        assert r.status_code == 200
        data = r.json()
        assert data["username"] == "admin"
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
        # Set admin's nickname
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
