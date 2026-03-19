import SwiftUI

struct RegisterView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.green.opacity(0.06), .blue.opacity(0.04), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        Spacer(minLength: 40)

                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(.linearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))

                            Text("Create Account")
                                .font(.system(size: 28, weight: .bold, design: .rounded))

                            Text("Join the community")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.bottom, 8)

                        // Input fields
                        VStack(spacing: 16) {
                            VStack(spacing: 14) {
                                AuthInputField(
                                    icon: "person.fill",
                                    placeholder: "Username",
                                    text: $viewModel.username,
                                    contentType: .username
                                )
                                AuthInputField(
                                    icon: "lock.fill",
                                    placeholder: "Password (min 6 characters)",
                                    text: $viewModel.password,
                                    contentType: .newPassword,
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

                            // Sign Up button
                            Button {
                                Task { await viewModel.register(authService: authService) }
                            } label: {
                                Group {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign Up")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 22)
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.roundedRectangle(radius: 12))
                            .controlSize(.large)
                            .tint(.green)
                            .disabled(viewModel.isLoading)
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 40)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    }
                }
            }
            .onChange(of: authService.isAuthenticated) { _, isAuth in
                if isAuth { dismiss() }
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
        }
    }
}

#Preview {
    RegisterView()
        .environment(AuthService())
}
