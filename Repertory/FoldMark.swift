import Foundation

/// Typed result of one fold step. Refused transitions carry a mark and leave
/// the root unchanged. Successful transitions carry the value that was written.
enum FoldMark: Equatable, Sendable {
    case stashed(Pass)
    case lit(LightMark)
    case dismissed(RepMark)
    case graded(RepMark)
    case peeled(PeelMark)
    case empty(EmptyMark)
    case double(DoubleMark)
    case hush(Hush)
}
