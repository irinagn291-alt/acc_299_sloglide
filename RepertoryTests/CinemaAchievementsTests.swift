import XCTest
@testable import Repertory

final class CinemaAchievementsTests: XCTestCase {
    private func mark(_ kind: Pass.MediaKind = .movie, grade: Int? = 3) -> RepMark {
        RepMark(pass: Pass(tmdbID: 1, mediaKind: kind, title: "Title", year: 2000,
                           posterPath: nil, stashedAt: .distantPast), daykey: 20261028, grade: grade)
    }

    func testOnlySavedValidGradesEarnAchievements() {
        let progress = CinemaAchievements.progress(for: [mark(grade: nil), mark(grade: 0), mark(grade: 6)])
        XCTAssertEqual(progress.count, 6)
        XCTAssertTrue(progress.values.allSatisfy { $0 == 0 })
    }

    func testFilmsAndSeriesHaveSeparateMilestones() {
        let p = CinemaAchievements.prefix
        let films = CinemaAchievements.progress(for: (0..<10).map { _ in mark() })
        XCTAssertEqual(films[p + "first_film"], 100)
        XCTAssertEqual(films[p + "ten_films"], 100)
        XCTAssertEqual(films[p + "fifty_films"], 20)
        XCTAssertEqual(films[p + "hundred_films"], 10)
        XCTAssertEqual(films[p + "first_series"], 0)
        XCTAssertEqual(films[p + "ten_grades"], 100)
        let series = CinemaAchievements.progress(for: [mark(.series)])
        XCTAssertEqual(series[p + "first_film"], 0)
        XCTAssertEqual(series[p + "first_series"], 100)
        XCTAssertEqual(series[p + "ten_grades"], 10)
    }

    func testReplayedFinishDoesNotCountTwice() {
        let finish = mark()
        var replay = finish
        replay.id = UUID()
        let progress = CinemaAchievements.progress(for: [finish, replay])
        XCTAssertEqual(progress[CinemaAchievements.prefix + "ten_films"], 10)
    }

    func testUndoAndResetKeepPreviouslyQueuedProgress() {
        let previous = CinemaAchievements.progress(for: (0..<10).map { _ in mark() })
        let afterUndo = CinemaAchievements.progress(for: (0..<9).map { _ in mark() })
        XCTAssertEqual(CinemaAchievements.retainingProgress(previous, current: afterUndo), previous)
        XCTAssertEqual(CinemaAchievements.retainingProgress(previous, current: CinemaAchievements.progress(for: [])), previous)
    }

    func testProgressStopsAtOneHundredPercent() {
        let progress = CinemaAchievements.progress(for: (0..<110).map { _ in mark() })
        XCTAssertTrue(progress.values.allSatisfy { (0...100).contains($0) })
        XCTAssertEqual(progress[CinemaAchievements.prefix + "hundred_films"], 100)
    }
}
