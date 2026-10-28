import SwiftUI

/// Dated finish list. The home slot stays on tonight.
struct FinishLogView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house

    var body: some View {
        ScreenShell(title: "Finish log", showsClose: showsClose, onClose: onClose) {
            Group {
                if let note = house.loadNote, house.root.rep.isEmpty {
                    RetryNotice(title: "Log unavailable.", line: note) {
                        Task { await house.retrySave() }
                    }
                } else if house.root.rep.isEmpty {
                    FullEmpty(
                        imageName: "rep_EmptyHome",
                        title: "The log is empty.",
                        line: "Dismiss a showing title and it lands here with the day.",
                        actionTitle: "Back to tonight",
                        action: onClose
                    )
                } else {
                    TimelineView(.everyMinute) { context in
                        List {
                            if house.loadNote != nil {
                                SaveNote()
                                    .rowChrome()
                            }
                            ForEach(house.root.rep.reversed()) { mark in
                                HStack(alignment: .center, spacing: Spacing.s12) {
                                    VStack(alignment: .leading, spacing: Spacing.s4) {
                                        Text(mark.pass.title)
                                            .appFont(.headline)
                                            .foregroundStyle(DesignTokens.ink)
                                            .lineLimit(2)
                                            .truncationMode(.tail)
                                        DayText(daykey: mark.daykey, now: context.date)
                                        YearKind(year: mark.pass.year, kind: mark.pass.mediaKind)
                                    }
                                    Spacer(minLength: Spacing.s8)
                                    if let grade = mark.grade {
                                        Text(grade, format: .number.precision(.fractionLength(0)))
                                            .appFont(.title)
                                            .foregroundStyle(DesignTokens.ink)
                                    } else {
                                        Text("unknown")
                                            .appFont(.caption)
                                            .foregroundStyle(DesignTokens.muted)
                                    }
                                }
                                .padding(Spacing.s16)
                                .cardSurface()
                                .rowChrome()
                            }
                        }
                        .repertoryList()
                    }
                }
            }
        }
    }
}
