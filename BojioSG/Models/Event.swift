import Foundation
import SwiftUI

struct Participant: Codable, Identifiable {
    let id: Int
    let username: String
    let status: String
    let joinedAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, status
        case joinedAt = "joined_at"
    }
}

struct Event: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let sportType: String
    let location: String
    let dateTime: String
    let price: Double
    let maxParticipants: Int
    let currentParticipants: Int
    let organizerId: Int
    let organizerUsername: String
    let isOrganizer: Bool?
    let joinStatus: String?
    let participants: [Participant]?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, participants
        case sportType = "sport_type"
        case location
        case dateTime = "date_time"
        case price
        case maxParticipants = "max_participants"
        case currentParticipants = "current_participants"
        case organizerId = "organizer_id"
        case organizerUsername = "organizer_username"
        case isOrganizer = "is_organizer"
        case joinStatus = "join_status"
        case createdAt = "created_at"
    }

    var isApproved: Bool {
        joinStatus == "approved"
    }

    var isPending: Bool {
        joinStatus == "pending"
    }

    var isJoinedOrPending: Bool {
        joinStatus != nil
    }

    var pendingCount: Int {
        participants?.filter { $0.status == "pending" }.count ?? 0
    }

    var isFull: Bool {
        currentParticipants >= maxParticipants
    }

    var spotsLeft: Int {
        max(0, maxParticipants - currentParticipants)
    }

    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    var sportColor: Color {
        switch sportType.lowercased() {
        case "pickleball": return .green
        case "badminton": return .orange
        case "tennis": return .blue
        case "basketball": return .red
        default: return .blue
        }
    }

    var sportIcon: String {
        switch sportType.lowercased() {
        case "pickleball": return "figure.pickleball"
        case "badminton": return "figure.badminton"
        case "tennis": return "figure.tennis"
        case "basketball": return "figure.basketball"
        default: return "sportscourt.fill"
        }
    }

    var formattedDate: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateTime) {
            return Self.displayFormatter.string(from: date)
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: dateTime) {
            return Self.displayFormatter.string(from: date)
        }
        // Try naive datetime (Python format without timezone)
        if let date = Self.naiveDateFormatter.date(from: dateTime) {
            return Self.displayFormatter.string(from: date)
        }
        return dateTime
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

struct EventCreate: Encodable {
    let title: String
    let description: String
    let sportType: String
    let location: String
    let dateTime: String
    let price: Double
    let maxParticipants: Int

    enum CodingKeys: String, CodingKey {
        case title, description, location, price
        case sportType = "sport_type"
        case dateTime = "date_time"
        case maxParticipants = "max_participants"
    }
}

struct JoinResponse: Codable {
    let message: String
    let status: String
}

struct ParticipantActionResponse: Codable {
    let message: String
}
