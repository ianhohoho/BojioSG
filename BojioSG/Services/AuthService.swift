import Foundation
import Supabase

@Observable
final class AuthService {
    private(set) var token: String?
    private(set) var email: String?
    private(set) var nickname: String?
    private(set) var isAuthenticated = false
    var needsPhoneSetup = false

    var displayName: String {
        nickname ?? email?.components(separatedBy: "@").first ?? "User"
    }

    private var authStateTask: Task<Void, Never>?

    init() {
        startListening()
    }

    deinit {
        authStateTask?.cancel()
    }

    private func startListening() {
        authStateTask = Task { [weak self] in
            for await (event, session) in SupabaseConfig.client.auth.authStateChanges {
                guard let self else { return }
                await MainActor.run {
                    switch event {
                    case .initialSession, .signedIn, .tokenRefreshed:
                        self.token = session?.accessToken
                        self.email = session?.user.email
                        self.isAuthenticated = session != nil
                    case .signedOut:
                        self.token = nil
                        self.email = nil
                        self.nickname = nil
                        self.isAuthenticated = false
                    default:
                        break
                    }
                }
            }
        }
    }

    func signInWithEmail(email: String, password: String) async throws {
        let session = try await SupabaseConfig.client.auth.signIn(
            email: email,
            password: password
        )
        self.token = session.accessToken
        self.email = session.user.email
        self.isAuthenticated = true
    }

    enum SignUpError: LocalizedError {
        case emailAlreadyRegistered

        var errorDescription: String? {
            switch self {
            case .emailAlreadyRegistered:
                return "An account with this email already exists. Please sign in instead."
            }
        }
    }

    /// Returns `true` if email confirmation is required (no session yet).
    @discardableResult
    func signUp(email: String, password: String) async throws -> Bool {
        let response = try await SupabaseConfig.client.auth.signUp(
            email: email,
            password: password
        )
        switch response {
        case .session(let session):
            self.token = session.accessToken
            self.email = session.user.email
            self.isAuthenticated = true
            self.needsPhoneSetup = true
            return false
        case .user(let user):
            // Supabase returns a user with empty identities when email is already registered
            if user.identities?.isEmpty != false {
                throw SignUpError.emailAlreadyRegistered
            }
            return true
        }
    }

    func signOut() async {
        try? await SupabaseConfig.client.auth.signOut()
        self.token = nil
        self.email = nil
        self.nickname = nil
        self.isAuthenticated = false
    }

    func updateNickname(_ nickname: String?) {
        self.nickname = nickname
    }
}
