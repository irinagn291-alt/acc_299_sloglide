import SwiftUI

/// Ordered queue. Light moves the tapped title onto the home slot.
struct QueueView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house

    var body: some View {
        ScreenShell(title: "Queue", showsClose: showsClose, onClose: onClose) {
            Group {
                if let note = house.loadNote, house.root.foyer.passes.isEmpty {
                    RetryNotice(title: "Queue unavailable.", line: note) {
                        Task { await house.retrySave() }
                    }
                } else if house.root.foyer.passes.isEmpty {
                    FullEmpty(
                        imageName: "rep_EmptyFoyerArt",
                        title: "Nothing in the queue.",
                        line: "Stash a title, then light the one you start.",
                        actionTitle: stashTitle,
                        action: stashSuggestion
                    )
                } else {
                    List {
                        if house.loadNote != nil {
                            SaveNote()
                                .rowChrome()
                        }
                        if let text = refusalText(house.lastMark) {
                            RefusalNote(text: text)
                                .rowChrome()
                        }
                        ForEach(Array(house.root.foyer.passes.enumerated()), id: \.element.id) { index, pass in
                            queueRow(pass, index: index, prominent: index == 0)
                                .rowChrome()
                        }
                    }
                    .repertoryList()
                }
            }
        }
    }

    private func queueRow(_ pass: Pass, index: Int, prominent: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            HStack(alignment: .center, spacing: Spacing.s12) {
                TitlePlate(title: pass.title, path: pass.posterPath)
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    Text(pass.title)
                        .appFont(prominent ? .title : .headline)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)
                    YearKind(year: pass.year, kind: pass.mediaKind)
                }
            }
            Button {
                house.light(passID: pass.id)
                if case .lit = house.lastMark {
                    onClose()
                }
            } label: {
                Text("Light")
            }
            .buttonStyle(SoftButtonStyle(role: prominent && house.root.marquee.isDark ? .primary : .secondary))
            .accessibilityLabel("Light \(pass.title)")
            HStack(spacing: Spacing.s12) {
                Button {
                    moveEarlier(pass.id)
                } label: {
                    Label("Earlier", systemImage: "arrow.up")
                }
                .buttonStyle(ChipButtonStyle())
                .disabled(index == 0)
                Button {
                    moveLater(pass.id)
                } label: {
                    Label("Later", systemImage: "arrow.down")
                }
                .buttonStyle(ChipButtonStyle())
                .disabled(index == house.root.foyer.passes.count - 1)
            }
        }
        .padding(Spacing.s16)
        .cardSurface()
    }

    private var stashTitle: String {
        if let title = LocalShelf.suggestion(in: house.root, now: Date())?.title {
            return "Stash \(title)"
        }
        return "Discover titles"
    }

    private func stashSuggestion() {
        if let pass = LocalShelf.suggestion(in: house.root, now: Date()) {
            house.stash(pass)
        } else {
            onClose()
        }
    }

    private func moveEarlier(_ id: UUID) {
        let passes = house.root.foyer.passes
        guard let index = passes.firstIndex(where: { $0.id == id }), index > 0 else { return }
        house.moveQueued(id, before: passes[index - 1].id)
    }

    private func moveLater(_ id: UUID) {
        let passes = house.root.foyer.passes
        guard let index = passes.firstIndex(where: { $0.id == id }), index + 1 < passes.count else { return }
        house.moveQueued(passes[index + 1].id, before: id)
    }
}
