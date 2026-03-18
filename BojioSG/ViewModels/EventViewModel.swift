import Foundation

@Observable
final class EventViewModel {
    var events: [Event] = []
    var isLoading = false
    var errorMessage: String?
    var joinMessage: String?

    private let apiClient = APIClient.shared

    func fetchEvents(token: String?) async {
        isLoading = true
        errorMessage = nil

        do {
            let fetched: [Event] = try await apiClient.request(
                path: "/events",
                token: token
            )
            events = fetched
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createEvent(_ event: EventCreate, token: String?) async -> Bool {
        guard let token else {
            errorMessage = "You must be logged in to create an event"
            return false
        }

        errorMessage = nil

        do {
            let _: Event = try await apiClient.request(
                path: "/events",
                method: "POST",
                body: event,
                token: token
            )
            await fetchEvents(token: token)
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func joinEvent(eventId: Int, token: String?) async {
        guard let token else {
            errorMessage = "You must be logged in to join an event"
            return
        }

        errorMessage = nil
        joinMessage = nil

        do {
            let response: JoinResponse = try await apiClient.request(
                path: "/events/\(eventId)/join",
                method: "POST",
                token: token
            )
            joinMessage = response.message
            // Refresh events to update participant counts
            await fetchEvents(token: token)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
