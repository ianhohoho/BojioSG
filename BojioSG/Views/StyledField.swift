import SwiftUI

extension View {
    func styledField() -> some View {
        self
            .textFieldStyle(.plain)
            .font(.body)
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
