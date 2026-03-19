# iOS Coding Conventions

## SwiftUI + MVVM
- Keep Views thin — logic goes in ViewModels.
- Use `@Observable` macro (iOS 17+) for view models.
- Use async/await for all networking. No Combine for new code.
- No force unwraps (`!`). Use `guard let`, `if let`, or nil coalescing.
- Use Codable structs for API models. Match backend schema naming with CodingKeys if needed.
- File naming: one primary type per file, filename matches type name.
- Use NavigationStack (not NavigationView).
- Use `snake_case` JSON keys decoded via `.convertFromSnakeCase` on JSONDecoder.
- Prefer `@Environment` for dependency injection of services (AuthService, etc.).
- Use `.task {}` modifier for async data loading on view appear. Clear stale shared ViewModel state (e.g., `joinMessage`, `errorMessage`) at the start of `.task` to avoid gating UI on old values.
- Use `@State` for view-local state, `@Bindable` when passing observable objects to child views.
- Use `#if targetEnvironment(simulator)` (not `#if DEBUG`) to distinguish simulator from physical devices.

## UI/Design Guidelines
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
- Form text fields: use `.styledField()` modifier (defined in `Views/StyledField.swift`) — `.plain` style, 12pt padding, `systemGray6` fill, 12pt corner radius. For `TextEditor`, apply `.scrollContentBackground(.hidden)` + same background/clip manually.
- Use `List` with `.listStyle(.plain)` and `.refreshable` for pull-to-refresh on card-based lists. Hide row chrome with `.listRowSeparator(.hidden)`, `.listRowBackground(Color.clear)`, custom `.listRowInsets`. Plain `ScrollView` + `.refreshable` is unreliable with nested horizontal `ScrollView`s.
