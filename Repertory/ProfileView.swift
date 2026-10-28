import SwiftUI

/// Taste summary, undo for the latest finish, and the way out to settings.
struct ProfileView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house
    @State private var child: AppRoute?
    @State private var confirmUndo = false

    var body: some View {
        ScreenShell(title: "Profile", showsClose: showsClose, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    SaveNote()
                    FinishedFigure(count: house.rollup.finishedCount)
                    GradeRollupChart(rollup: house.rollup)
                    gameCenter
                    if let last = house.root.rep.last {
                        VStack(alignment: .leading, spacing: Spacing.s8) {
                            Text("Latest finish")
                                .appFont(.label)
                                .foregroundStyle(DesignTokens.muted)
                            Text(last.pass.title)
                                .appFont(.title)
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(2)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Button {
                            confirmUndo = true
                        } label: {
                            Label("Undo last finish", systemImage: "arrow.uturn.backward")
                        }
                        .buttonStyle(SoftButtonStyle(role: .destructive))
                    } else {
                        Text("No finishes yet.")
                            .appFont(.body)
                            .foregroundStyle(DesignTokens.muted)
                    }
                    contact
                    VStack(spacing: Spacing.s12) {
                        link("Grades", route: .goals)
                        link("Finished titles", route: .seen)
                        link("Finish log", route: .log)
                        link("Day marks", route: .repmarks)
                        link("Undo finish", route: .peel)
                        link("Finishing", route: .twist)
                        link("Settings", route: .settings)
                    }
                }
                .padding(Spacing.s20)
            }
            .confirmationDialog(
                "Undo the last finish?",
                isPresented: $confirmUndo,
                titleVisibility: .visible
            ) {
                Button("Undo last finish", role: .destructive) {
                    house.peel()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("It returns to the queue. The home slot stays as it is.")
            }
            .sheet(item: $child) { route in
                childScreen(route)
            }
        }
    }

    private var contact: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Contact")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
            if let url = URL(string: "https://repertory-marquee.space/contact-us") {
                Link(destination: url) {
                    Label("Contact", systemImage: "envelope")
                        .frame(maxWidth: .infinity, minHeight: Spacing.s48)
                }
                .buttonStyle(SoftButtonStyle(role: .secondary))
            }
        }
    }

    private var gameCenter: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Game Center")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
            Text(house.gameCenter.status)
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
            Button {
                house.gameCenter.showAchievements()
            } label: {
                Label(house.gameCenter.isAuthenticated ? "View achievements" : "Connect Game Center", systemImage: "trophy")
                    .frame(maxWidth: .infinity, minHeight: Spacing.s48)
            }
            .buttonStyle(SoftButtonStyle(role: .secondary))
            if house.gameCenter.isAuthenticated {
                Button("Retry sync") { house.gameCenter.retry() }
                    .buttonStyle(SoftButtonStyle(role: .secondary))
                    .disabled(house.gameCenter.isSyncing)
            }
            Text("Grades stay on this device. Only achievement progress is sent to Game Center. Undo and Reset all data keep earned achievements.")
                .appFont(.caption)
                .foregroundStyle(DesignTokens.muted)
        }
    }

    private func link(_ title: String, route: AppRoute) -> some View {
        Button {
            child = route
        } label: {
            HStack {
                Text(title)
                Spacer(minLength: Spacing.s8)
                Image(systemName: "chevron.right")
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(SoftButtonStyle(role: .secondary))
    }

    @ViewBuilder
    private func childScreen(_ route: AppRoute) -> some View {
        switch route {
        case .goals:
            GoalsView(showsClose: true) { child = nil }
        case .seen:
            SeenView(showsClose: true) { child = nil }
        case .log:
            FinishLogView(showsClose: true) { child = nil }
        case .twist:
            TwistScreen(showsClose: true) { child = nil }
        case .settings:
            SettingsView(showsClose: true) { child = nil }
        case .repmarks:
            RepMarksView(showsClose: true) { child = nil }
        case .peel:
            PeelView(showsClose: true) { child = nil }
        case .discover, .queue, .profile:
            SettingsView(showsClose: true) { child = nil }
        }
    }
}
