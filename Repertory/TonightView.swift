import SwiftUI

/// Home is the lit slot. Stash does not finish a title.
/// Dismiss files it. The dither plate is the only custom-drawn surface.
struct TonightView: View {
    var onOpen: (AppRoute) -> Void

    @Environment(RepertoryHouse.self) private var house
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if house.root.hushIfIdle() != nil {
                vacant
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: Spacing.s24) {
                        SaveNote()
                        header
                        if let text = refusalText(house.lastMark) {
                            RefusalNote(text: text)
                        }
                        if house.root.marquee.litPass != nil {
                            dismissCard
                        } else if !house.root.foyer.passes.isEmpty {
                            lightCard(house.root.foyer.passes[0], prominent: true)
                        } else {
                            stashCard
                        }
                        if !house.root.foyer.passes.isEmpty, house.root.marquee.litPass != nil {
                            waiting
                        } else if house.root.foyer.passes.count > 1, house.root.marquee.isDark {
                            waitingTail
                        }
                        if !house.root.rep.isEmpty {
                            recent
                        }
                    }
                    .padding(.horizontal, Spacing.s20)
                    .padding(.top, Spacing.s16)
                    .padding(.bottom, Spacing.s32)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .screenBackground()
        .accessibilityIdentifier(house.phaseToken)
    }

    private var vacant: some View {
        FullEmpty(
            imageName: "rep_EmptyHome",
            title: "Nothing in the queue.",
            line: Hush.idle.message,
            actionTitle: stashTitle,
            action: stashOrDiscover
        )
    }

    private var header: some View {
        HStack(alignment: .top, spacing: Spacing.s12) {
            VStack(alignment: .leading, spacing: Spacing.s8) {
                Text(house.root.marquee.litPass == nil ? "Nothing showing" : "Now showing")
                    .appFont(.label)
                    .foregroundStyle(DesignTokens.muted)
                if let pass = house.root.marquee.litPass {
                    heroTitle(pass.title)
                    YearKind(year: pass.year, kind: pass.mediaKind)
                    Text("Log the film you just watched. Dismiss when the credits roll.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                } else if house.root.foyer.passes.isEmpty {
                    Text("Nothing showing. Stash a title to fill the queue.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Light one queued title, then dismiss it when the credits roll.")
                        .appFont(.body)
                        .foregroundStyle(DesignTokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            FinishedFigure(count: house.ribbonCount)
                .layoutPriority(1)
                .padding(.trailing, -Spacing.s12)
        }
    }

    private func heroTitle(_ title: String) -> some View {
        ViewThatFits(in: .horizontal) {
            Text(title)
                .appFont(dynamicTypeSize.isAccessibilitySize ? .title : .display)
                .lineLimit(2)
            Text(title)
                .appFont(.title)
                .lineLimit(3)
        }
        .foregroundStyle(DesignTokens.ink)
        .truncationMode(.tail)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)
    }

    private var dismissCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            DitherPlate()
                .frame(height: Spacing.s48 * 2)
                .clipShape(RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                .clipped()
            Button {
                house.dismiss()
            } label: {
                Text("Dismiss")
            }
            .buttonStyle(SoftButtonStyle(role: .primary))
            .disabled(house.showsGrade || house.root.marquee.litPass == nil)
        }
        .padding(Spacing.s16)
        .cardSurface()
    }

    private var stashCard: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text(stashTitle)
                .appFont(.headline)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button(action: stashOrDiscover) {
                Text(stashTitle)
            }
            .buttonStyle(SoftButtonStyle(role: .primary))
        }
        .padding(Spacing.s16)
        .cardSurface()
    }

    private var waiting: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Waiting")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
            ForEach(Array(house.root.foyer.passes.enumerated()), id: \.element.id) { index, pass in
                lightCard(pass, prominent: index == 0)
            }
            Button {
                onOpen(.queue)
            } label: {
                Text("Open queue")
            }
            .buttonStyle(SoftButtonStyle(role: .secondary))
        }
    }

    private var waitingTail: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Also waiting")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
            ForEach(house.root.foyer.passes.dropFirst()) { pass in
                lightCard(pass, prominent: false)
            }
        }
    }

    private func lightCard(_ pass: Pass, prominent: Bool) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(pass.title)
                .appFont(prominent ? .title : .headline)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
            YearKind(year: pass.year, kind: pass.mediaKind)
            Button {
                house.light(passID: pass.id)
            } label: {
                Text("Light")
            }
            .buttonStyle(SoftButtonStyle(role: prominent && house.root.marquee.isDark ? .primary : .secondary))
            .accessibilityLabel("Light \(pass.title)")
        }
        .padding(Spacing.s16)
        .cardSurface()
    }

    private var recent: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            Text("Recent")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
            TimelineView(.everyMinute) { context in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: Spacing.s12) {
                        ForEach(Array(house.root.rep.reversed().enumerated()), id: \.element.id) { index, mark in
                            recentCard(mark, wide: index == 0, now: context.date)
                        }
                    }
                    .padding(.vertical, Spacing.s16)
                }
            }
            Button {
                onOpen(.log)
            } label: {
                Text("Finish log")
            }
            .buttonStyle(SoftButtonStyle(role: .secondary))
        }
    }

    private func recentCard(_ mark: RepMark, wide: Bool, now: Date) -> some View {
        VStack(alignment: .leading, spacing: Spacing.s8) {
            Text(mark.pass.title)
                .appFont(wide ? .headline : .body)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
            DayText(daykey: mark.daykey, now: now)
            gradeReadout(mark.grade)
        }
        .padding(Spacing.s16)
        .frame(width: wide ? Spacing.s48 * 5 : Spacing.s48 * 4, alignment: .leading)
        .cardSurface()
    }

    @ViewBuilder
    private func gradeReadout(_ grade: Int?) -> some View {
        if let grade {
            Text(grade, format: .number.precision(.fractionLength(0)))
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
        } else {
            Text("unknown")
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
        }
    }

    private var stashTitle: String {
        if let title = LocalShelf.suggestion(in: house.root, now: Date())?.title {
            return "Stash \(title)"
        }
        return "Discover titles"
    }

    private func stashOrDiscover() {
        if let pass = LocalShelf.suggestion(in: house.root, now: Date()) {
            house.stash(pass)
        } else {
            onOpen(.discover)
        }
    }
}

/// Dot plate for the home slot only. No other screen draws with Canvas.
private struct DitherPlate: View {
    var body: some View {
        Canvas { context, size in
            let step = Spacing.s8
            let dot = Spacing.s4
            var row = 0
            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = row.isMultiple(of: 2) ? 0 : Spacing.s4
                while x < size.width {
                    let rect = CGRect(x: x, y: y, width: dot, height: dot)
                    context.fill(
                        Path(roundedRect: rect, cornerRadius: Radius.chip),
                        with: .color(DesignTokens.accent)
                    )
                    x += step * 2
                }
                y += step
                row += 1
            }
        }
        .background(DesignTokens.surface)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}
