import SwiftUI

struct EventRowView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Sport badge + status badges + price
            HStack {
                StatusPill(label: event.sportType.capitalized, color: event.sportColor, icon: event.sportIcon)

                if event.isOrganizer == true {
                    HStack(spacing: 4) {
                        Text("Your event")
                        if event.pendingCount > 0 {
                            Text("\(event.pendingCount)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(.orange)
                                .clipShape(Capsule())
                        }
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.indigo.opacity(0.12))
                    .foregroundStyle(.indigo)
                    .clipShape(Capsule())
                } else if event.isApproved {
                    StatusPill(label: "Joined", color: .green)
                } else if event.isPaymentSubmitted {
                    StatusPill(label: "Paid", color: .teal)
                } else if event.isPendingPayment {
                    StatusPill(label: "Pay Now", color: .blue)
                } else if event.isPending {
                    StatusPill(label: "Pending", color: .orange)
                }

                Spacer()

                Text(event.formattedPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.green)
            }

            // Title
            Text(event.title)
                .font(.headline)
                .lineLimit(2)

            // Date
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption2)
                Text(event.formattedDate)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            // Location + spots
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption2)
                    Text(event.location)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: event.isFull ? "person.2.slash" : "person.2.fill")
                        .font(.caption2)
                    Text(event.isFull ? "Full" : "\(event.spotsLeft) spots")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundStyle(event.isFull ? .red : .blue)
            }
        }
        .cardStyle()
    }
}
