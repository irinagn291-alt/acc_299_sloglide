import Foundation

/// Successful Light. One foyer pass is now the lit marquee, and the phase
/// folded from Dark to Lit. The rep chronicle is unchanged.
struct LightMark: Equatable, Sendable {
    var passID: UUID
}
