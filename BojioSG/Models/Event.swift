import Foundation
import SwiftUI

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
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case sportType = "sport_type"
        case location
        case dateTime = "date_time"
        case price
        case maxParticipants = "max_participants"
        case currentParticipants = "current_participants"
        case organizerId = "organizer_id"
        case createdAt = "created_at"
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
        guard let date = formatter.date(from: dateTime) else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            guard let date = formatter.date(from: dateTime) else { return dateTime }
            return Self.displayFormatter.string(from: date)
        }
        return Self.displayFormatter.string(from: date)
    }

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
}

struct JoinResponse: Codable {
    let message: String
}
