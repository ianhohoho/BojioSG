import SwiftUI

struct ProfileView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar + username header
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(.gray.opacity(0.5))

                        Text("@\(authService.username ?? "")")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)

                    // PayNow setup banner (shown for new users)
                    if authService.needsPhoneSetup {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(Color.accentColor)
                                .font(.body)
                                .padding(.top, 2)
                            Text("Add your phone number so participants can send you PayNow payments when you organise events.")
                                .font(.subheadline)
                                .foregroundStyle(Color.accentColor)
                        }
                        .padding(12)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                    }

                    // Profile form card
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Display Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            TextField("Enter a nickname", text: $viewModel.nickname)
                                .styledField()
                                .textContentType(.nickname)
                                .autocorrectionDisabled()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Phone Number")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            TextField("e.g. +65 9123 4567", text: $viewModel.phoneNumber)
                                .styledField()
                                .textContentType(.telephoneNumber)
                                .keyboardType(.phonePad)
                        }
                    }
                    .padding(.horizontal, 4)
                    .cardStyle()
                    .padding(.horizontal, 16)

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    // Save button
                    GradientButton(
                        label: viewModel.saveSuccess ? "Saved!" : (authService.needsPhoneSetup ? "Continue" : "Save Changes"),
                        isLoading: viewModel.isSaving
                    ) {
                        Task {
                            if let profile = await viewModel.updateProfile(token: authService.token) {
                                authService.updateNickname(profile.nickname)
                            }
                            if authService.needsPhoneSetup {
                                authService.needsPhoneSetup = false
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isSaving)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle(authService.needsPhoneSetup ? "Set Up Profile" : "Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(authService.needsPhoneSetup ? "Skip" : "Done") {
                        if authService.needsPhoneSetup {
                            authService.needsPhoneSetup = false
                        }
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchProfile(token: authService.token)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environment(AuthService())
}
