import Foundation

struct AppNotification: Codable, Identifiable {
    let id: Int
    let eventId: Int
    let eventTitle: String
    let type: String
    let message: String
    let reason: String?
    let isRead: Bool
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, type, message, reason
        case eventId = "event_id"
        case eventTitle = "event_title"
        case isRead = "is_read"
        case createdAt = "created_at"
    }

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: createdAt) {
            return Self.displayFormatter.string(from: date)
        }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: createdAt) {
            return Self.displayFormatter.string(from: date)
        }
        let stripped = createdAt.replacingOccurrences(of: "\\.\\d+$", with: "", options: .regularExpression)
        if let date = Self.naiveDateFormatter.date(from: stripped) {
            return Self.displayFormatter.string(from: date)
        }
        return createdAt
    }

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd hh:mm a"
        return f
    }()

    private static let naiveDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
