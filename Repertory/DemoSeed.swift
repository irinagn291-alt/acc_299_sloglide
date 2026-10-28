import Foundation

/// Simulator opening house. One pass is already Lit so Dismiss is the first
/// live verb. Two foyer passes and two prior finishes keep the ribbon honest.
/// The versioned flag `rep.demo.v1` is stored by the house, not here.
enum DemoSeed {
    static let storageKey = "rep.demo.v1"

    static let litID = UUID(uuidString: "A1000001-0000-4000-8000-000000000001") ?? UUID()
    static let foyerA = UUID(uuidString: "A1000001-0000-4000-8000-000000000002") ?? UUID()
    static let foyerB = UUID(uuidString: "A1000001-0000-4000-8000-000000000003") ?? UUID()
    static let repA = UUID(uuidString: "A1000001-0000-4000-8000-000000000004") ?? UUID()
    static let repB = UUID(uuidString: "A1000001-0000-4000-8000-000000000005") ?? UUID()

    static func make(now: Date, calendar: Calendar) -> RepertoryRoot {
        let lit = Pass(
            id: litID,
            tmdbID: 550,
            mediaKind: .movie,
            title: "After Hours",
            year: 1985,
            posterPath: "/after.jpg",
            stashedAt: now.addingTimeInterval(-86_400 * 3)
        )
        let queuedA = Pass(
            id: foyerA,
            tmdbID: 680,
            mediaKind: .movie,
            title: "Pulp Fiction",
            year: 1994,
            posterPath: "/pulp.jpg",
            stashedAt: now.addingTimeInterval(-86_400 * 2)
        )
        let queuedB = Pass(
            id: foyerB,
            tmdbID: 1396,
            mediaKind: .series,
            title: "Breaking Bad",
            year: 2008,
            posterPath: "/bb.jpg",
            stashedAt: now.addingTimeInterval(-86_400)
        )
        let older = Pass(
            id: UUID(uuidString: "A1000001-0000-4000-8000-000000000006") ?? UUID(),
            tmdbID: 238,
            mediaKind: .movie,
            title: "The Godfather",
            year: 1972,
            posterPath: "/gf.jpg",
            stashedAt: now.addingTimeInterval(-86_400 * 10)
        )
        let newer = Pass(
            id: UUID(uuidString: "A1000001-0000-4000-8000-000000000007") ?? UUID(),
            tmdbID: 1399,
            mediaKind: .series,
            title: "Game of Thrones",
            year: 2011,
            posterPath: "/got.jpg",
            stashedAt: now.addingTimeInterval(-86_400 * 8)
        )
        let day = calendar.date(byAdding: .day, value: -2, to: now) ?? now
        let previous = calendar.date(byAdding: .day, value: -1, to: now) ?? now
        let first = RepMark(
            id: repA,
            pass: older,
            daykey: DayKey.yyyymmdd(day, calendar: calendar),
            grade: 5
        )
        let second = RepMark(
            id: repB,
            pass: newer,
            daykey: DayKey.yyyymmdd(previous, calendar: calendar),
            grade: 4
        )
        return RepertoryRoot(
            foyer: Foyer(passes: [queuedA, queuedB]),
            marquee: Marquee(phase: .lit(lit)),
            rep: [first, second],
            openGradeID: nil,
            onboardingComplete: true
        )
    }
}
