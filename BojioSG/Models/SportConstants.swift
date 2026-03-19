import SwiftUI

enum SportConstants {
    static func color(for sportType: String) -> Color {
        switch sportType.lowercased() {
        case "pickleball": .green
        case "badminton": .orange
        case "tennis": .blue
        case "basketball": .red
        default: .blue
        }
    }

    static func icon(for sportType: String) -> String {
        switch sportType.lowercased() {
        case "pickleball": "figure.pickleball"
        case "badminton": "figure.badminton"
        case "tennis": "figure.tennis"
        case "basketball": "figure.basketball"
        default: "sportscourt.fill"
        }
    }
}
