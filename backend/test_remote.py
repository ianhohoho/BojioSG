"""Smoke tests against a live API endpoint. Usage: python test_remote.py [base_url]"""

import sys
import httpx

BASE_URL = sys.argv[1] if len(sys.argv) > 1 else "https://bojiosg-api.fly.dev"
passed = 0
failed = 0


def test(name, fn):
    global passed, failed
    try:
        fn()
        print(f"  PASS  {name}")
        passed += 1
    except Exception as e:
        print(f"  FAIL  {name}: {e}")
        failed += 1


client = httpx.Client(base_url=BASE_URL, timeout=15)

print(f"\nRunning smoke tests against {BASE_URL}\n")


def test_health():
    r = client.get("/")
    assert r.status_code == 200
    assert r.json()["message"] == "BojioSG API"

test("GET /", test_health)


def test_list_events():
    r = client.get("/events")
    assert r.status_code == 200
    assert isinstance(r.json(), list)

test("GET /events", test_list_events)


def test_event_detail():
    events = client.get("/events").json()
    if len(events) > 0:
        r = client.get(f"/events/{events[0]['id']}")
        assert r.status_code == 200
        assert r.json()["title"] == events[0]["title"]
    else:
        # No events seeded yet — just check 404 works
        r = client.get("/events/1")
        assert r.status_code in (200, 404)

test("GET /events/{id}", test_event_detail)


def test_event_not_found():
    r = client.get("/events/999999")
    assert r.status_code == 404

test("GET /events/999999 returns 404", test_event_not_found)


def test_me_no_token():
    r = client.get("/auth/me")
    assert r.status_code == 403

test("GET /auth/me without token returns 403", test_me_no_token)


def test_sport_filter():
    r = client.get("/events", params={"sport_type": "pickleball"})
    assert r.status_code == 200
    for e in r.json():
        assert e["sport_type"] == "pickleball"

test("GET /events?sport_type=pickleball", test_sport_filter)

print(f"\n{'='*40}")
print(f"  {passed} passed, {failed} failed")
print(f"{'='*40}\n")

sys.exit(1 if failed else 0)
