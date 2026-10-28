import Foundation

/// Refused Light. The marquee is already Lit, so a second light does not
/// replace the showing pass and does not touch the rep chronicle.
struct DoubleMark: Equatable, Sendable {
    var message: String

    static let alreadyLit = DoubleMark(
        message: "Dismiss the title already showing before lighting another."
    )
}
