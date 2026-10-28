import Foundation

/// The queue sheet's ordered passes. Stash appends. Light removes exactly one
/// tapped pass. Peel may insert a restored pass at the head. The foyer never
/// writes a finish record.
struct Foyer: Codable, Equatable, Sendable {
    var passes: [Pass]

    init(passes: [Pass] = []) {
        self.passes = passes
    }

    func index(of id: UUID) -> Int? {
        passes.firstIndex { $0.id == id }
    }

    mutating func append(_ pass: Pass) {
        passes.append(pass)
    }

    mutating func remove(id: UUID) -> Pass? {
        guard let index = index(of: id) else { return nil }
        return passes.remove(at: index)
    }

    /// Moves `id` so it sits immediately before `before`. Identity stays on the pass.
    mutating func move(_ id: UUID, before: UUID) {
        guard id != before, let from = index(of: id), index(of: before) != nil else { return }
        let pass = passes.remove(at: from)
        guard let destination = index(of: before) else {
            passes.append(pass)
            return
        }
        passes.insert(pass, at: destination)
    }

    mutating func insertAtHead(_ pass: Pass) {
        passes.insert(pass, at: 0)
    }
}
