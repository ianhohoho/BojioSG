import SwiftUI

struct StatusBanner: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.headline)
        .foregroundStyle(color)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
