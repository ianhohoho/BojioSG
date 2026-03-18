import Foundation

@Observable
final class AuthService {
    private(set) var token: String?
    private(set) var isAuthenticated = false

    private let tokenKey = "bojiosg_auth_token"

    init() {
        self.token = UserDefaults.standard.string(forKey: tokenKey)
        self.isAuthenticated = token != nil
    }

    func setToken(_ token: String) {
        self.token = token
        self.isAuthenticated = true
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    func clearToken() {
        self.token = nil
        self.isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
