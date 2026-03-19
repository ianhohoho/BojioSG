import SwiftUI

struct EventDetailView: View {
    @Environment(AuthService.self) private var authService
    let eventId: Int
    @Bindable var viewModel: EventViewModel

    @State private var isEditMode = false
    @State private var showRemoveConfirmation = false
    @State private var removeTargetParticipant: Participant?
    @State private var removeReason = ""
    @State private var showApprovalAlert = false
    @State private var approvedParticipantName = ""

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
                            StatusPill(label: event.sportType.capitalized, color: .white, icon: event.sportIcon)
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
                                label: "Price/pax",
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
                        .cardStyle()

                        // About section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About")
                                .font(.headline)
                            Text(event.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        .cardStyle()

                        // Participants list (organizer only)
                        if event.isOrganizer == true, let participants = event.participants {
                            let pending = participants.filter { $0.status == "pending" }
                            let awaitingPayment = participants.filter { $0.status == "pending_payment" || $0.status == "payment_submitted" }
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

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(participant.username)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                if let phone = participant.phoneNumber {
                                                    Text(phone)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }

                                            Spacer()

                                            Button {
                                                Task {
                                                    let name = participant.username
                                                    await viewModel.approveParticipant(
                                                        eventId: event.id,
                                                        userId: participant.id,
                                                        token: authService.token
                                                    )
                                                    if viewModel.errorMessage == nil {
                                                        approvedParticipantName = name
                                                        showApprovalAlert = true
                                                    }
                                                }
                                            } label: {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(.green)
                                            }

                                            Button {
                                                removeTargetParticipant = participant
                                                removeReason = ""
                                                showRemoveConfirmation = true
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .cardStyle()
                            }

                            // Awaiting payment
                            if !awaitingPayment.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Awaiting Payment")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(awaitingPayment.count)")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.blue)
                                    }

                                    ForEach(awaitingPayment) { participant in
                                        HStack(spacing: 12) {
                                            Image(systemName: "person.circle.fill")
                                                .font(.title3)
                                                .foregroundStyle(.blue)

                                            VStack(alignment: .leading, spacing: 2) {
                                                HStack(spacing: 6) {
                                                    Text(participant.username)
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                    if participant.status == "payment_submitted" {
                                                        Text("Paid")
                                                            .font(.caption2)
                                                            .fontWeight(.bold)
                                                            .foregroundStyle(.white)
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(.green)
                                                            .clipShape(Capsule())
                                                    }
                                                }
                                                if let phone = participant.phoneNumber {
                                                    Text(phone)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }

                                            Spacer()

                                            Button {
                                                Task {
                                                    await viewModel.confirmPayment(
                                                        eventId: event.id,
                                                        userId: participant.id,
                                                        token: authService.token
                                                    )
                                                }
                                            } label: {
                                                Text("Confirm")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(.green)
                                                    .clipShape(Capsule())
                                            }

                                            Button {
                                                removeTargetParticipant = participant
                                                removeReason = ""
                                                showRemoveConfirmation = true
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                                .cardStyle()
                            }

                            // Confirmed participants
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Confirmed")
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
                                    Text("No confirmed participants yet")
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

                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(participant.username)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                if let phone = participant.phoneNumber {
                                                    Text(phone)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }

                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            .cardStyle()
                        }

                        // Status messages
                        if event.isOrganizer != true, let joinMessage = viewModel.joinMessage {
                            AlertBanner(message: joinMessage, style: .success)
                                .fontWeight(.medium)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        if let error = viewModel.errorMessage {
                            AlertBanner(message: error, style: .error)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }

                        // Action area
                        if event.isOrganizer == true {
                            StatusBanner(icon: "star.fill", label: "You're the organizer", color: .indigo)
                        } else if event.isApproved, viewModel.joinMessage == nil {
                            VStack(spacing: 10) {
                                StatusBanner(icon: "checkmark.circle.fill", label: "You've joined this event", color: .green)

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
                        } else if event.isPendingPayment, viewModel.joinMessage == nil {
                            VStack(spacing: 10) {
                                StatusBanner(icon: "creditcard.fill", label: "Payment Required", color: .blue)

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

                                Button {
                                    Task {
                                        await viewModel.notifyPayment(eventId: event.id, token: authService.token)
                                    }
                                } label: {
                                    Text("Let Organiser Know Payment Made")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(
                                            LinearGradient(
                                                colors: [.blue, .blue.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }

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
                        } else if event.isPaymentSubmitted, viewModel.joinMessage == nil {
                            VStack(spacing: 10) {
                                StatusBanner(icon: "creditcard.fill", label: "Payment Required", color: .blue)

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

                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Organiser has been notified")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.teal)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(.teal.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))

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
                                StatusBanner(icon: "clock.fill", label: "Waiting for approval", color: .orange)

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
                            StatusBanner(icon: "person.2.slash", label: "This event is full", color: .gray)
                        } else if viewModel.joinMessage == nil {
                            GradientButton(
                                label: "Request to Join  \(event.formattedPrice)",
                                color: event.sportColor
                            ) {
                                Task {
                                    await viewModel.joinEvent(eventId: event.id, token: authService.token)
                                }
                            }
                            .font(.headline)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .refreshable {
            await viewModel.fetchEvents(token: authService.token)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.joinMessage = nil
            viewModel.errorMessage = nil
            await viewModel.fetchEvents(token: authService.token)
        }
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
        .alert("Request Approved", isPresented: $showApprovalAlert) {
            Button("OK") {}
        } message: {
            Text("\(approvedParticipantName) has been notified to PayNow you.")
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
