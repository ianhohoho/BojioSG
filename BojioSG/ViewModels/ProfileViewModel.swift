import Foundation

@Observable
final class ProfileViewModel {
    var nickname = ""
    var phoneNumber = ""
    var email = ""
    var isLoading = false
    var isSaving = false
    var errorMessage: String?
    var saveSuccess = false

    private let apiClient = APIClient.shared

    func fetchProfile(token: String?) async {
        guard let token else { return }
        isLoading = true
        errorMessage = nil

        do {
            let profile: ProfileResponse = try await apiClient.request(
                path: "/auth/me",
                token: token
            )
            email = profile.email ?? ""
            nickname = profile.nickname ?? ""
            phoneNumber = profile.phoneNumber ?? ""
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func updateProfile(token: String?) async -> ProfileResponse? {
        guard let token else { return nil }
        isSaving = true
        errorMessage = nil
        saveSuccess = false

        do {
            let update = ProfileUpdate(
                nickname: nickname.isEmpty ? nil : nickname,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
            )
            let profile: ProfileResponse = try await apiClient.request(
                path: "/auth/me",
                method: "PUT",
                body: update,
                token: token
            )
            saveSuccess = true
            isSaving = false
            return profile
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isSaving = false
        return nil
    }
}
