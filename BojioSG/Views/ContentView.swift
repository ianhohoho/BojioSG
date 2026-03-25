import SwiftUI

struct ContentView: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        Group {
            if authService.isAuthenticated {
                EventListView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
        .sheet(isPresented: Binding(
            get: { authService.needsPhoneSetup },
            set: { authService.needsPhoneSetup = $0 }
        )) {
            ProfileView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService())
}
