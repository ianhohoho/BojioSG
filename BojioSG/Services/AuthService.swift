import Foundation

@Observable
final class AuthService {
    private(set) var token: String?
    private(set) var userId: Int?
    private(set) var username: String?
    private(set) var isAuthenticated = false

    private let tokenKey = "bojiosg_auth_token"
    private let userIdKey = "bojiosg_user_id"
    private let usernameKey = "bojiosg_username"

    init() {
        self.token = UserDefaults.standard.string(forKey: tokenKey)
        let storedId = UserDefaults.standard.integer(forKey: userIdKey)
        self.userId = storedId != 0 ? storedId : nil
        self.username = UserDefaults.standard.string(forKey: usernameKey)
        self.isAuthenticated = token != nil
    }

    func setAuth(token: String, userId: Int, username: String) {
        self.token = token
        self.userId = userId
        self.username = username
        self.isAuthenticated = true
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
    }

    func clearToken() {
        self.token = nil
        self.userId = nil
        self.username = nil
        self.isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
    }
}
