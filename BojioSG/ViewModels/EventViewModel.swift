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
            await fetchEvents(token: token)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func approveParticipant(eventId: Int, userId: Int, token: String?) async {
        guard let token else { return }
        errorMessage = nil

        do {
            let _: ParticipantActionResponse = try await apiClient.request(
                path: "/events/\(eventId)/participants/\(userId)/approve",
                method: "PUT",
                token: token
            )
            await fetchEvents(token: token)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func notifyPayment(eventId: Int, token: String?) async {
        guard let token else { return }
        errorMessage = nil

        do {
            let _: ParticipantActionResponse = try await apiClient.request(
                path: "/events/\(eventId)/notify-payment",
                method: "PUT",
                token: token
            )
            await fetchEvents(token: token)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmPayment(eventId: Int, userId: Int, token: String?) async {
        guard let token else { return }
        errorMessage = nil

        do {
            let _: ParticipantActionResponse = try await apiClient.request(
                path: "/events/\(eventId)/participants/\(userId)/confirm-payment",
                method: "PUT",
                token: token
            )
            await fetchEvents(token: token)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func removeParticipant(eventId: Int, userId: Int, token: String?, reason: String? = nil) async {
        guard let token else { return }
        errorMessage = nil

        do {
            let body: RemoveParticipantRequest? = reason.map { RemoveParticipantRequest(reason: $0) }
            let _: ParticipantActionResponse = try await apiClient.request(
                path: "/events/\(eventId)/participants/\(userId)",
                method: "DELETE",
                body: body,
                token: token
            )
            await fetchEvents(token: token)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func leaveEvent(eventId: Int, token: String?) async {
        guard let token else { return }
        errorMessage = nil
        joinMessage = nil

        do {
            let _: ParticipantActionResponse = try await apiClient.request(
                path: "/events/\(eventId)/leave",
                method: "DELETE",
                token: token
            )
            await fetchEvents(token: token)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
