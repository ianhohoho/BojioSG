# BojioSG

## Project Overview
BojioSG is an iOS app for discovering and joining paid events, starting with sports like pickleball and badminton. "Bojio" is Singlish for "didn't invite me" — this app makes sure no one gets left out.

## Architecture
- **Frontend:** SwiftUI iOS app (iOS 17+), MVVM pattern
- **Backend:** Python FastAPI + Supabase PostgreSQL (SQLite for local dev/tests)
- **Auth:** JWT-based (username/password)
- **Migrations:** Flyway (baseline V1, SQL-based versioned migrations)

## Tech Stack
- **iOS:** SwiftUI, Swift 5.9+, async/await, Codable
- **Backend:** FastAPI, SQLAlchemy, Pydantic, passlib (bcrypt), python-jose (JWT)
- **Database:** Supabase PostgreSQL (production), SQLite (local dev/tests)
- **Migrations:** Flyway CLI (`backend/flyway.toml`, `backend/sql/migrations/`)
- **Project Generation:** XcodeGen (`project.yml`)

## iOS Project Structure
```
BojioSG/
├── App/             # App entry point
├── Models/          # Codable data models
├── Views/           # SwiftUI views
│   ├── Auth/        # Login, Register
│   ├── Events/      # Event list, detail, row, create
│   ├── Inbox/       # Notification inbox
│   └── Profile/     # User profile
├── ViewModels/      # ObservableObject view models
├── Services/        # API client, auth service
└── Resources/       # Assets
```

## How to Run

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python main.py
# Server runs at http://localhost:8000
# API docs at http://localhost:8000/docs
```

### Seed Data
```bash
cd backend
python seed.py
```

### Database Migrations (Flyway)
```bash
cd backend
# Run pending migrations against Supabase
./flyway.sh migrate
# Check migration status
./flyway.sh info
# New migration: create backend/sql/migrations/V<N>__<description>.sql, then run migrate
```

### iOS App
```bash
# Generate Xcode project (requires xcodegen)
xcodegen generate
# Open BojioSG.xcodeproj in Xcode and run on simulator
```

## API Endpoints
- `POST /auth/register` — register new user (returns JWT + nickname)
- `POST /auth/login` — login, returns JWT + nickname
- `GET /auth/me` — get user profile (auth required)
- `PUT /auth/me` — update nickname/phone_number (auth required)
- `GET /events` — list all events (optional auth for personalized fields)
- `GET /events/{id}` — event detail
- `POST /events` — create event (auth required)
- `POST /events/{id}/join` — request to join (creates pending, auth required)
- `PUT /events/{id}/participants/{user_id}/approve` — organizer approves → pending_payment (auth required)
- `PUT /events/{id}/notify-payment` — user notifies organizer of payment → payment_submitted (auth required)
- `PUT /events/{id}/participants/{user_id}/confirm-payment` — organizer confirms payment → approved (auth required)
- `DELETE /events/{id}/participants/{user_id}` — organizer removes participant (auth required)
- `DELETE /events/{id}/leave` — user withdraws from event (auth required)
- `GET /notifications` — list user's notifications (auth required)
- `PUT /notifications/{id}/read` — mark notification as read (auth required)

## API Base URL
- Development: `http://localhost:8000`
- Production: `https://bojiosg-api.fly.dev`
- iOS uses `#if DEBUG` to select: localhost for debug builds, production for release

## Deployment (Fly.io)
```bash
# Run unit tests, deploy, and smoke test (via /deploy skill)
cd backend && source venv/bin/activate && python -m pytest tests/ -v
cd backend && fly deploy --local-only
python test_remote.py http://localhost:8000
python test_remote.py https://bojiosg-api.fly.dev
```
- App: `bojiosg-api`, region: `sin` (Singapore)
- Config: `backend/fly.toml`, `backend/Dockerfile`, `backend/.dockerignore`
- Secrets set via `fly secrets set` (DB_USER, DB_PASSWORD, etc.)
- Smoke tests: `backend/test_remote.py` — 10 tests against any live endpoint
