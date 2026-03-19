import SwiftUI

enum EventFilter: String, CaseIterable {
    case all = "All"
    case organised = "Organised"
    case joined = "Joined"
}

enum TimeFilter: String, CaseIterable {
    case all = "Any Time"
    case nextDay = "24 Hours"
    case nextWeek = "This Week"
    case nextMonth = "This Month"
}

struct EventListView: View {
    @Environment(AuthService.self) private var authService
    @State private var viewModel = EventViewModel()
    @State private var notificationViewModel = NotificationViewModel()
    @State private var showingCreateSheet = false
    @State private var showingProfileSheet = false
    @State private var showingInboxSheet = false
    @State private var navigationPath = NavigationPath()
    @State private var pendingEventNavigation: Int?
    @State private var filter: EventFilter = .all
    @State private var selectedSport: String?
    @State private var timeFilter: TimeFilter = .all
    @State private var sortAscending = true

    private static let sportTypes: [(String, String, Color)] = [
        ("Pickleball", "figure.pickleball", .green),
        ("Badminton", "figure.badminton", .orange),
        ("Tennis", "figure.tennis", .blue),
        ("Basketball", "figure.basketball", .red),
    ]

    private var selectedSportColor: Color {
        guard let sport = selectedSport else { return .secondary }
        return Self.sportTypes.first { $0.0 == sport }?.2 ?? .secondary
    }

    private var selectedSportIcon: String {
        guard let sport = selectedSport else { return "sportscourt" }
        return Self.sportTypes.first { $0.0 == sport }?.1 ?? "sportscourt"
    }

    private var filteredEvents: [Event] {
        var events: [Event]
        switch filter {
        case .all:
            events = viewModel.events
        case .organised:
            events = viewModel.events.filter { $0.isOrganizer == true }
        case .joined:
            events = viewModel.events.filter { $0.isJoinedOrPending && $0.isOrganizer != true }
        }
        if let sport = selectedSport {
            events = events.filter { $0.sportType.lowercased() == sport.lowercased() }
        }
        if timeFilter != .all {
            let now = Date()
            let cutoff: Date = switch timeFilter {
            case .nextDay: Calendar.current.date(byAdding: .day, value: 1, to: now)!
            case .nextWeek: Calendar.current.date(byAdding: .day, value: 7, to: now)!
            case .nextMonth: Calendar.current.date(byAdding: .month, value: 1, to: now)!
            case .all: now
            }
            events = events.filter { event in
                guard let date = event.parsedDate else { return true }
                return date >= now && date <= cutoff
            }
        }
        events.sort { a, b in
            let dateA = a.parsedDate ?? .distantFuture
            let dateB = b.parsedDate ?? .distantFuture
            return sortAscending ? dateA < dateB : dateA > dateB
        }
        return events
    }

    private var emptyStateIcon: String {
        switch filter {
        case .all: return "calendar.badge.exclamationmark"
        case .organised: return "star"
        case .joined: return "person.2"
        }
    }

