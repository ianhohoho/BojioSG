import SwiftUI

struct EventRowView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Sport badge + status badges + price
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: event.sportIcon)
                        .font(.caption)
                    Text(event.sportType.capitalized)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(event.sportColor.opacity(0.12))
                .foregroundStyle(event.sportColor)
                .clipShape(Capsule())

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
                    Text("Joined")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.12))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                } else if event.isPaymentSubmitted {
                    Text("Paid")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.teal.opacity(0.12))
                        .foregroundStyle(.teal)
                        .clipShape(Capsule())
                } else if event.isPendingPayment {
                    Text("Pay Now")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.12))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                } else if event.isPending {
                    Text("Pending")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange.opacity(0.12))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }
}
