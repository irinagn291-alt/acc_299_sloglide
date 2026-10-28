import SwiftUI

/// Three pages, then the home slot. Skip still marks the intro done.
struct OnboardingView: View {
    @Environment(RepertoryHouse.self) private var house
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0
    @ScaledMetric(relativeTo: .largeTitle) private var artHeight: CGFloat = 280

    private let pages: [Page] = [
        Page(
            image: "rep_Onboarding1",
            title: "One title at a time.",
            line: "Light it when you start watching."
        ),
        Page(
            image: "rep_Onboarding2",
            title: "Dismiss to log the finish.",
            line: "The queue does not count as watched."
        ),
        Page(
            image: "rep_Onboarding3",
            title: "Grades stay on this device.",
            line: "Undo the last finish if the title was wrong."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s16) {
                    HStack(spacing: Spacing.s8) {
                        Text(page + 1, format: .number.precision(.fractionLength(0)))
                        Text("of")
                        Text(pages.count, format: .number.precision(.fractionLength(0)))
                    }
                    .appFont(.label)
                    .foregroundStyle(DesignTokens.muted)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Page")
                    Image(pages[page].image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: artHeight)
                        .accessibilityHidden(true)
                    Text(pages[page].title)
                        .appFont(.display)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(pages[page].line)
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(Spacing.s20)
                .id(page)
            }
            VStack(spacing: Spacing.s12) {
                Button("Skip") {
                    house.completeOnboarding()
                }
                .buttonStyle(SoftButtonStyle(role: .secondary))
                Button(page == pages.count - 1 ? "Start" : "Next") {
                    advance()
                }
                .buttonStyle(SoftButtonStyle(role: .primary))
            }
            .padding(.horizontal, Spacing.s20)
            .padding(.bottom, Spacing.s20)
        }
        .screenBackground()
        .animation(reduceMotion ? Motion.ease : Motion.ease, value: page)
    }

    private func advance() {
        if page < pages.count - 1 {
            page += 1
        } else {
            house.completeOnboarding()
        }
    }
}

private struct Page {
    var image: String
    var title: String
    var line: String
}
