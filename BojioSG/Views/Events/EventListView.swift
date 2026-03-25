import SwiftUI

enum EventFilter: String, CaseIterable {
    case all = "All"
    case organised = "Organised"
    case joined = "Joined"
}

private func generateDates(count: Int) -> [(key: String, day: String, date: Int, month: String, fullDate: Date)] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    return (0..<count).map { i in
        let d = calendar.date(byAdding: .day, value: i, to: today)!
        let comp = calendar.dateComponents([.weekday, .day, .month], from: d)
        let dayLabel = i == 0 ? "Today" : i == 1 ? "Tmr" : dayNames[comp.weekday! - 1]
        return (
            key: formatter.string(from: d),
            day: dayLabel,
            date: comp.day!,
            month: monthNames[comp.month! - 1],
            fullDate: d
        )
    }
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
    @State private var selectedDateKey: String?
    @State private var sortAscending = true

    private let dates = generateDates(count: 21)

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
        if let dateKey = selectedDateKey {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            events = events.filter { event in
                guard let date = event.parsedDate else { return false }
                return formatter.string(from: date) == dateKey
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
        if selectedDateKey != nil {
            return "No events on this date."
        }
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
                            // Date scroller
                            ScrollViewReader { proxy in
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 6) {
                                        // "All" button
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedDateKey = nil
                                            }
                                        } label: {
                                            VStack(spacing: 2) {
                                                Text("All")
                                                    .font(.system(size: 11))
                                                Text("—")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                            }
                                            .frame(minWidth: 52)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 12)
                                            .background(selectedDateKey == nil ? Color.accentColor : Color(.systemGray6))
                                            .foregroundStyle(selectedDateKey == nil ? .white : .secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        .id("date-all")

                                        ForEach(dates, id: \.key) { d in
                                            Button {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    selectedDateKey = selectedDateKey == d.key ? nil : d.key
                                                }
                                            } label: {
                                                VStack(spacing: 2) {
                                                    Text(d.day)
                                                        .font(.system(size: 11))
                                                    Text("\(d.date)")
                                                        .font(.subheadline)
                                                        .fontWeight(.semibold)
                                                    Text(d.month)
                                                        .font(.system(size: 10))
                                                        .opacity(0.7)
                                                }
                                                .frame(minWidth: 52)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(
                                                    selectedDateKey == d.key
                                                        ? Color.accentColor
                                                        : d.day == "Today"
                                                            ? Color.accentColor.opacity(0.12)
                                                            : Color(.systemGray6)
                                                )
                                                .foregroundStyle(
                                                    selectedDateKey == d.key
                                                        ? .white
                                                        : d.day == "Today"
                                                            ? Color.accentColor
                                                            : .secondary
                                                )
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                            .id("date-\(d.key)")
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .onAppear {
                                    if let key = selectedDateKey {
                                        proxy.scrollTo("date-\(key)", anchor: .center)
                                    }
                                }
                            }

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

                            // Row 2: Sport menu + Reset + Sort
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
                                        Text(selectedSport ?? "Sport")
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

                                // Reset button (only visible when sport filter is active)
                                if selectedSport != nil {
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedSport = nil
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

                                Spacer()

                                // Sort order
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sortAscending.toggle()
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                        Text(sortAscending ? "Earliest" : "Latest")
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
