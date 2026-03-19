import Foundation
import SwiftUI

struct Participant: Codable, Identifiable {
    let id: Int
    let username: String
    let phoneNumber: String?
    let status: String
    let joinedAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, status
        case phoneNumber = "phone_number"
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
    let organizerPhoneNumber: String?
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
        case organizerPhoneNumber = "organizer_phone_number"
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

    var isPendingPayment: Bool {
        joinStatus == "pending_payment"
    }

    var isPaymentSubmitted: Bool {
        joinStatus == "payment_submitted"
    }

    var pendingPaymentCount: Int {
        participants?.filter { $0.status == "pending_payment" }.count ?? 0
    }

    var paymentSubmittedCount: Int {
        participants?.filter { $0.status == "payment_submitted" }.count ?? 0
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
        String(format: "$%.2f/pax", price)
    }

    var sportColor: Color {
        SportConstants.color(for: sportType)
    }

    var sportIcon: String {
        SportConstants.icon(for: sportType)
    }

    var parsedDate: Date? {
        dateTime.parsedAsAPIDate()
    }

    var formattedDate: String {
        dateTime.formattedAsEventDate()
    }
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

struct RemoveParticipantRequest: Encodable {
    let reason: String?
}