    private var emptyStateMessage: String {
        switch filter {
        case .all: return "No events available right now."
        case .organised: return "You haven't organised any events yet."
        case .joined: return "You haven't joined any events yet."
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView("Loading events...")
                } else if let error = viewModel.errorMessage, viewModel.events.isEmpty {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.triangle.fill")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await viewModel.fetchEvents(token: authService.token)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                } else if viewModel.events.isEmpty {
                    ContentUnavailableView(
                        "No Events",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("No events available right now.\nCheck back later!")
                    )
                } else {
                    VStack(spacing: 0) {
                        // Filter rows
                        VStack(spacing: 6) {
                            // Row 1: Event filter pills
                            HStack(spacing: 8) {
                                ForEach(EventFilter.allCases, id: \.self) { option in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            filter = option
                                        }
                                    } label: {
                                        Text(option.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(filter == option ? Color.accentColor : Color.gray.opacity(0.12))
                                            .foregroundStyle(filter == option ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)

                            // Row 2: Type menu + Time menu + Reset
                            HStack(spacing: 8) {
                                // Sport type menu
                                Menu {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedSport = nil
                                        }
                                    } label: {
                                        if selectedSport == nil {
                                            Label("All Types", systemImage: "checkmark")
                                        } else {
                                            Text("All Types")
                                        }
                                    }
                                    ForEach(Self.sportTypes, id: \.0) { name, icon, _ in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedSport = name
                                            }
                                        } label: {
                                            if selectedSport == name {
                                                Label(name, systemImage: "checkmark")
                                            } else {
                                                Text(name)
                                            }
                                        }
                                    }
                                } label: {
                                    let isActive = selectedSport != nil
                                    HStack(spacing: 5) {
                                        Image(systemName: selectedSportIcon)
                                            .font(.caption)
                                        Text(selectedSport ?? "Type")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 8, weight: .bold))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(isActive ? selectedSportColor.opacity(0.15) : Color.gray.opacity(0.1))
                                    .foregroundStyle(isActive ? selectedSportColor : .secondary)
                                    .clipShape(Capsule())
                                }

                                // Time filter menu
                                Menu {
                                    ForEach(TimeFilter.allCases, id: \.self) { option in
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                timeFilter = option
                                            }
                                        } label: {
                                            if timeFilter == option {
                                                Label(option.rawValue, systemImage: "checkmark")
                                            } else {
                                                Text(option.rawValue)
                                            }
                                        }
                                    }
                                } label: {
                                    let isActive = timeFilter != .all
                                    HStack(spacing: 5) {
                                        Image(systemName: isActive ? "calendar" : "clock")
                                            .font(.caption)
                                        Text(isActive ? timeFilter.rawValue : "Time")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 8, weight: .bold))
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(isActive ? Color.purple.opacity(0.15) : Color.gray.opacity(0.1))
                                    .foregroundStyle(isActive ? .purple : .secondary)
                                    .clipShape(Capsule())
                                }

                                Spacer()

                                // Reset button (only visible when filters are active)
                                if selectedSport != nil || timeFilter != .all {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedSport = nil
                                            timeFilter = .all
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 10, weight: .bold))
                                            Text("Reset")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .foregroundStyle(.red)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)

                            // Row 3: Sort order
                            HStack {
                                Spacer()
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sortAscending.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                        Text(sortAscending ? "Earliest first" : "Latest first")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 8)

                        List {
                            if filteredEvents.isEmpty {
                                ContentUnavailableView(
                                    "No \(filter.rawValue) Events",
                                    systemImage: emptyStateIcon,
                                    description: Text(emptyStateMessage)
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .padding(.top, 40)
                            } else {
                                ForEach(filteredEvents) { event in
                                    NavigationLink(value: event.id) {
                                        EventRowView(event: event)
                                    }
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                    .listRowBackground(Color.clear)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await viewModel.fetchEvents(token: authService.token)
                            await notificationViewModel.fetchNotifications(token: authService.token)
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .navigationDestination(for: Int.self) { eventId in
                EventDetailView(eventId: eventId, viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showingInboxSheet = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(Color.accentColor)
                                    .frame(width: 22, height: 22)

                                if notificationViewModel.unreadCount > 0 {
                                    Text("\(notificationViewModel.unreadCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 1)
                                        .background(.red)
                                        .clipShape(Capsule())
                                        .offset(x: 6, y: -6)
                                }
                            }
                            .frame(width: 30, height: 30)
                        }

                        Button {
                            showingProfileSheet = true
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        }

                        Button {
                            showingCreateSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        }

                        Button {
                            authService.clearToken()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingInboxSheet, onDismiss: {
                Task {
                    await viewModel.fetchEvents(token: authService.token)
                    await notificationViewModel.fetchNotifications(token: authService.token)
                    if let eventId = pendingEventNavigation {
                        pendingEventNavigation = nil
                        navigationPath.append(eventId)
                    }
                }
            }) {
                InboxView(viewModel: notificationViewModel) { eventId in
                    pendingEventNavigation = eventId
                    showingInboxSheet = false
                }
            }
            .sheet(isPresented: $showingProfileSheet) {
                ProfileView()
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateEventView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchEvents(token: authService.token)
                await notificationViewModel.fetchNotifications(token: authService.token)
            }
        }
    }
}

#Preview {
    EventListView()
        .environment(AuthService())
}
