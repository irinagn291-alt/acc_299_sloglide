import Charts
import SwiftUI

/// Saved grades only. Ungraded finishes stay out of the bars.
struct GoalsView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house

    var body: some View {
        ScreenShell(title: "Grades", showsClose: showsClose, onClose: onClose) {
            Group {
                if house.rollup.finishedCount == 0 {
                    FullEmpty(
                        imageName: "rep_TwistHero",
                        title: "No saved grades yet.",
                        line: "Dismiss a showing title, then save a whole grade from 1 to 5.",
                        actionTitle: showsClose ? "Close" : "Back to tonight",
                        action: onClose
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.s24) {
                            Text(house.rollup.finishedCount, format: .number.precision(.fractionLength(0)))
                                .appFont(.display)
                                .foregroundStyle(DesignTokens.ink)
                                .contentTransition(.numericText(value: Double(house.rollup.finishedCount)))
                            GradeRollupChart(rollup: house.rollup)
                            HStack(spacing: Spacing.s8) {
                                ForEach(bars) { bar in
                                    VStack(spacing: Spacing.s4) {
                                        Text(bar.count, format: .number.precision(.fractionLength(0)))
                                            .appFont(.headline)
                                            .foregroundStyle(DesignTokens.ink)
                                        Text(bar.grade, format: .number.precision(.fractionLength(0)))
                                            .appFont(.caption)
                                            .foregroundStyle(DesignTokens.muted)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: Spacing.s48)
                                }
                            }
                            .padding(Spacing.s12)
                            .cardSurface()
                        }
                        .padding(Spacing.s20)
                    }
                }
            }
        }
    }

    private var bars: [GradeBar] {
        (1...5).map { grade in
            GradeBar(grade: grade, count: house.rollup.countsByGrade[grade] ?? 0)
        }
    }
}

struct GradeRollupChart: View {
    var rollup: GradeRollup
    @ScaledMetric(relativeTo: .body) private var chartHeight: CGFloat = 240

    private var bars: [GradeBar] {
        (1...5).map { grade in
            GradeBar(grade: grade, count: rollup.countsByGrade[grade] ?? 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Saved grades")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
            Chart(bars) { bar in
                BarMark(
                    x: .value("Grade", bar.grade),
                    y: .value("Count", bar.count)
                )
                .foregroundStyle(DesignTokens.accent)
                .accessibilityLabel("Grade")
                .accessibilityValue(Text(bar.count, format: .number.precision(.fractionLength(0))))
            }
            .chartYScale(domain: 0...max(1, bars.map(\.count).max() ?? 1))
            .chartXAxis {
                AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                    AxisValueLabel {
                        if let grade = value.as(Int.self) {
                            Text(grade, format: .number.precision(.fractionLength(0)))
                                .appFont(.caption)
                                .foregroundStyle(DesignTokens.muted)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine().foregroundStyle(DesignTokens.muted)
                    AxisValueLabel {
                        if let count = value.as(Int.self) {
                            Text(count, format: .number.precision(.fractionLength(0)))
                                .appFont(.caption)
                                .foregroundStyle(DesignTokens.muted)
                        }
                    }
                }
            }
            .frame(minHeight: chartHeight, maxHeight: chartHeight)
            Text("Saved grades only.")
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(Spacing.s16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .accessibilityElement(children: .contain)
    }
}

struct GradeBar: Identifiable {
    var grade: Int
    var count: Int
    var id: Int { grade }
}
