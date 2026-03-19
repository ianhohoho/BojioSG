import SwiftUI

enum EventFilter: String, CaseIterable {
    case all = "All"
    case organised = "Organised"
    case joined = "Joined"
}

struct EventListView: View {
    @Environment(AuthService.self) private var authService
    @State private var viewModel = EventViewModel()
    @State private var showingCreateSheet = false
    @State private var showingProfileSheet = false
    @State private var filter: EventFilter = .all

    private var filteredEvents: [Event] {
        switch filter {
        case .all:
            return viewModel.events
        case .organised:
            return viewModel.events.filter { $0.isOrganizer == true }
        case .joined:
            return viewModel.events.filter { $0.isJoinedOrPending }
        }
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
        NavigationStack {
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
                    ScrollView {
                        // Filter pills
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

                        if filteredEvents.isEmpty {
                            ContentUnavailableView(
                                "No \(filter.rawValue) Events",
                                systemImage: emptyStateIcon,
                                description: Text(emptyStateMessage)
                            )
                            .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredEvents) { event in
                                    NavigationLink(value: event.id) {
                                        EventRowView(event: event)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                    .refreshable {
                        await viewModel.fetchEvents(token: authService.token)
                    }
                }
            }
            .navigationTitle("Events")
            .navigationDestination(for: Int.self) { eventId in
                EventDetailView(eventId: eventId, viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
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
            .sheet(isPresented: $showingProfileSheet) {
                ProfileView()
            }
            .sheet(isPresented: $showingCreateSheet) {
                CreateEventView(viewModel: viewModel)
            }
            .task {
                await viewModel.fetchEvents(token: authService.token)
            }
        }
    }
}

#Preview {
    EventListView()
        .environment(AuthService())
}
