import SwiftUI

struct AlertBanner: View {
    let message: String
    let style: Style

    enum Style {
        case error
        case success

        var color: Color {
            switch self {
            case .error: .red
            case .success: .green
            }
        }

        var icon: String {
            switch self {
            case .error: "exclamationmark.circle.fill"
            case .success: "checkmark.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: style.icon)
            Text(message)
        }
        .font(.subheadline)
        .foregroundStyle(style.color)
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(style.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
