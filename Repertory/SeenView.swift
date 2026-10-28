import SwiftUI

/// Finished titles, newest first. Grades come from saved finishes only.
struct SeenView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house

    var body: some View {
        ScreenShell(title: "Finished", showsClose: showsClose, onClose: onClose) {
            Group {
                if let note = house.loadNote, house.root.rep.isEmpty {
                    RetryNotice(title: "Finishes unavailable.", line: note) {
                        Task { await house.retrySave() }
                    }
                } else if house.root.rep.isEmpty {
                    FullEmpty(
                        imageName: "rep_EmptyHome",
                        title: "No finishes yet.",
                        line: "Dismiss a showing title to file it here.",
                        actionTitle: "Back to tonight",
                        action: onClose
                    )
                } else {
                    TimelineView(.everyMinute) { context in
                        ScrollView {
                            VStack(alignment: .leading, spacing: Spacing.s24) {
                                SaveNote()
                                FinishedFigure(count: house.ribbonCount)
                                if let last = house.root.rep.last {
                                    feature(last, now: context.date)
                                }
                                if house.root.rep.count > 1 {
                                    VStack(alignment: .leading, spacing: Spacing.s12) {
                                        Text("Earlier")
                                            .appFont(.label)
                                            .foregroundStyle(DesignTokens.muted)
                                        ForEach(house.root.rep.dropLast().reversed()) { mark in
                                            compact(mark, now: context.date)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, Spacing.s20)
                            .padding(.top, Spacing.s16)
                            .padding(.bottom, Spacing.s32)
                        }
                    }
                }
            }
        }
    }

    private func feature(_ mark: RepMark, now: Date) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Latest")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
            Text(mark.pass.title)
                .appFont(.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(3)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
            YearKind(year: mark.pass.year, kind: mark.pass.mediaKind)
            DayText(daykey: mark.daykey, now: now)
            grade(mark.grade)
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
    }

    private func compact(_ mark: RepMark, now: Date) -> some View {
        HStack(alignment: .center, spacing: Spacing.s12) {
            TitlePlate(title: mark.pass.title, path: mark.pass.posterPath)
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(mark.pass.title)
                    .appFont(.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .truncationMode(.tail)
                DayText(daykey: mark.daykey, now: now)
            }
            Spacer(minLength: Spacing.s8)
            grade(mark.grade)
        }
        .padding(Spacing.s16)
        .cardSurface()
    }

    @ViewBuilder
    private func grade(_ value: Int?) -> some View {
        if let value {
            Text(value, format: .number.precision(.fractionLength(0)))
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
        } else {
            Text("unknown")
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
        }
    }
}
