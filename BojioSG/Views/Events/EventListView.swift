import SwiftUI

struct EventListView: View {
    @Environment(AuthService.self) private var authService
    @State private var viewModel = EventViewModel()
    @State private var showingCreateSheet = false

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
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.events) { event in
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
                    .refreshable {
                        await viewModel.fetchEvents(token: authService.token)
                    }
                }
            }
            .navigationTitle("Events")
            .navigationDestination(for: Int.self) { eventId in
                if let event = viewModel.events.first(where: { $0.id == eventId }) {
                    EventDetailView(event: event, viewModel: viewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
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
