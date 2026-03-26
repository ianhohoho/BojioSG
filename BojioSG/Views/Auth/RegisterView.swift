import SwiftUI

private struct Perk: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
}

private let perks = [
    Perk(icon: "calendar.badge.plus", text: "Browse and join sports events near you"),
    Perk(icon: "person.2.fill", text: "Connect with players in your community"),
    Perk(icon: "bell.badge.fill", text: "Get notified when spots open up"),
]

struct RegisterView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthViewModel()
    @State private var showPassword = false
    @State private var showConfirm = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.green.opacity(0.08), .blue.opacity(0.05), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        // Welcome header with branding
                        VStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Text("🎾")
                                    .font(.title2)
                                Text("BojioSG")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                            }

                            Text("Join the community")
                                .font(.title2.weight(.bold))

                            Text("Create an account and never miss a game")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 24)

                        // Perks section
                        VStack(spacing: 12) {
                            ForEach(perks) { perk in
                                HStack(spacing: 14) {
                                    Image(systemName: perk.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(.green)
                                        .frame(width: 36, height: 36)
                                        .background(.green.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))

                                    Text(perk.text)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)

                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 28)

                        // Divider
                        Rectangle()
                            .fill(.secondary.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 28)
                            .padding(.bottom, 24)

                        // Form
                        VStack(spacing: 16) {
                            VStack(spacing: 14) {
                                AuthInputField(
                                    icon: "envelope.fill",
                                    placeholder: "Email",
                                    text: $viewModel.email,
                                    contentType: .emailAddress,
                                    keyboardType: .emailAddress
                                )

                                // Password with show/hide
                                passwordField(
                                    icon: "lock.fill",
                                    placeholder: "Password (min 6 characters)",
                                    text: $viewModel.password,
                                    isVisible: showPassword,
                                    contentType: .newPassword
                                ) {
                                    showPassword.toggle()
                                }

                                // Confirm password with show/hide + match indicator
                                VStack(alignment: .leading, spacing: 6) {
                                    passwordField(
                                        icon: "lock.rotation",
                                        placeholder: "Confirm password",
                                        text: $viewModel.confirmPassword,
                                        isVisible: showConfirm,
                                        contentType: .newPassword,
                                        borderColor: viewModel.passwordsMatch ? .green : (viewModel.passwordMismatch ? .red : nil)
                                    ) {
                                        showConfirm.toggle()
                                    }

                                    if viewModel.passwordsMatch {
                                        Label("Passwords match", systemImage: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.green)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                    } else if viewModel.passwordMismatch {
                                        Text("Passwords do not match")
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                            }

                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            if let success = viewModel.successMessage {
                                Text(success)
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }

                            // Create Account button
                            Button {
                                Task { await viewModel.register(authService: authService) }
                            } label: {
                                Group {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Create Account")
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
                            .disabled(viewModel.isLoading || viewModel.successMessage != nil)
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
            .animation(.easeInOut(duration: 0.2), value: viewModel.successMessage)
            .animation(.easeInOut(duration: 0.2), value: viewModel.passwordsMatch)
            .animation(.easeInOut(duration: 0.2), value: viewModel.passwordMismatch)
        }
    }

    @ViewBuilder
    private func passwordField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isVisible: Bool,
        contentType: UITextContentType?,
        borderColor: Color? = nil,
        toggleVisibility: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            if isVisible {
                TextField(placeholder, text: text)
                    .textContentType(contentType)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } else {
                SecureField(placeholder, text: text)
                    .textContentType(contentType)
            }

            Button(action: toggleVisibility) {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor ?? .clear, lineWidth: 1.5)
        )
    }
}

#Preview {
    RegisterView()
        .environment(AuthService())
}
