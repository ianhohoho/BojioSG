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

    private static let sportTypes = [
        ("Pickleball", "figure.pickleball", Color.green),
        ("Badminton", "figure.badminton", Color.orange),
        ("Tennis", "figure.tennis", Color.blue),
        ("Basketball", "figure.basketball", Color.red),
    ]

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
                        // Filter pills (pinned above scrollable content)
                        VStack(spacing: 2) {
                            HStack(spacing: 10) {
                                ForEach(EventFilter.allCases, id: \.self) { option in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            filter = option
                                        }
                                    } label: {
                                        Text(option.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(filter == option ? Color.accentColor : Color.gray.opacity(0.12))
                                            .foregroundStyle(filter == option ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                            // Sport type filter
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedSport = nil
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "sportscourt")
                                                .font(.caption)
                                            Text("All Types")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedSport == nil ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.08))
                                        .foregroundStyle(selectedSport == nil ? Color.accentColor : .secondary)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(selectedSport == nil ? Color.accentColor.opacity(0.3) : .clear, lineWidth: 1)
                                        )
                                    }

                                    ForEach(Self.sportTypes, id: \.0) { name, icon, color in
                                        let isSelected = selectedSport == name
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedSport = isSelected ? nil : name
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: icon)
                                                    .font(.caption)
                                                Text(name)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(isSelected ? color.opacity(0.15) : Color.gray.opacity(0.08))
                                            .foregroundStyle(isSelected ? color : .secondary)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .strokeBorder(isSelected ? color.opacity(0.3) : .clear, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 2)

                            // Time filter + sort
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(TimeFilter.allCases, id: \.self) { option in
                                        let isSelected = timeFilter == option
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                timeFilter = option
                                            }
                                        } label: {
                                            HStack(spacing: 6) {
                                                Image(systemName: option == .all ? "clock" : "calendar")
                                                    .font(.caption)
                                                Text(option.rawValue)
                                                    .font(.caption)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(isSelected ? Color.purple.opacity(0.15) : Color.gray.opacity(0.08))
                                            .foregroundStyle(isSelected ? .purple : .secondary)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .strokeBorder(isSelected ? Color.purple.opacity(0.3) : .clear, lineWidth: 1)
                                            )
                                        }
                                    }

                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            sortAscending.toggle()
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                                .font(.caption)
                                            Text(sortAscending ? "Earliest" : "Latest")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.15))
                                        .foregroundStyle(.purple)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 2)
                        }
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
