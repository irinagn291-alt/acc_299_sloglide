import Foundation

/// Maps a horizontal drag across five grade pips to a whole grade.
/// The sheet calls this. The view does not invent the snap.
enum GradePips {
    static func grade(forFraction fraction: Double) -> Int {
        let clamped = min(max(fraction, 0), 0.999_999)
        return Int(clamped * 5) + 1
    }

    static func step(_ grade: Int, by delta: Int) -> Int {
        min(5, max(1, grade + delta))
    }
}
