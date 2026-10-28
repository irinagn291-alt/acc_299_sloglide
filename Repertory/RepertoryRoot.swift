import Foundation

/// One chart record: foyer passes, the live marquee, and the append-only rep
/// chronicle. `schemaVersion` starts at 1. The open grade id is the transient
/// graded moment. It is not a resting marquee phase.
struct RepertoryRoot: Codable, Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var foyer: Foyer
    var marquee: Marquee
    var rep: [RepMark]
    var openGradeID: UUID?
    var onboardingComplete: Bool

    init(
        schemaVersion: Int = RepertoryRoot.currentSchema,
        foyer: Foyer = Foyer(),
        marquee: Marquee = Marquee(),
        rep: [RepMark] = [],
        openGradeID: UUID? = nil,
        onboardingComplete: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.foyer = foyer
        self.marquee = marquee
        self.rep = rep
        self.openGradeID = openGradeID
        self.onboardingComplete = onboardingComplete
    }

    static let empty = RepertoryRoot()

    var isVacant: Bool {
        foyer.passes.isEmpty && marquee.isDark && rep.isEmpty && openGradeID == nil
    }

    var finishedCount: Int { rep.count }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case foyer
        case marquee
        case rep
        case openGradeID
        case onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            foyer = try container.decode(Foyer.self, forKey: .foyer)
            marquee = try container.decode(Marquee.self, forKey: .marquee)
            rep = try container.decode([RepMark].self, forKey: .rep)
            openGradeID = try container.decodeIfPresent(UUID.self, forKey: .openGradeID)
            onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unknown repertory schema \(version)."
                )
            )
        }
    }
}
