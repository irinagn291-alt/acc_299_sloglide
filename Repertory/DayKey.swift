import Foundation

/// Day edge for a finish record. The stored form is an Int YYYYMMDD taken from
/// `Calendar.startOfDay`, not a raw timestamp and not a string.
enum DayKey {
    static func yyyymmdd(_ date: Date, calendar: Calendar) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
