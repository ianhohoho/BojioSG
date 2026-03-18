import SwiftUI

struct EventDetailView: View {
    @Environment(AuthService.self) private var authService
    let event: Event
    @Bindable var viewModel: EventViewModel

    var body: some View {
        ScrollView {
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

                    // Status messages
                    if let joinMessage = viewModel.joinMessage {
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

                    // Join button
                    if event.isFull {
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
                    } else {
                        Button {
                            Task {
                                await viewModel.joinEvent(eventId: event.id, token: authService.token)
                            }
                        } label: {
                            Text("Join Event  \(event.formattedPrice)")
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.easeInOut(duration: 0.2), value: viewModel.joinMessage)
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage)
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
