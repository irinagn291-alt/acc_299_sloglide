import SwiftUI

/// Intro, reset, and the contact page.
struct SettingsView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house
    @State private var confirmReset = false

    var body: some View {
        ScreenShell(title: "Settings", showsClose: showsClose, onClose: onClose) {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s24) {
                    SaveNote()
                    VStack(alignment: .leading, spacing: Spacing.s12) {
                        Text("On this device")
                            .appFont(.label)
                            .foregroundStyle(DesignTokens.muted)
                        Button {
                            house.reopenOnboarding()
                            onClose()
                        } label: {
                            Text("Show intro")
                        }
                        .buttonStyle(SoftButtonStyle(role: .secondary))
                        Button {
                            confirmReset = true
                        } label: {
                            Label("Reset all data", systemImage: "trash")
                        }
                        .buttonStyle(SoftButtonStyle(role: .destructive))
                    }
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
                .padding(Spacing.s20)
            }
            .confirmationDialog(
                "Reset all data?",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset all data", role: .destructive) {
                    Task {
                        await house.resetAllData()
                        onClose()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Deletes every finish and queued title on this device.")
            }
        }
    }
}
