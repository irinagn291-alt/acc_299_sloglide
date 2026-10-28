import Foundation

/// Refused Dismiss. The marquee is Dark, so there is no finish to file.
/// The rep count stays the same. The next tap that works is Light.
struct EmptyMark: Equatable, Sendable {
    var message: String

    static let dark = EmptyMark(
        message: "Light a queued title before you log a finish."
    )
}
