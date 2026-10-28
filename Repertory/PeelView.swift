import SwiftUI

/// Undo only the latest finish. The home slot is left alone.
struct PeelView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house
    @State private var confirm = false
    @ScaledMetric(relativeTo: .largeTitle) private var artHeight: CGFloat = 180

    var body: some View {
        ScreenShell(title: "Undo", showsClose: showsClose, onClose: onClose) {
            Group {
                if let last = house.root.rep.last {
                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.s24) {
                            Image("rep_EmptyFoyerArt")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: artHeight)
                                .accessibilityHidden(true)
                            Text("Latest finish")
                                .appFont(.label)
                                .foregroundStyle(DesignTokens.muted)
                            Text(last.pass.title)
                                .appFont(.display)
                                .foregroundStyle(DesignTokens.ink)
                                .lineLimit(3)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Undo puts it back in the queue. The home slot stays as it is.")
                                .appFont(.body)
                                .foregroundStyle(DesignTokens.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Button {
                                confirm = true
                            } label: {
                                Label("Undo last finish", systemImage: "arrow.uturn.backward")
                            }
                            .buttonStyle(SoftButtonStyle(role: .destructive))
                        }
                        .padding(Spacing.s20)
                    }
                    .confirmationDialog(
                        "Undo the last finish?",
                        isPresented: $confirm,
                        titleVisibility: .visible
                    ) {
                        Button("Undo last finish", role: .destructive) {
                            house.peel()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("It returns to the queue. The home slot stays as it is.")
                    }
                } else {
                    FullEmpty(
                        imageName: "rep_EmptyHome",
                        title: "Nothing to undo.",
                        line: "Dismiss a showing title first.",
                        actionTitle: showsClose ? "Close" : "Back to tonight",
                        action: onClose
                    )
                }
            }
        }
    }
}
