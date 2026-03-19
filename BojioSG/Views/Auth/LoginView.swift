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
                                HStack(spacing: 12) {
                                    Image(systemName: "person.fill")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 20)
                                    TextField("Username", text: $viewModel.username)
                                        .textContentType(.username)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                }
                                .padding(14)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 20)
                                    SecureField("Password", text: $viewModel.password)
                                        .textContentType(.password)
                                }
                                .padding(14)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
