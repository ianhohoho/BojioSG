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
│   └── Events/      # Event list, detail, row
├── ViewModels/      # ObservableObject view models
├── Services/        # API client, auth service
└── Resources/       # Assets
```

## iOS Coding Conventions
- Use SwiftUI + MVVM. Keep Views thin — logic goes in ViewModels.
- Use `@Observable` macro (iOS 17+) for view models.
- Use async/await for all networking. No Combine for new code.
- No force unwraps (`!`). Use `guard let`, `if let`, or nil coalescing.
- Use Codable structs for API models. Match backend schema naming with CodingKeys if needed.
- File naming: one primary type per file, filename matches type name.
- Use NavigationStack (not NavigationView).
- Use `snake_case` JSON keys decoded via `.convertFromSnakeCase` on JSONDecoder.
- Prefer `@Environment` for dependency injection of services (AuthService, etc.).
- Use `.task {}` modifier for async data loading on view appear.
- Use `@State` for view-local state, `@Bindable` when passing observable objects to child views.

## iOS UI/Design Guidelines
- **Modern & sleek aesthetic.** Use cards with rounded corners, subtle shadows, and generous spacing.
- Prefer custom-styled buttons (`.fill` rounded rects) over default `.borderedProminent` for primary actions.
- Use SF Symbols consistently for icons. Prefer filled variants for primary UI elements.
- Use semantic colors from asset catalog (AccentColor) and system adaptive colors.
- Apply gradient accents sparingly for visual polish (e.g., branded header, primary buttons).
- Cards should use `RoundedRectangle(cornerRadius: 16)` with `.shadow(color: .black.opacity(0.08), radius: 8, y: 4)`.
- Text hierarchy: `.title` / `.title2` for headings, `.subheadline` for secondary, `.caption` for metadata.
- Use `.contentTransition(.numericText())` for animated number changes where appropriate.
- Sport type badges: colored capsule pills with sport-specific colors (pickleball = green, badminton = orange).
- Keep minimum tap targets at 44pt. Generous padding (16-20pt) on screen edges.
- Use `ScrollView` with `LazyVStack` for card-based lists instead of plain `List` for more design control.

## Backend Coding Conventions
- FastAPI with type hints everywhere.
- Pydantic models for all request/response schemas.
- SQLAlchemy ORM models in `models.py`.
- Dependency injection for database sessions.
- Passwords hashed with bcrypt via passlib. Pin `bcrypt==4.0.1` for passlib compatibility.
- JWT tokens via python-jose.
- CORS enabled for local development.

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

## API Base URL
- Development: `http://localhost:8000`
