import SwiftUI

struct CreateEventView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: EventViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var sportType = "pickleball"
    @State private var location = ""
    @State private var dateTime = Date.now.addingTimeInterval(3600)
    @State private var priceText = ""
    @State private var maxParticipants = 8
    @State private var isSubmitting = false

    private let sportTypes = ["pickleball", "badminton", "tennis", "basketball"]

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && !location.trimmingCharacters(in: .whitespaces).isEmpty
        && (Double(priceText) ?? -1) >= 0
        && maxParticipants >= 2
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Sport Type Picker
                    VStack(alignment: .leading, spacing: 8) {
                        label("Sport", icon: "sportscourt.fill")

                        HStack(spacing: 10) {
                            ForEach(sportTypes, id: \.self) { sport in
                                sportButton(sport)
                            }
                        }
                    }
                    .cardStyle()

                    // Event Details
                    VStack(alignment: .leading, spacing: 16) {
                        label("Details", icon: "square.and.pencil")

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Title")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("e.g. Saturday Morning Pickleball", text: $title)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $description)
                                .frame(minHeight: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.quaternary, lineWidth: 1)
                                )
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("e.g. Clementi Sports Hall", text: $location)
                                .textFieldStyle(.roundedBorder)
                        }
                    }
                    .cardStyle()

                    // Date & Time
                    VStack(alignment: .leading, spacing: 12) {
                        label("When", icon: "calendar")

                        DatePicker(
                            "Date & Time",
                            selection: $dateTime,
                            in: Date.now...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.graphical)
                    }
                    .cardStyle()

                    // Price & Capacity
                    VStack(alignment: .leading, spacing: 16) {
                        label("Pricing & Capacity", icon: "dollarsign.circle.fill")

                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Price ($)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                TextField("0.00", text: $priceText)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                            }

                            Spacer(minLength: 20)

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Max Participants")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Stepper("\(maxParticipants)", value: $maxParticipants, in: 2...50)
                                    .monospacedDigit()
                            }
                        }
                    }
                    .cardStyle()

                    // Error message
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
                    }

                    // Create button
                    Button {
                        Task { await submit() }
                    } label: {
                        Group {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Event")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(
                                colors: isFormValid
                                    ? [sportColor, sportColor.opacity(0.8)]
                                    : [.gray, .gray.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
                .padding(16)
                .padding(.bottom, 20)
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Helpers

    private var sportColor: Color {
        switch sportType {
        case "pickleball": return .green
        case "badminton": return .orange
        case "tennis": return .blue
        case "basketball": return .red
        default: return .blue
        }
    }

    private func sportButton(_ sport: String) -> some View {
        let isSelected = sportType == sport
        let color: Color = switch sport {
        case "pickleball": .green
        case "badminton": .orange
        case "tennis": .blue
        case "basketball": .red
        default: .blue
        }

        return Button {
            sportType = sport
        } label: {
            Text(sport.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? color.opacity(0.15) : .clear)
                .foregroundStyle(isSelected ? color : .secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func label(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .fontWeight(.semibold)
    }

    private func submit() async {
        isSubmitting = true
        viewModel.errorMessage = nil

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let event = EventCreate(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            sportType: sportType,
            location: location.trimmingCharacters(in: .whitespaces),
            dateTime: formatter.string(from: dateTime),
            price: Double(priceText) ?? 0,
            maxParticipants: maxParticipants
        )

        let success = await viewModel.createEvent(event, token: authService.token)
        isSubmitting = false

        if success {
            dismiss()
        }
    }
}

// MARK: - Card Style Modifier

private extension View {
    func cardStyle() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            )
    }
}
