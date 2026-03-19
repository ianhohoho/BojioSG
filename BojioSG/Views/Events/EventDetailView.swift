import SwiftUI

struct EventDetailView: View {
    @Environment(AuthService.self) private var authService
    let eventId: Int
    @Bindable var viewModel: EventViewModel

    @State private var isEditMode = false
    @State private var showRemoveConfirmation = false
    @State private var removeTargetParticipant: Participant?
    @State private var removeReason = ""

    private var event: Event? {
        viewModel.events.first(where: { $0.id == eventId })
    }

    var body: some View {
        ScrollView {
            if let event {
                VStack(spacing: 0) {
                    // Hero header
                    ZStack(alignment: .bottomLeading) {
                        LinearGradient(
                            colors: [event.sportColor.opacity(0.3), event.sportColor.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 180)

                        VStack(alignment: .leading, spacing: 8) {
                            Label(event.sportType.capitalized, systemImage: event.sportIcon)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())

                            Text(event.title)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(20)
                    }

                    VStack(spacing: 20) {
                        // Info cards
                        VStack(spacing: 0) {
                            DetailInfoRow(
                                icon: "calendar",
                                iconColor: .blue,
                                label: "Date & Time",
                                value: event.formattedDate
                            )
                            Divider().padding(.leading, 52)
                            DetailInfoRow(
                                icon: "mappin.and.ellipse",
                                iconColor: .red,
                                label: "Location",
                                value: event.location
                            )
                            Divider().padding(.leading, 52)
                            DetailInfoRow(
                                icon: "person.2.fill",
                                iconColor: .purple,
                                label: "Availability",
                                value: "\(event.spotsLeft) of \(event.maxParticipants) spots available"
                            )
                            Divider().padding(.leading, 52)
                            DetailInfoRow(
                                icon: "dollarsign.circle.fill",
                                iconColor: .green,
                                label: "Price",
                                value: event.formattedPrice
                            )
                            Divider().padding(.leading, 52)
                            DetailInfoRow(
                                icon: "person.fill",
                                iconColor: .indigo,
                                label: "Organized by",
                                value: event.organizerUsername
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.background)
                                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                        )

                        // About section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About")
                                .font(.headline)
                            Text(event.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.background)
                                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                        )

                        // Participants list (organizer only)
                        if event.isOrganizer == true, let participants = event.participants {
                            let pending = participants.filter { $0.status == "pending" }
                            let approved = participants.filter { $0.status == "approved" }

                            // Pending requests
                            if !pending.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Pending Requests")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(pending.count)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.orange)
                                    }

                                    ForEach(pending) { participant in
                                        HStack(spacing: 12) {
                                            Image(systemName: "person.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.orange)

                                            Text(participant.username)
                                                .font(.subheadline)
                                                .fontWeight(.medium)

                                            Spacer()

                                            Button {
                                                Task {
                                                    await viewModel.approveParticipant(
                                                        eventId: event.id,
                                                        userId: participant.id,
                                                        token: authService.token
                                                    )
                                                }
                                            } label: {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(.green)
                                            }

                                            Button {
                                                Task {
                                                    await viewModel.removeParticipant(
                                                        eventId: event.id,
                                                        userId: participant.id,
                                                        token: authService.token
                                                    )
                                                }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.background)
                                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                                )
                            }

                            // Approved participants
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Participants")
                                        .font(.headline)
                                    Spacer()
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isEditMode.toggle()
                                        }
                                    } label: {
                                        Text(isEditMode ? "Done" : "Edit")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color.accentColor)
                                    }
                                    Text("\(approved.count)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                }

                                if approved.isEmpty {
                                    Text("No approved participants yet")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                } else {
                                    ForEach(approved) { participant in
                                        HStack(spacing: 12) {
                                            if isEditMode {
                                                Button {
                                                    removeTargetParticipant = participant
                                                    removeReason = ""
                                                    showRemoveConfirmation = true
                                                } label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .font(.title3)
                                                        .foregroundStyle(.red.opacity(0.7))
                                                }
                                                .transition(.move(edge: .leading).combined(with: .opacity))
                                            }

                                            Image(systemName: "person.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.secondary)

                                            Text(participant.username)
                                                .font(.subheadline)
                                                .fontWeight(.medium)

                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                            )
                        }

                        // Status messages
                        if event.isOrganizer != true, let joinMessage = viewModel.joinMessage {
                            VStack(spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text(joinMessage)
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                if let phone = event.organizerPhoneNumber, !phone.isEmpty {
                                    HStack(spacing: 8) {
                                        Image(systemName: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90")
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Pay \(event.formattedPrice) via PayNow")
                                                .fontWeight(.semibold)
                                            Text("Send to \(phone) (\(event.organizerUsername))")
                                        }
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.blue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(14)
                                    .background(.blue.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        if let error = viewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                Text(error)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        // Action area
                        if event.isOrganizer == true {
                            HStack(spacing: 8) {
                                Image(systemName: "star.fill")
                                Text("You're the organizer")
                            }
                            .font(.headline)
                            .foregroundStyle(.indigo)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(.indigo.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else if event.isApproved, viewModel.joinMessage == nil {
                            VStack(spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("You've joined this event")
                                }
                                .font(.headline)
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                                Button {
                                    Task {
                                        await viewModel.leaveEvent(eventId: event.id, token: authService.token)
                                    }
                                } label: {
                                    Text("Withdraw")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.red)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(.red.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        } else if event.isPending, viewModel.joinMessage == nil {
                            VStack(spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.fill")
                                    Text("Waiting for approval")
                                }
                                .font(.headline)
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                                Button {
                                    Task {
                                        await viewModel.leaveEvent(eventId: event.id, token: authService.token)
                                    }
                                } label: {
                                    Text("Withdraw Request")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.red)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(.red.opacity(0.1))
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        } else if event.isFull {
                            HStack(spacing: 8) {
                                Image(systemName: "person.2.slash")
                                Text("This event is full")
                            }
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else if viewModel.joinMessage == nil {
                            Button {
                                Task {
                                    await viewModel.joinEvent(eventId: event.id, token: authService.token)
                                }
                            } label: {
                                Text("Request to Join  \(event.formattedPrice)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        LinearGradient(
                                            colors: [event.sportColor, event.sportColor.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.2), value: viewModel.joinMessage)
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
        .alert("Remove Participant?", isPresented: $showRemoveConfirmation) {
            TextField("Reason (optional)", text: $removeReason)
            Button("Cancel", role: .cancel) {
                removeTargetParticipant = nil
            }
            Button("Remove", role: .destructive) {
                if let participant = removeTargetParticipant, let event {
                    let reason = removeReason.trimmingCharacters(in: .whitespacesAndNewlines)
                    Task {
                        await viewModel.removeParticipant(
                            eventId: event.id,
                            userId: participant.id,
                            token: authService.token,
                            reason: reason.isEmpty ? nil : reason
                        )
                    }
                }
                removeTargetParticipant = nil
            }
        } message: {
            if let name = removeTargetParticipant?.username {
                Text("Are you sure you want to remove \(name)? They will be notified.")
            }
        }
    }
}

private struct DetailInfoRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
