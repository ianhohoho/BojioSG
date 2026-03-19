# Backend Coding Conventions

## FastAPI
- Type hints everywhere.
- Pydantic models for all request/response schemas.
- SQLAlchemy ORM models in `models.py`.
- Dependency injection for database sessions via `Depends(get_db)`.
- CORS enabled for local development.

## Auth
- Passwords hashed with bcrypt via passlib. Pin `bcrypt==4.0.1` for passlib compatibility.
- JWT tokens via python-jose.
- JWT `sub` claim must be a **string** (e.g., `str(user.id)`). `python-jose` enforces this on decode.
- Use `HTTPBearer` security scheme with `Depends(get_current_user)` for protected routes.

## Database
- Production: Supabase PostgreSQL (connection via env vars in `backend/.env`).
- Local dev/tests: SQLite (`backend/bojiosg.db` / in-memory).
- `database.py` auto-selects based on whether `DB_*` env vars are set.
- Models define relationships with `relationship()`.
- Use `Column`, `ForeignKey`, standard SQLAlchemy patterns.
- Seed data via `backend/seed.py`.

## Database Migrations (Flyway)
- Flyway manages schema changes on Supabase PostgreSQL.
- Config: `backend/flyway.toml`. Migrations: `backend/sql/migrations/`.
- Wrapper script: `backend/flyway.sh` (loads `.env` before running Flyway).
- V1 is the baseline (initial 4 tables, already applied).
- Workflow: create `V<N>__<description>.sql`, run `./flyway.sh migrate`, update `models.py` to match.
- `cleanDisabled = true` — prevents accidental `flyway clean` on production.
- JDBC URL uses `prepareThreshold=0` for Supabase PgBouncer compatibility.

## Project Structure
```
backend/
├── main.py            # FastAPI app, CORS, router includes
├── database.py        # SQLAlchemy engine + session
├── models.py          # ORM models (User, Event, EventParticipant, Notification)
├── schemas.py         # Pydantic request/response schemas
├── auth.py            # Password hashing, JWT creation/verification
├── seed.py            # Sample data seeder
├── flyway.toml        # Flyway config (Supabase connection)
├── flyway.sh          # Wrapper script (loads .env, runs flyway)
├── sql/migrations/    # Flyway SQL migrations (V1__, V2__, ...)
├── .env               # DB credentials (not committed)
├── routers/
│   ├── auth_router.py          # /auth/register, /auth/login, /auth/me (profile)
│   ├── events_router.py        # CRUD /events, join/approve/remove/leave
│   └── notifications_router.py # /notifications list + mark read
└── tests/             # pytest tests (in-memory SQLite)
```

## User Profile
- `User` model has optional `nickname` and `phone_number` columns.
- `nickname or username` is used as display name in event responses (`organizer_username`, participant `username`).
- `Token` response includes `nickname` so the iOS app can display it immediately after login/register.
- `EventResponse` includes `organizer_phone_number` (from organizer's `phone_number`) for PayNow payment prompts.

## Event Participation
- `EventParticipant` has a `status` column with 4 values: `"pending"` → `"pending_payment"` → `"payment_submitted"` → `"approved"`.
- `current_participants` only counts `"approved"` participants.
- **3-step payment flow:**
  1. User requests to join → `"pending"` → organizer gets `join_request` notification.
  2. Organizer approves → `"pending_payment"` → user gets `payment_required` notification with PayNow details.
  3. User pays externally, clicks notify → `"payment_submitted"` → organizer gets `payment_submitted` notification.
  4. Organizer confirms payment → `"approved"` → user gets `approved` notification. Capacity re-checked here.
- Removal is a hard delete — removed users can re-request. Removal creates a `Notification` for the removed user (with optional reason).
- Organizers cannot join their own event.
- When schema changes add columns to existing tables, delete `bojiosg.db` and re-seed (SQLite `create_all()` won't alter existing tables).

## Tests
- Tests live in `backend/tests/` using pytest with in-memory SQLite.
- Run with: `cd backend && source venv/bin/activate && python -m pytest tests/ -v`
- `conftest.py` provides `db_session`, `client`, `seed_users`, `seed_events` fixtures.
- Helper functions: `login(client, username)` returns token, `auth_header(token)` returns header dict.
- Import helpers as `from tests.conftest import auth_header, login` (not bare `from conftest`).
- `TestClient.delete()` doesn't support `json` kwarg — use `client.request("DELETE", ..., json=...)`.

## Notifications
- `Notification` model: `id, user_id (FK), event_id (FK), type, message, reason, is_read (Boolean), created_at`.
- Created automatically when an organizer removes a participant (type=`"removed"`).
- `reason` is optional — passed via `RemoveParticipantRequest` body on the DELETE endpoint.
- Notification types: `join_request`, `payment_required`, `payment_submitted`, `approved`, `removed`, `rejected`, `withdrawn`.
```
