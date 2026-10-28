import SwiftUI

/// Every finish as the day it was filed, with the saved grade in words.
struct RepMarksView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house
    @State private var focus: UUID?

    var body: some View {
        ScreenShell(title: "Day marks", showsClose: showsClose, onClose: onClose) {
            Group {
                if house.root.rep.isEmpty {
                    FullEmpty(
                        imageName: "rep_EmptyHome",
                        title: "No day marks yet.",
                        line: "Dismiss a showing title and the day is filed here.",
                        actionTitle: showsClose ? "Close" : "Back to tonight",
                        action: onClose
                    )
                } else {
                    TimelineView(.everyMinute) { context in
                        VStack(alignment: .leading, spacing: Spacing.s16) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: Spacing.s16) {
                                    Text("The day you finished each film, and the grade you saved.")
                                        .appFont(.body)
                                        .foregroundStyle(DesignTokens.ink)
                                        .fixedSize(horizontal: false, vertical: true)
                                    ForEach(marks) { mark in
                                        dayButton(mark, now: context.date)
                                    }
                                }
                                .padding(.bottom, Spacing.s8)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Button(action: onClose) {
                                Text(showsClose ? "Close" : "Back to tonight")
                            }
                            .buttonStyle(SoftButtonStyle(role: .primary))
                        }
                        .padding(.horizontal, Spacing.s20)
                        .padding(.top, Spacing.s16)
                        .padding(.bottom, Spacing.s16)
                    }
                }
            }
        }
    }

    private var marks: [RepMark] {
        house.root.rep.reversed()
    }

    private var focusID: UUID? {
        if let focus, marks.contains(where: { $0.id == focus }) {
            return focus
        }
        return marks.first?.id
    }

    private func dayButton(_ mark: RepMark, now: Date) -> some View {
        let selected = mark.id == focusID
        return Button {
            focus = mark.id
        } label: {
            VStack(alignment: .leading, spacing: Spacing.s8) {
                Text("Finished")
                    .appFont(.label)
                    .foregroundStyle(DesignTokens.muted)
                Text(finishedDay(mark.daykey, now: now))
                    .appFont(.title)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                Text(mark.pass.title)
                    .appFont(.headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                YearKind(year: mark.pass.year, kind: mark.pass.mediaKind)
                Text(gradeWords(mark.grade))
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(selected ? "Showing this day" : "Show this day")
                    .appFont(.headline)
                    .foregroundStyle(DesignTokens.ink)
            }
            .frame(maxWidth: .infinity, minHeight: Spacing.s48, alignment: .leading)
            .padding(Spacing.s16)
            .contentShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        }
        .buttonStyle(.plain)
        .cardSurface()
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(accessibilityLine(mark, now: now, selected: selected))
    }

    private func finishedDay(_ daykey: Int, now: Date) -> String {
        let words = DayLabel.words(for: daykey, now: now)
        if words == "Today" || words == "unknown" {
            return words
        }
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = Calendar.current.date(from: parts) else { return words }
        return date.formatted(.dateTime.month(.wide).day().year())
    }

    private func gradeWords(_ grade: Int?) -> String {
        guard let grade, (1...5).contains(grade) else { return "Grade not saved" }
        return "Grade \(grade) of 5"
    }

    private func accessibilityLine(_ mark: RepMark, now: Date, selected: Bool) -> String {
        let day = finishedDay(mark.daykey, now: now)
        let showing = selected ? "Showing this day" : "Show this day"
        return "Finished \(day). \(mark.pass.title). \(gradeWords(mark.grade)). \(showing)"
    }
}
