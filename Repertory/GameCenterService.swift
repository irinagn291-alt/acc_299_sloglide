import GameKit
import Observation
import SwiftUI

@MainActor
@Observable
final class GameCenterService: NSObject, @MainActor GKGameCenterControllerDelegate {
    private(set) var isAuthenticated = false
    private(set) var status = "Connect in Settings > Game Center to save achievements."
    private(set) var isSyncing = false
    private var started = false
    private var desired: [String: Double] = [:]
    private var needsSync = false
    private var reportingEnabled = true
    private var session = 0
    private let defaults: UserDefaults
    weak var presenter: UIViewController?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
    }

    func start(reportingEnabled: Bool) {
        guard !started else { return }
        guard !ProcessInfo.processInfo.arguments.contains("-ReviewScreen"),
              NSClassFromString("XCTestCase") == nil else { return }
        started = true
        self.reportingEnabled = reportingEnabled
        authenticate()
    }

    private func authenticate() {
        status = "Connecting to Game Center."
        GKLocalPlayer.local.authenticateHandler = { [weak self] controller, error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if let controller {
                    self.present(controller)
                    return
                }
                self.session += 1
                self.isAuthenticated = GKLocalPlayer.local.isAuthenticated
                if self.isAuthenticated {
                    self.status = self.reportingEnabled
                        ? "Achievements connected."
                        : "Demo history is not sent to Game Center."
                    self.requestSync()
                } else {
                    self.status = error == nil
                        ? "Connect in Settings > Game Center to save achievements."
                        : "Game Center is unavailable. Check Settings > Game Center, then retry."
                }
            }
        }
    }

    /// Called only after the archive successfully saves the corresponding history.
    func update(_ marks: [RepMark]) {
        let next = CinemaAchievements.progress(for: marks)
        guard next != desired else { return }
        desired = next
        requestSync()
    }

    func retry() {
        guard started else { return }
        if GKLocalPlayer.local.isAuthenticated {
            isAuthenticated = true
            requestSync()
        } else {
            authenticate()
        }
    }

    func resume() {
        guard started else { return }
        isAuthenticated = GKLocalPlayer.local.isAuthenticated
        if isAuthenticated { requestSync() }
    }

    func showAchievements() {
        guard isAuthenticated else { retry(); return }
        let dashboard = GKGameCenterViewController(state: .achievements)
        dashboard.gameCenterDelegate = self
        present(dashboard)
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }

    private func present(_ controller: UIViewController) {
        guard var host = presenter?.viewIfLoaded?.window?.rootViewController else {
            status = "Game Center could not open. Return to Profile and retry."
            return
        }
        while let presented = host.presentedViewController { host = presented }
        host.present(controller, animated: true)
    }

    private func requestSync() {
        guard reportingEnabled, isAuthenticated else { return }
        let playerID = GKLocalPlayer.local.gamePlayerID
        let key = "rep.gameCenter.pending." + playerID
        let pending = CinemaAchievements.retainingProgress(
            defaults.dictionary(forKey: key) as? [String: Double] ?? [:], current: desired
        )
        defaults.set(pending, forKey: key)
        needsSync = true
        guard !isSyncing else { return }
        isSyncing = true
        Task { await sync(playerID: playerID, key: key, session: session) }
    }

    private func sync(playerID: String, key: String, session expectedSession: Int) async {
        defer {
            isSyncing = false
            if needsSync, session != expectedSession { requestSync() }
        }
        do {
            let remote = try await GKAchievement.loadAchievements()
            guard currentPlayer(playerID, session: expectedSession) else { return }
            var known = Dictionary(remote.map { ($0.identifier, $0.percentComplete) }, uniquingKeysWith: max)
            while needsSync {
                needsSync = false
                let pending = defaults.dictionary(forKey: key) as? [String: Double] ?? [:]
                let reports = pending.compactMap { id, value -> GKAchievement? in
                    guard value > (known[id] ?? 0) else { return nil }
                    let achievement = GKAchievement(identifier: id)
                    achievement.percentComplete = max(value, known[id] ?? 0)
                    achievement.showsCompletionBanner = true
                    return achievement
                }
                if !reports.isEmpty { try await GKAchievement.report(reports) }
                guard currentPlayer(playerID, session: expectedSession) else { return }
                for achievement in reports { known[achievement.identifier] = achievement.percentComplete }
                status = "Achievements saved to Game Center."
            }
        } catch {
            guard currentPlayer(playerID, session: expectedSession) else { return }
            needsSync = false
            status = "Achievements are waiting. Check your connection and retry."
        }
    }

    private func currentPlayer(_ id: String, session expected: Int) -> Bool {
        isAuthenticated && GKLocalPlayer.local.isAuthenticated
            && GKLocalPlayer.local.gamePlayerID == id && session == expected
    }
}

/// Keeps authentication and the dashboard attached to the active native window.
struct GameCenterPresenter: UIViewControllerRepresentable {
    var service: GameCenterService

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        service.presenter = controller
        return controller
    }

    func updateUIViewController(_ controller: UIViewController, context: Context) {
        service.presenter = controller
    }
}
