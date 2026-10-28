import SwiftUI

/// Whole grades 1 through 5. The finger updates the draft. Save commits it.
struct GradeSheet: View {
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house
    @GestureState private var dragFraction: Double?
    @State private var trackWidth: CGFloat = 1

    var body: some View {
        ScreenShell(title: "Grade", showsClose: true, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    Text("Drag across the line. It snaps to a whole grade.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(shownGrade, format: .number.precision(.fractionLength(0)))
                        .appFont(.display)
                        .foregroundStyle(DesignTokens.ink)
                        .contentTransition(.numericText(value: Double(shownGrade)))
                        .accessibilityHidden(true)
                    track
                    HStack(spacing: Spacing.s8) {
                        ForEach(1...5, id: \.self) { grade in
                            Text(grade, format: .number.precision(.fractionLength(0)))
                                .appFont(grade == shownGrade ? .headline : .caption)
                                .foregroundStyle(grade == shownGrade ? DesignTokens.ink : DesignTokens.muted)
                                .frame(maxWidth: .infinity, minHeight: Spacing.s48)
                                .background(
                                    DesignTokens.surface,
                                    in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                                        .strokeBorder(
                                            grade == shownGrade ? DesignTokens.ink : DesignTokens.muted,
                                            lineWidth: Elevation.hairline
                                        )
                                )
                        }
                    }
                    Button(action: onClose) {
                        Text("Save")
                    }
                    .buttonStyle(SoftButtonStyle(role: .primary))
                }
                .padding(Spacing.s20)
            }
        }
    }

    private var shownGrade: Int {
        if let dragFraction {
            return GradePips.grade(forFraction: dragFraction)
        }
        return house.gradeDraft ?? 3
    }

    private var track: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                .fill(DesignTokens.muted)
                .frame(height: Spacing.s12)
            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                .fill(DesignTokens.accent)
                .frame(width: max(Spacing.s12, trackWidth * CGFloat(shownGrade) / 5), height: Spacing.s12)
        }
        .frame(maxWidth: .infinity, minHeight: Spacing.s48)
        .contentShape(Rectangle())
        .background {
            GeometryReader { proxy in
                DesignTokens.bg
                    .preference(key: TrackWidthKey.self, value: proxy.size.width)
            }
        }
        .onPreferenceChange(TrackWidthKey.self) { trackWidth = max($0, 1) }
        .gesture(drag)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Grade")
        .accessibilityValue(Text(shownGrade, format: .number.precision(.fractionLength(0))))
        .accessibilityAdjustableAction { direction in
            let delta: Int
            switch direction {
            case .increment:
                delta = 1
            case .decrement:
                delta = -1
            default:
                delta = 0
            }
            house.setGradeDraft(GradePips.step(shownGrade, by: delta))
        }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragFraction) { value, state, _ in
                let width = max(trackWidth, 1)
                let x = min(max(0, value.location.x), width)
                state = Double(x / width)
            }
            .onEnded { value in
                let width = max(trackWidth, 1)
                let x = min(max(0, value.location.x), width)
                house.setGradeDraft(GradePips.grade(forFraction: Double(x / width)))
            }
    }
}

private struct TrackWidthKey: PreferenceKey {
    static let defaultValue: CGFloat = 1
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
