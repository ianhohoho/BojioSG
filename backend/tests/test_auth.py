"""Tests for authentication endpoints."""

from tests.conftest import login


class TestRegister:
    def test_register_success(self, client):
        r = client.post("/auth/register", json={"username": "newuser", "password": "secret123"})
        assert r.status_code == 200
        data = r.json()
        assert data["access_token"]
        assert data["token_type"] == "bearer"
        assert data["user_id"]
        assert data["username"] == "newuser"

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
