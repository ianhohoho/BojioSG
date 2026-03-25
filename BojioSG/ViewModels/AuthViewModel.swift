import Foundation

@Observable
final class AuthViewModel {
    var email = ""
    var password = ""
    var errorMessage: String?
    var successMessage: String?
    var isLoading = false

    func login(authService: AuthService) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.signInWithEmail(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register(authService: AuthService) async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let needsConfirmation = try await authService.signUp(email: email, password: password)
            if needsConfirmation {
                successMessage = "Check your email for a confirmation link."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func clearForm() {
        email = ""
        password = ""
        errorMessage = nil
        successMessage = nil
    }
}
