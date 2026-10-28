import Foundation
import Observation

/// The seam between the fold and the screens. Views call these methods.
/// They never read the archive or `UserDefaults`. Memory is the source of truth.
/// The file and the single defaults key are projections, written after each mark.
@MainActor
@Observable
final class RepertoryHouse {
    private(set) var root: RepertoryRoot
    private(set) var lastMark: FoldMark?
    private(set) var loadNote: String?
    private(set) var gradeDraft: Int?
    let gameCenter: GameCenterService
    /// False until the first `prepare()` finishes, so the frame does not flash empty.

    private let archive: RepertoryArchive
    private let defaults: UserDefaults
    private let seedDemo: Bool
    private let calendar: Calendar
    private(set) var isReady = false
    private var loaded = false
    private var saveTask: Task<Void, Never>?

    init(
        archive: RepertoryArchive? = nil,
        defaults: UserDefaults = .standard,
        seedDemo: Bool = true,
        calendar: Calendar = .current
    ) {
        self.archive = archive ?? .live
        self.defaults = defaults
        self.seedDemo = seedDemo
        self.calendar = calendar
        gameCenter = GameCenterService(defaults: defaults)
        root = .empty
    }

    var rollup: GradeRollup { GradeRollup.fold(root.rep) }

    var ribbonCount: Int { root.finishedCount }

    var phaseToken: String {
        if root.hushIfIdle() != nil { return "hush" }
        if root.marquee.litPass != nil { return "lit" }
        return "dark"
    }

    var showsGrade: Bool { root.openGradeID != nil }

    func prepare() async {
        guard !loaded else {
            isReady = true
            return
        }
        let result = await archive.load()
        if result.root.isVacant, let mirrored = mirroredRoot() {
            root = mirrored
        } else {
            root = result.root
            loadNote = result.note
        }
        seedIfNeeded()
        gradeDraft = root.openGradeID == nil ? nil : 3
        loaded = true
        isReady = true
        await flush()
    }

    func stash(_ pass: Pass) {
        lastMark = root.stash(pass)
        scheduleSave(immediate: false)
    }

    func light(passID: UUID) {
        let before = root
        let mark = root.light(passID: passID)
        if case .lit = mark {
            lastMark = mark
            scheduleSave(immediate: false)
        } else {
            root = before
            lastMark = mark
        }
    }

    func dismiss(on date: Date = Date()) {
        let before = root
        let mark = root.dismiss(on: date, calendar: calendar)
        if case .dismissed = mark {
            gradeDraft = 3
            lastMark = mark
            scheduleSave(immediate: true)
        } else {
            root = before
            lastMark = mark
        }
    }

    func setGradeDraft(_ grade: Int) {
        guard showsGrade else { return }
        gradeDraft = GradePips.step(grade, by: 0)
    }

    func confirmGrade() {
        guard let grade = gradeDraft else { return }
        let before = root
        guard let mark = root.confirmGrade(grade) else {
            root = before
            return
        }
        gradeDraft = nil
        lastMark = mark
        scheduleSave(immediate: true)
    }

    func peel() {
        guard let mark = root.peel() else { return }
        if root.openGradeID == nil { gradeDraft = nil }
        lastMark = mark
        scheduleSave(immediate: true)
    }

    func moveQueued(_ id: UUID, before: UUID) {
        root.moveQueued(id, before: before)
        scheduleSave(immediate: false)
    }

    func completeOnboarding() {
        root.completeOnboarding()
        scheduleSave(immediate: true)
    }

    /// Settings can show the intro again. The fold itself is unchanged.
    func reopenOnboarding() {
        root.onboardingComplete = false
        scheduleSave(immediate: true)
    }

    /// Clears a save note and writes the current root again.
    func retrySave() async {
        loadNote = nil
        await flush()
    }

    func resetAllData() async {
        saveTask?.cancel()
        root = .empty
        lastMark = nil
        gradeDraft = nil
        loadNote = nil
        defaults.removeObject(forKey: RepertoryArchive.storageKey)
        do {
            try await archive.reset()
        } catch {
            loadNote = "Reset could not remove the saved file."
        }
        loaded = true
        isReady = true
    }

    func flush() async {
        guard loaded else { return }
        let snapshot = root
        do {
            let data = try await archive.save(snapshot)
            guard !Task.isCancelled else { return }
            guard root == snapshot else {
                await flush()
                return
            }
            defaults.set(data, forKey: RepertoryArchive.storageKey)
            gameCenter.update(snapshot.rep)
        } catch is CancellationError {
            return
        } catch {
            loadNote = "The log could not be saved."
        }
    }

    private func scheduleSave(immediate: Bool) {
        guard loaded else { return }
        saveTask?.cancel()
        if immediate {
            saveTask = Task { await flush() }
            return
        }
        saveTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(350))
            } catch is CancellationError {
                return
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await self?.flush()
        }
    }

    private func seedIfNeeded() {
        #if targetEnvironment(simulator)
        guard seedDemo else { return }
        let alreadySeeded = defaults.bool(forKey: DemoSeed.storageKey)
        if root.isVacant, !alreadySeeded {
            root = DemoSeed.make(now: Date(), calendar: calendar)
        }
        if !root.onboardingComplete {
            root.completeOnboarding()
        }
        defaults.set(true, forKey: DemoSeed.storageKey)
        #endif
    }

    private func mirroredRoot() -> RepertoryRoot? {
        guard let data = defaults.data(forKey: RepertoryArchive.storageKey) else { return nil }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(RepertoryRoot.self, from: data)
    }
}
