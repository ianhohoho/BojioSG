import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case createdAt = "created_at"
    }
}

struct LoginRequest: Codable {
    let username: String
    let password: String
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let tokenType: String
    let userId: Int
    let username: String
    let nickname: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case userId = "user_id"
        case username, nickname
    }
}

struct ProfileResponse: Codable {
    let id: Int
    let username: String
    let nickname: String?
    let phoneNumber: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, username, nickname
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
