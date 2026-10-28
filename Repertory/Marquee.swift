import Foundation

/// Live slot on the home surface. Resting phases are Dark and Lit only.
/// The grade sheet is not a third resting phase: while it is up, the marquee
/// is already Dark and the root keeps an open grade id.
struct Marquee: Codable, Equatable, Sendable {
    enum Phase: Codable, Equatable, Sendable {
        case dark
        case lit(Pass)
    }

    var phase: Phase

    init(phase: Phase = .dark) {
        self.phase = phase
    }

    var litPass: Pass? {
        if case .lit(let pass) = phase { return pass }
        return nil
    }

    var isDark: Bool {
        if case .dark = phase { return true }
        return false
    }
}
