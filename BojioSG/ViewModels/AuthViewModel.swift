import Foundation

@Observable
final class AuthViewModel {
    var username = ""
    var password = ""
    var errorMessage: String?
    var isLoading = false

    private let apiClient = APIClient.shared

    func login(authService: AuthService) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter username and password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = LoginRequest(username: username, password: password)
            let response: AuthResponse = try await apiClient.request(
                path: "/auth/login",
                method: "POST",
                body: request
            )
            authService.setAuth(
                token: response.accessToken,
                userId: response.userId,
                username: response.username,
                nickname: response.nickname
            )
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register(authService: AuthService) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter username and password"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let request = RegisterRequest(username: username, password: password)
            let response: AuthResponse = try await apiClient.request(
                path: "/auth/register",
                method: "POST",
                body: request
            )
            authService.setAuth(
                token: response.accessToken,
                userId: response.userId,
                username: response.username,
                nickname: response.nickname
            )
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func clearForm() {
        username = ""
        password = ""
        errorMessage = nil
    }
}
