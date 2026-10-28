import Foundation

/// Only committed grades count. Queue entries and an open grade earn nothing.
enum CinemaAchievements {
    static let prefix = "com.repertory.marquee.achievement."

    static func progress(for marks: [RepMark]) -> [String: Double] {
        let graded = marks.filter(\.gradeIsCommitted)
        let movies = Set(graded.filter { $0.pass.mediaKind == .movie }.map(\.pass.id)).count
        let series = Set(graded.filter { $0.pass.mediaKind == .series }.map(\.pass.id)).count
        let grades = Set(graded.map(\.pass.id)).count
        return [
            prefix + "first_film": percent(movies, target: 1),
            prefix + "ten_films": percent(movies, target: 10),
            prefix + "fifty_films": percent(movies, target: 50),
            prefix + "hundred_films": percent(movies, target: 100),
            prefix + "first_series": percent(series, target: 1),
            prefix + "ten_grades": percent(grades, target: 10)
        ]
    }

    private static func percent(_ count: Int, target: Int) -> Double {
        min(100, Double(count) / Double(target) * 100)
    }

    static func retainingProgress(_ previous: [String: Double], current: [String: Double]) -> [String: Double] {
        current.mapValues { min(100, max(0, $0)) }.merging(previous) { max($0, $1) }
    }
}
