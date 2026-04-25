import Foundation

extension Double {
    /// Treats this Double as minutes and returns a formatted string like "1 hour, 40 minutes".
    var formattedHoursAndMinutes: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full // e.g. "1 hour, 40 minutes"
        formatter.allowedUnits = [.hour, .minute]
        formatter.maximumUnitCount = 2 // show at most hours and minutes

        return formatter.string(from: self * 60) ?? "\(Int(self)) minutes"
    }
}
