import Foundation

@Observable
final class AuthService {
    private(set) var token: String?
    private(set) var userId: Int?
    private(set) var username: String?
    private(set) var nickname: String?
    private(set) var isAuthenticated = false
    var needsPhoneSetup = false

    private let tokenKey = "bojiosg_auth_token"
    private let userIdKey = "bojiosg_user_id"
    private let usernameKey = "bojiosg_username"
    private let nicknameKey = "bojiosg_nickname"

    var displayName: String {
        nickname ?? username ?? "User"
    }

    init() {
        self.token = UserDefaults.standard.string(forKey: tokenKey)
        let storedId = UserDefaults.standard.integer(forKey: userIdKey)
        self.userId = storedId != 0 ? storedId : nil
        self.username = UserDefaults.standard.string(forKey: usernameKey)
        self.nickname = UserDefaults.standard.string(forKey: nicknameKey)
        self.isAuthenticated = token != nil
    }

    func setAuth(token: String, userId: Int, username: String, nickname: String?) {
        self.token = token
        self.userId = userId
        self.username = username
        self.nickname = nickname
        self.isAuthenticated = true
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
        if let nickname {
            UserDefaults.standard.set(nickname, forKey: nicknameKey)
        } else {
            UserDefaults.standard.removeObject(forKey: nicknameKey)
        }
    }

    func updateNickname(_ nickname: String?) {
        self.nickname = nickname
        if let nickname {
            UserDefaults.standard.set(nickname, forKey: nicknameKey)
        } else {
            UserDefaults.standard.removeObject(forKey: nicknameKey)
        }
    }

    func clearToken() {
        self.token = nil
        self.userId = nil
        self.username = nil
        self.nickname = nil
        self.isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
        UserDefaults.standard.removeObject(forKey: nicknameKey)
    }
}
