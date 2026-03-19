import Foundation

extension String {
    func parsedAsAPIDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: self) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: self) { return date }
        let stripped = self.replacingOccurrences(of: "\\.\\d+$", with: "", options: .regularExpression)
        return DateParser.naiveDateFormatter.date(from: stripped)
    }

    func formattedAsEventDate() -> String {
        if let date = self.parsedAsAPIDate() {
            return DateParser.displayFormatter.string(from: date)
        }
        return self
    }
}

enum DateParser {
    static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d MMM yyyy, ha"
        f.amSymbol = "am"
        f.pmSymbol = "pm"
        return f
    }()

    static let naiveDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
