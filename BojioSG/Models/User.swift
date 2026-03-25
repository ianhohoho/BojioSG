import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let username: String?
    let email: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, email
        case createdAt = "created_at"
    }
}

struct ProfileResponse: Codable {
    let id: Int
    let username: String?
    let email: String?
    let nickname: String?
    let phoneNumber: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, email, nickname
        case phoneNumber = "phone_number"
        case createdAt = "created_at"
    }
}

struct ProfileUpdate: Encodable {
    let nickname: String?
    let phoneNumber: String?

    enum CodingKeys: String, CodingKey {
        case nickname
        case phoneNumber = "phone_number"
    }
}
