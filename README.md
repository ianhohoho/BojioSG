<p align="center">
  <img src="assets/logo.png" width="120" alt="BojioSG logo">
</p>

# BojioSG

**"Don't say bojio!"** — A social sports event app for Singapore. Discover, join, and organise paid activities like pickleball, badminton, tennis, and basketball. No one gets left out.

## Features

- Browse and filter events by sport type, time range, and sort order
- Create events with pricing, capacity, date/time, and location
- 3-step payment approval flow: Request to Join → Organiser Approves → PayNow → Confirmed
- Real-time notifications for join requests, approvals, payments, and removals
- User profiles with display name and phone number (for PayNow)
- Pull-to-refresh on all views

## Tech Stack

| Layer | Technology |
|-------|-----------|
| iOS App | SwiftUI (iOS 17+), MVVM, async/await |
| Backend | Python FastAPI, SQLAlchemy, Pydantic |
| Database | Supabase PostgreSQL (prod), SQLite (local dev/tests) |
| Auth | JWT (username/password), bcrypt |
| Hosting | Fly.io (Singapore region) |
| Migrations | Flyway CLI |
| Project Gen | XcodeGen |

## Prerequisites

- **macOS** with Xcode 15+ installed
- **XcodeGen** — `brew install xcodegen`
- **An iPhone** plugged into your Mac via USB/USB-C
- **An Apple Developer account** (free tier works for device testing)

## Getting Started

### 1. Clone the repo

```bash
git clone git@github.com:ianhohoho/BojioSG.git
cd BojioSG
```

### 2. Generate the Xcode project

```bash
xcodegen generate
```

### 3. Open in Xcode

```bash
open BojioSG.xcodeproj
```

### 4. Run on your iPhone

1. **Plug your iPhone into your Mac** via USB/USB-C
2. On your iPhone, go to **Settings → Privacy & Security → Developer Mode** and enable it (restart required)
3. In Xcode:
   - Select your iPhone from the device dropdown (it should appear under "Devices")
   - Go to **Signing & Capabilities** → select your **Team** (Apple ID)
   - Xcode will auto-create a provisioning profile
4. If prompted on your iPhone, go to **Settings → General → VPN & Device Management** and trust the developer certificate
5. Press **Cmd+R** to build and run on your iPhone

The app connects to the hosted backend at `https://bojiosg-api.fly.dev` — no local server setup needed.

### Test accounts

| Username | Password | Nickname |
|----------|----------|----------|
| admin | admin | Admin |
| alice | alice | Alice Tan |
| bob | bob | Bobby |
| charlie | charlie | Charlie Lim |
| diana | diana | Diana |

## Project Structure

```
BojioSG/
├── BojioSG/                    # iOS app source
│   ├── App/                    # App entry point
│   ├── Models/                 # Codable data models
│   ├── Views/
│   │   ├── Auth/               # Login, Register
│   │   ├── Events/             # Event list, detail, row, create
│   │   ├── Inbox/              # Notification inbox
│   │   └── Profile/            # User profile
│   ├── ViewModels/             # @Observable view models
│   ├── Services/               # API client, auth service
│   └── Resources/              # Assets, app icon
├── backend/
│   ├── main.py                 # FastAPI app entry point
│   ├── models.py               # SQLAlchemy ORM models
│   ├── schemas.py              # Pydantic request/response schemas
│   ├── auth.py                 # JWT + password hashing
│   ├── database.py             # DB engine (auto-selects Supabase/SQLite)
│   ├── seed.py                 # Sample data seeder
│   ├── test_remote.py          # Smoke tests for live endpoints
│   ├── routers/
│   │   ├── auth_router.py      # /auth endpoints
│   │   ├── events_router.py    # /events endpoints
│   │   └── notifications_router.py
│   ├── tests/                  # pytest unit tests
│   ├── Dockerfile              # Docker image for Fly.io
│   ├── fly.toml                # Fly.io app config
│   └── sql/migrations/         # Flyway SQL migrations
├── project.yml                 # XcodeGen project spec
└── README.md
```

## API Endpoints

### Auth
| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login (returns JWT) |
| GET | `/auth/me` | Get profile |
| PUT | `/auth/me` | Update nickname/phone |

### Events
| Method | Path | Description |
|--------|------|-------------|
| GET | `/events` | List events (optional `?sport_type=`) |
| GET | `/events/{id}` | Event detail |
| POST | `/events` | Create event |
| POST | `/events/{id}/join` | Request to join |
| PUT | `/events/{id}/participants/{uid}/approve` | Approve request |
| PUT | `/events/{id}/notify-payment` | Notify organiser of payment |
| PUT | `/events/{id}/participants/{uid}/confirm-payment` | Confirm payment received |
| DELETE | `/events/{id}/participants/{uid}` | Remove participant |
| DELETE | `/events/{id}/leave` | Withdraw from event |

### Notifications
| Method | Path | Description |
|--------|------|-------------|
| GET | `/notifications` | List notifications |
| PUT | `/notifications/{id}/read` | Mark as read |

## Payment Flow

```
User requests to join          →  status: "pending"
Organiser approves             →  status: "pending_payment"  (user notified to PayNow)
User pays via PayNow & taps    →  status: "payment_submitted" (organiser notified)
   "Let Organiser Know"
Organiser confirms payment     →  status: "approved"         (user confirmed in)
```

Only `approved` participants count toward event capacity. Capacity is checked at join request and payment confirmation.

## Deployment

The backend is deployed on [Fly.io](https://fly.io) in the Singapore region.

```bash
cd backend
source venv/bin/activate

# Run tests first
python -m pytest tests/ -v

# Deploy (builds Docker image locally)
fly deploy --local-only

# Verify
python test_remote.py https://bojiosg-api.fly.dev
```

Production URL: **https://bojiosg-api.fly.dev**

## License

This project is not currently licensed for public use.
