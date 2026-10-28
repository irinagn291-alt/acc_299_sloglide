import Foundation

/// Taste counts folded from finish records for the profile sheet. Nothing here
/// is stored. Grades outside 1...5 and marks still waiting on the sheet are omitted.
struct GradeRollup: Equatable, Sendable {
    var finishedCount: Int
    var countsByGrade: [Int: Int]

    static func fold(_ marks: [RepMark]) -> GradeRollup {
        var counts: [Int: Int] = [:]
        for grade in 1...5 {
            counts[grade] = 0
        }
        var finished = 0
        for mark in marks where mark.gradeIsCommitted {
            guard let grade = mark.grade else { continue }
            counts[grade, default: 0] += 1
            finished += 1
        }
        return GradeRollup(finishedCount: finished, countsByGrade: counts)
    }
}
