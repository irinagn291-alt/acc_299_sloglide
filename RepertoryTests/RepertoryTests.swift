import XCTest
@testable import Repertory

@MainActor
final class RepertoryTests: XCTestCase {
    private func calendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }

    private func pass(id: UUID, title: String, tmdbID: Int = 1) -> Pass {
        Pass(
            id: id,
            tmdbID: tmdbID,
            mediaKind: .movie,
            title: title,
            year: 1999,
            posterPath: "/p.jpg",
            stashedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    private func litHouse(foyer: [Pass] = []) -> RepertoryRoot {
        let showing = pass(id: UUID(uuidString: "BBBBBBBB-BBBB-4BBB-8BBB-BBBBBBBBBBBB") ?? UUID(), title: "Showing", tmdbID: 9)
        return RepertoryRoot(
            foyer: Foyer(passes: foyer),
            marquee: Marquee(phase: .lit(showing)),
            rep: []
        )
    }

    func testDismissOnDarkLeavesRepUnchanged() {
        var root = RepertoryRoot(foyer: Foyer(passes: [pass(id: UUID(), title: "Queued")]))
        let count = root.finishedCount
        let mark = root.dismiss(on: Date(timeIntervalSince1970: 1_761_360_000), calendar: calendar())
        XCTAssertEqual(mark, .empty(.dark))
        XCTAssertEqual(root.finishedCount, count)
        XCTAssertTrue(root.marquee.isDark)
        XCTAssertNil(root.openGradeID)
    }

    func testDismissEmptyHouseWritesHush() {
        var root = RepertoryRoot.empty
        let mark = root.dismiss(on: Date(), calendar: calendar())
        XCTAssertEqual(mark, .hush(.idle))
        XCTAssertEqual(root.finishedCount, 0)
        XCTAssertTrue(root.isVacant)
    }

    func testDismissOnLitWritesRepAndFoldsDark() {
        let queued = pass(id: UUID(), title: "Still queued")
        var root = litHouse(foyer: [queued])
        let showing = root.marquee.litPass
        let when = Date(timeIntervalSince1970: 1_761_360_000)
        let mark = root.dismiss(on: when, calendar: calendar())
        guard case .dismissed(let written) = mark else {
            XCTFail("Expected a finish record")
            return
        }
        XCTAssertEqual(written.pass, showing)
        XCTAssertEqual(written.daykey, DayKey.yyyymmdd(when, calendar: calendar()))
        XCTAssertNil(written.grade)
        XCTAssertEqual(root.finishedCount, 1)
        XCTAssertTrue(root.marquee.isDark)
        XCTAssertEqual(root.openGradeID, written.id)
        XCTAssertEqual(root.foyer.passes, [queued])
        XCTAssertEqual(root.confirmGrade(4), .graded(root.rep[0]))
        XCTAssertEqual(root.rep[0].grade, 4)
        XCTAssertNil(root.openGradeID)
        XCTAssertTrue(root.marquee.isDark)
        XCTAssertNil(root.confirmGrade(0))
        XCTAssertNil(root.confirmGrade(6))
        XCTAssertEqual(root.rep[0].grade, 4)
    }

    func testLightWhileLitWritesDoubleMark() {
        let extra = pass(id: UUID(), title: "Extra")
        var root = litHouse(foyer: [extra])
        let before = root
        let mark = root.light(passID: extra.id)
        XCTAssertEqual(mark, .double(.alreadyLit))
        XCTAssertEqual(root, before)
    }

    func testStashDoesNotLightOrFile() {
        var root = litHouse()
        let marquee = root.marquee
        let added = pass(id: UUID(), title: "Stashed")
        let mark = root.stash(added)
        XCTAssertEqual(mark, .stashed(added))
        XCTAssertEqual(root.marquee, marquee)
        XCTAssertEqual(root.finishedCount, 0)
        XCTAssertEqual(root.foyer.passes.last, added)
    }

    func testLightFoldsDarkToLitAndRemovesTheTappedPass() {
        let first = pass(id: UUID(), title: "First")
        let second = pass(id: UUID(), title: "Second")
        var root = RepertoryRoot(foyer: Foyer(passes: [first, second]))
        let mark = root.light(passID: second.id)
        XCTAssertEqual(mark, .lit(LightMark(passID: second.id)))
        XCTAssertEqual(root.marquee.litPass, second)
        XCTAssertEqual(root.foyer.passes, [first])
        XCTAssertEqual(root.finishedCount, 0)
        XCTAssertFalse(root.marquee.isDark)
    }

    func testPeelDropsLastRepAndDoesNotRelight() {
        let showing = pass(id: UUID(), title: "Still showing", tmdbID: 3)
        let finished = pass(id: UUID(), title: "Finished", tmdbID: 4)
        let mark = RepMark(pass: finished, daykey: 20261024, grade: 2)
        var root = RepertoryRoot(
            foyer: Foyer(passes: [pass(id: UUID(), title: "Queued", tmdbID: 5)]),
            marquee: Marquee(phase: .lit(showing)),
            rep: [mark]
        )
        let peeled = root.peel()
        XCTAssertEqual(peeled, .peeled(PeelMark(restored: finished)))
        XCTAssertTrue(root.rep.isEmpty)
        XCTAssertEqual(root.foyer.passes.first, finished)
        XCTAssertEqual(root.marquee.litPass, showing)
        XCTAssertNil(root.peel())
    }

    func testRollupUsesCommittedGradesOnly() {
        let bare = RepMark(pass: pass(id: UUID(), title: "Open"), daykey: 20261025, grade: nil)
        let loved = RepMark(pass: pass(id: UUID(), title: "Loved"), daykey: 20261024, grade: 5)
        let rollup = GradeRollup.fold([bare, loved])
        XCTAssertEqual(rollup.finishedCount, 1)
        XCTAssertEqual(rollup.countsByGrade[5], 1)
        XCTAssertEqual(rollup.countsByGrade[1], 0)
    }

    func testGradePipsSnapToWholeGrades() {
        XCTAssertEqual(GradePips.grade(forFraction: 0), 1)
        XCTAssertEqual(GradePips.grade(forFraction: 0.5), 3)
        XCTAssertEqual(GradePips.grade(forFraction: 1), 5)
        XCTAssertEqual(GradePips.step(5, by: 1), 5)
        XCTAssertEqual(GradePips.step(1, by: -1), 1)
    }

    func testFoyerReorderKeepsIdentity() {
        let a = pass(id: UUID(), title: "A")
        let b = pass(id: UUID(), title: "B")
        let c = pass(id: UUID(), title: "C")
        var foyer = Foyer(passes: [a, b, c])
        foyer.move(a.id, before: c.id)
        XCTAssertEqual(foyer.passes.map(\.id), [b.id, a.id, c.id])
    }

    func testSimulatorSeedLeavesDismissLive() {
        let root = DemoSeed.make(now: Date(timeIntervalSince1970: 1_761_360_000), calendar: calendar())
        XCTAssertNotNil(root.marquee.litPass)
        XCTAssertEqual(root.foyer.passes.count, 2)
        XCTAssertEqual(root.rep.count, 2)
        XCTAssertTrue(root.onboardingComplete)
        XCTAssertNil(root.hushIfIdle())
        XCTAssertEqual(root.rep.map(\.grade), [5, 4])
    }

    func testRestingPhasesStayDarkOrLit() {
        var root = RepertoryRoot(foyer: Foyer(passes: [pass(id: UUID(), title: "Only")]))
        _ = root.light(passID: root.foyer.passes[0].id)
        XCTAssertNotNil(root.marquee.litPass)
        _ = root.dismiss(on: Date(timeIntervalSince1970: 1_761_360_000), calendar: calendar())
        XCTAssertTrue(root.marquee.isDark)
        XCTAssertNotNil(root.openGradeID)
        _ = root.confirmGrade(3)
        XCTAssertTrue(root.marquee.isDark)
        XCTAssertNil(root.openGradeID)
    }

    func testPersistenceRoundTrip() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("rep-tests-\(UUID().uuidString)", isDirectory: true)
        let suite = "rep.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)
        XCTAssertNotNil(defaults)
        guard let defaults else { return }
        defer {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: directory)
        }
        let archive = RepertoryArchive(directory: directory)
        let house = RepertoryHouse(archive: archive, defaults: defaults, seedDemo: false, calendar: calendar())
        await house.prepare()
        let added = pass(id: UUID(), title: "Persisted")
        house.stash(added)
        let queued = house.root.foyer.passes[0]
        house.light(passID: queued.id)
        house.dismiss(on: Date(timeIntervalSince1970: 1_761_360_000))
        house.confirmGrade()
        await house.flush()

        let reloaded = RepertoryHouse(archive: archive, defaults: defaults, seedDemo: false, calendar: calendar())
        await reloaded.prepare()
        XCTAssertEqual(reloaded.root.rep.count, 1)
        XCTAssertEqual(reloaded.root.rep[0].pass.title, "Persisted")
        XCTAssertEqual(reloaded.root.rep[0].grade, 3)
        XCTAssertTrue(reloaded.root.marquee.isDark)
        XCTAssertTrue(reloaded.root.foyer.passes.isEmpty)
        XCTAssertNotNil(defaults.data(forKey: RepertoryArchive.storageKey))
    }

    func testCorruptFileFallsBackToBackup() async {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("rep-corrupt-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let archive = RepertoryArchive(directory: directory)
        var saved = RepertoryRoot(foyer: Foyer(passes: [pass(id: UUID(), title: "Backup")]))
        saved.onboardingComplete = true
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try? encoder.encode(saved)
        XCTAssertNotNil(data)
        guard let data else { return }
        let backup = directory.appendingPathComponent("repertory.json.backup")
        let main = directory.appendingPathComponent("repertory.json")
        try? data.write(to: backup, options: .atomic)
        try? Data("not-json".utf8).write(to: main, options: .atomic)
        let loaded = await archive.load()
        XCTAssertEqual(loaded.root.foyer.passes.first?.title, "Backup")
        XCTAssertNotNil(loaded.note)
    }

    func testResetClearsTheProjection() async {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("rep-reset-\(UUID().uuidString)", isDirectory: true)
        let suite = "rep.reset.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suite) else {
            XCTFail("Missing defaults suite")
            return
        }
        defer {
            defaults.removePersistentDomain(forName: suite)
            try? FileManager.default.removeItem(at: directory)
        }
        let house = RepertoryHouse(
            archive: RepertoryArchive(directory: directory),
            defaults: defaults,
            seedDemo: false,
            calendar: calendar()
        )
        await house.prepare()
        house.stash(pass(id: UUID(), title: "Gone"))
        await house.flush()
        await house.resetAllData()
        XCTAssertTrue(house.root.isVacant)
        XCTAssertNil(defaults.data(forKey: RepertoryArchive.storageKey))
        let again = await RepertoryArchive(directory: directory).load()
        XCTAssertTrue(again.root.isVacant)
    }

    func testReviewLaunchParsesScreenArgument() {
        XCTAssertNil(ReviewLaunch.screen(in: ["Repertory"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Repertory", "-ReviewScreen"]))
        XCTAssertEqual(ReviewLaunch.screen(in: ["Repertory", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Repertory", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Repertory", "-ReviewScreen", "goals"]), "goals")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Repertory", "-ReviewScreen", "foyer"]), "foyer")
        XCTAssertEqual(ReviewLaunch.screen, ReviewLaunch.screen(in: ProcessInfo.processInfo.arguments))
    }

    func testSearchDecodesNumericStringsAndRefusesMalformedJSON() async throws {
        let payload = """
        {"page":"2","results":[{"id":"42","title":"Nope","release_date":"2022-07-22","poster_path":"/n.jpg"}],"total_pages":"4"}
        """.data(using: .utf8) ?? Data()
        let decoded = client(responses: [.success(payload)])
        let envelope = try await decoded.client.searchMovies("nope", page: 2)
        XCTAssertEqual(envelope.page, 2)
        XCTAssertEqual(envelope.totalPages, 4)
        XCTAssertEqual(envelope.results.first?.makePass(kind: .movie, stashedAt: Date())?.title, "Nope")
        XCTAssertEqual(envelope.results.first?.makePass(kind: .movie, stashedAt: Date())?.year, 2022)
        let agent = await decoded.box.userAgent
        XCTAssertEqual(agent, TitleClient.userAgent)

        let broken = client(responses: [.success(Data("[]".utf8))])
        do {
            _ = try await broken.client.searchMovies("nope", page: 1)
            XCTFail("Malformed JSON should be a handled error")
        } catch let error as CatalogError {
            XCTAssertEqual(error, .decoding)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
    }

    func testSearchRetriesTransportOnceAndSkipsNotFound() async throws {
        let ok = """
        {"page":1,"results":[],"total_pages":1}
        """.data(using: .utf8) ?? Data()
        let flaky = client(responses: [.failure(URLError(.networkConnectionLost)), .success(ok)])
        let envelope = try await flaky.client.searchSeries("tape", page: 1)
        XCTAssertEqual(envelope.results.count, 0)
        let calls = await flaky.box.calls
        XCTAssertEqual(calls, 2)

        let missing = client(status: 404, responses: [.success(ok)])
        do {
            _ = try await missing.client.searchMovies("missing", page: 1)
            XCTFail("404 should not retry")
        } catch let error as CatalogError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Unexpected error \(error)")
        }
        let after = await missing.box.calls
        XCTAssertEqual(after, 1)
    }

    /// Light then dismiss is the home verb. This is not an OLS rate fit and not a COSC spread.
    func testDismissFilesTheLitTitle() {
        let calendar = Calendar(identifier: .gregorian)
        var root = DemoSeed.make(now: Date(), calendar: calendar)
        let before = root.rep.count
        let mark = root.dismiss(on: Date(), calendar: calendar)
        guard case .dismissed = mark else {
            XCTFail("A lit title should file a finish")
            return
        }
        XCTAssertEqual(root.rep.count, before + 1)
        XCTAssertTrue(root.marquee.isDark)
        XCTAssertNotNil(root.openGradeID)
    }

    func testStaleSearchIsNotAdmitted() {
        XCTAssertFalse(SearchAdmission.admit(token: 1, current: 2, cancelled: false))
        XCTAssertFalse(SearchAdmission.admit(token: 2, current: 2, cancelled: true))
        XCTAssertTrue(SearchAdmission.admit(token: 2, current: 2, cancelled: false))
    }

    private func client(status: Int = 200, responses: [Result<Data, Error>]) -> (client: TitleClient, box: ResponseBox) {
        let box = ResponseBox(responses: responses, status: status)
        let client = TitleClient(apiKey: "test-key", transport: { request in
            try await box.respond(to: request)
        })
        return (client, box)
    }
}

private actor ResponseBox {
    var responses: [Result<Data, Error>]
    let status: Int
    private(set) var calls = 0
    private(set) var userAgent: String?

    init(responses: [Result<Data, Error>], status: Int) {
        self.responses = responses
        self.status = status
    }

    func respond(to request: URLRequest) throws -> (Data, HTTPURLResponse) {
        calls += 1
        userAgent = request.value(forHTTPHeaderField: "User-Agent")
        if request.timeoutInterval != TitleClient.timeout {
            throw CatalogError.transport
        }
        let result = responses.isEmpty ? .failure(URLError(.badServerResponse)) : responses.removeFirst()
        switch result {
        case .success(let data):
            let url = request.url ?? URL(fileURLWithPath: "/tmp/repertory-test")
            guard let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil) else {
                throw CatalogError.transport
            }
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
}
