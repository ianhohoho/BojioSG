import SwiftUI

struct InboxView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: NotificationViewModel
    var onNavigateToEvent: ((Int) -> Void)?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.notifications.isEmpty {
                    ContentUnavailableView(
                        "No Notifications",
                        systemImage: "bell.slash",
                        description: Text("You're all caught up!")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.notifications) { notification in
                                NotificationRow(notification: notification) {
                                    if !notification.isRead {
                                        Task {
                                            await viewModel.markAsRead(
                                                notificationId: notification.id,
                                                token: authService.token
                                            )
                                        }
                                    }
                                    onNavigateToEvent?(notification.eventId)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchNotifications(token: authService.token)
            }
        }
    }
}

private struct NotificationRow: View {
    let notification: AppNotification
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Unread indicator
                Circle()
                    .fill(notification.isRead ? .clear : .red)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 6) {
                    Text(notification.eventTitle)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let reason = notification.reason, !reason.isEmpty {
                        Text("\"\(reason)\"")
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.secondary)
                    }

                    Text(notification.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 6)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(notification.isRead ? Color(.systemBackground) : Color.red.opacity(0.04))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}
