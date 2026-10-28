import SwiftUI

/// Why the home verb is dismiss, not a reorder of titles already seen.
struct TwistScreen: View {
    var showsClose: Bool
    var onClose: () -> Void

    @ScaledMetric(relativeTo: .largeTitle) private var artHeight: CGFloat = 220

    var body: some View {
        ScreenShell(title: "Finishing", showsClose: showsClose, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    Image("rep_TwistHero")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: artHeight)
                        .accessibilityHidden(true)
                    Text("Light, then dismiss.")
                        .appFont(.title)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Stash only fills the queue. Light puts one title on the home slot. Dismiss files it and clears the slot.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(alignment: .leading, spacing: Spacing.s8) {
                        Text("Dismiss")
                            .appFont(.headline)
                            .foregroundStyle(DesignTokens.accent)
                        Text("That is the finish. A second light waits until the slot is clear. Undo puts the last finish back in the queue.")
                            .appFont(.body)
                            .foregroundStyle(DesignTokens.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(Spacing.s16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cardSurface()
                }
                .padding(Spacing.s20)
            }
        }
    }
}
