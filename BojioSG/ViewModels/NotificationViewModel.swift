import Foundation

@Observable
final class NotificationViewModel {
    var notifications: [AppNotification] = []
    var errorMessage: String?

    private let apiClient = APIClient.shared

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    func fetchNotifications(token: String?) async {
        guard let token else { return }

        do {
            let fetched: [AppNotification] = try await apiClient.request(
                path: "/notifications",
                token: token
            )
            notifications = fetched
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAsRead(notificationId: Int, token: String?) async {
        guard let token else { return }

        do {
            let updated: AppNotification = try await apiClient.request(
                path: "/notifications/\(notificationId)/read",
                method: "PUT",
                token: token
            )
            if let index = notifications.firstIndex(where: { $0.id == updated.id }) {
                notifications[index] = updated
            }
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
