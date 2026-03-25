import SwiftUI

struct CreateEventView: View {
    @Environment(AuthService.self) private var authService
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: EventViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var sportType = "pickleball"
    @State private var location = ""
    @State private var dateTime: Date = {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: .now)
        comps.hour = 12
        comps.minute = 0
        return Calendar.current.date(from: comps) ?? .now
    }()
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
                        sectionLabel("Sport", icon: "sportscourt.fill")

                        FlowLayout(spacing: 10) {
                            ForEach(sportTypes, id: \.self) { sport in
                                sportButton(sport)
                            }
                        }
                    }
                    .cardStyle()

                    // Event Details
                    VStack(alignment: .leading, spacing: 16) {
                        sectionLabel("Details", icon: "square.and.pencil")

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Title")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("e.g. Saturday Morning Pickleball", text: $title)
                                .styledField()
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextEditor(text: $description)
                                .font(.body)
                                .padding(10)
                                .frame(minHeight: 80)
                                .scrollContentBackground(.hidden)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Location")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            TextField("e.g. Clementi Sports Hall", text: $location)
                                .styledField()
                        }
                    }
                    .cardStyle()

                    // Date & Time
                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("When", icon: "calendar")

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
                        sectionLabel("Pricing & Capacity", icon: "dollarsign.circle.fill")

                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Price/pax ($)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                TextField("0.00", text: $priceText)
                                    .styledField()
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
                        AlertBanner(message: error, style: .error)
                    }

                    // Create button
                    GradientButton(
                        label: "Create Event",
                        isLoading: isSubmitting,
                        color: isFormValid ? sportColor : .gray
                    ) {
                        Task { await submit() }
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
        SportConstants.color(for: sportType)
    }

    private func sportButton(_ sport: String) -> some View {
        let isSelected = sportType == sport
        let color = SportConstants.color(for: sport)

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

    private func sectionLabel(_ text: String, icon: String) -> some View {
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
