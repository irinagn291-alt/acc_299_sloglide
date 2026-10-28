import Foundation

/// Append-only finish record. Dismiss writes one with a day key and clears the
/// marquee. The grade arrives when the fused sheet confirms. Peel may drop only
/// the latest mark.
struct RepMark: Codable, Equatable, Sendable, Identifiable {
    var id: UUID
    var pass: Pass
    var daykey: Int
    var grade: Int?

    init(id: UUID = UUID(), pass: Pass, daykey: Int, grade: Int? = nil) {
        self.id = id
        self.pass = pass
        self.daykey = daykey
        self.grade = grade
    }

    var gradeIsCommitted: Bool {
        guard let grade else { return false }
        return (1...5).contains(grade)
    }
}
