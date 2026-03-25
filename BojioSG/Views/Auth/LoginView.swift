import SwiftUI

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    @State private var viewModel = AuthViewModel()
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.08), .purple.opacity(0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 60)

                        // Logo & tagline
                        VStack(spacing: 12) {
                            Image(systemName: "figure.run.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(.linearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))

                            Text("BojioSG")
                                .font(.system(size: 36, weight: .bold, design: .rounded))

                            Text("Don't say Bojio! Join fun activites near you.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 8)

                        // Input fields card
                        VStack(spacing: 16) {
                            VStack(spacing: 14) {
                                AuthInputField(
                                    icon: "envelope.fill",
                                    placeholder: "Email",
                                    text: $viewModel.email,
                                    contentType: .emailAddress,
                                    keyboardType: .emailAddress
                                )
                                AuthInputField(
                                    icon: "lock.fill",
                                    placeholder: "Password",
                                    text: $viewModel.password,
                                    contentType: .password,
                                    isSecure: true
                                )
                            }

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Login button
                            Button {
                                Task { await viewModel.login(authService: authService) }
                            } label: {
                                Group {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Log In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 22)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle(radius: 12))
                            .controlSize(.large)
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.horizontal, 24)

                        // Sign up link
                        Button {
                            showRegister = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundStyle(.secondary)
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .sheet(isPresented: $showRegister) {
                RegisterView()
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthService())
}
