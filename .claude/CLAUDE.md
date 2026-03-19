# BojioSG

## Project Overview
BojioSG is an iOS app for discovering and joining paid events, starting with sports like pickleball and badminton. "Bojio" is Singlish for "didn't invite me" — this app makes sure no one gets left out.

## Architecture
- **Frontend:** SwiftUI iOS app (iOS 17+), MVVM pattern
- **Backend:** Python FastAPI + SQLite
- **Auth:** JWT-based (username/password)

## Tech Stack
- **iOS:** SwiftUI, Swift 5.9+, async/await, Codable
- **Backend:** FastAPI, SQLAlchemy, Pydantic, passlib (bcrypt), python-jose (JWT)
- **Database:** SQLite (via SQLAlchemy)
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
- `PUT /events/{id}/participants/{user_id}/approve` — organizer approves (auth required)
- `DELETE /events/{id}/participants/{user_id}` — organizer removes participant (auth required)
- `DELETE /events/{id}/leave` — user withdraws from event (auth required)
- `GET /notifications` — list user's notifications (auth required)
- `PUT /notifications/{id}/read` — mark notification as read (auth required)

## API Base URL
- Development: `http://localhost:8000`
