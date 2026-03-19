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
        createdAt.formattedAsEventDate()
    }
}
