import Foundation

/// Home empty page. The marquee is Dark and the foyer has no pass, so neither
/// Light nor Dismiss has a title to take. The next tap is to stash one.
struct Hush: Equatable, Sendable {
    var message: String

    static let idle = Hush(
        message: "Add a title, then light it when you start watching."
    )
}
