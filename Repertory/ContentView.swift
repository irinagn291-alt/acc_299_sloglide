import SwiftUI

/// Root frame. Reads `ReviewLaunch.screen` once, after the intro is done,
/// and opens that screen. Today stays on the home slot.
struct ContentView: View {
    @Environment(RepertoryHouse.self) private var house
    @State private var didReadReview = false
    @State private var reviewScreen: String?
    @State private var route: AppRoute?
    @State private var gradeOpen = false
    @State private var commitPulse = 0

    var body: some View {
        stage
            .preferredColorScheme(.dark)
            .onAppear(perform: captureReviewIfReady)
            .onChange(of: house.isReady) { _, _ in
                captureReviewIfReady()
            }
            .onChange(of: house.root.onboardingComplete) { _, _ in
                captureReviewIfReady()
            }
            .onChange(of: house.showsGrade) { _, show in
                if gradeOpen != show {
                    gradeOpen = show
                }
            }
            .onChange(of: house.lastMark) { _, mark in
                if case .graded = mark {
                    commitPulse += 1
                }
            }
            .sensoryFeedback(.success, trigger: commitPulse)
            .sheet(isPresented: $gradeOpen, onDismiss: commitGradeIfNeeded) {
                GradeSheet {
                    house.confirmGrade()
                    gradeOpen = false
                }
            }
            .sheet(item: $route) { route in
                routed(route, showsClose: true)
            }
    }

    @ViewBuilder
    private var stage: some View {
        if !house.isReady {
            BootSplash()
        } else if !house.root.onboardingComplete {
            OnboardingView()
        } else if let reviewScreen, let cover = AppRoute(rawValue: reviewScreen) {
            routed(cover, showsClose: false)
                .accessibilityIdentifier(reviewScreen)
        } else {
            home
                .accessibilityIdentifier(reviewScreen ?? "today")
        }
    }

    private var home: some View {
        NavigationStack {
            TonightView { route = $0 }
                .navigationTitle("Tonight")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(DesignTokens.bg, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .tint(DesignTokens.ink)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        coverButton("Discover", systemImage: "magnifyingglass", route: .discover)
                        coverButton("Queue", systemImage: "list.bullet", route: .queue)
                        coverButton("Profile", systemImage: "person", route: .profile)
                    }
                }
        }
    }

    private func coverButton(_ title: String, systemImage: String, route: AppRoute) -> some View {
        Button {
            self.route = route
        } label: {
            Image(systemName: systemImage)
                .appFont(.headline)
        }
        .buttonStyle(IconButtonStyle())
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private func routed(_ route: AppRoute, showsClose: Bool) -> some View {
        switch route {
        case .discover:
            DiscoverView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .queue:
            QueueView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .seen:
            SeenView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .profile:
            ProfileView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .settings:
            SettingsView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .twist:
            TwistScreen(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .log:
            FinishLogView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .goals:
            GoalsView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .repmarks:
            RepMarksView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        case .peel:
            PeelView(showsClose: showsClose, onClose: { dismissRoute(showsClose) })
        }
    }

    private func dismissRoute(_ showsClose: Bool) {
        if showsClose {
            route = nil
        }
    }

    private func captureReviewIfReady() {
        guard !didReadReview else { return }
        guard house.isReady, house.root.onboardingComplete else { return }
        didReadReview = true
        reviewScreen = ReviewLaunch.screen
    }

    private func commitGradeIfNeeded() {
        if house.showsGrade {
            house.confirmGrade()
        }
    }
}

private struct BootSplash: View {
    var body: some View {
        ZStack {
            DesignTokens.bg
            Image("rep_Splash")
                .resizable()
                .scaledToFill()
                .clipped()
                .accessibilityHidden(true)
        }
        .ignoresSafeArea()
        .accessibilityLabel("Loading")
    }
}

#Preview {
    ContentView()
        .environment(RepertoryHouse(seedDemo: false))
}
