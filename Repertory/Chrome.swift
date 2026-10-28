import SwiftUI

/// Spacing, type, radius, and elevation for every screen.
/// Colours stay in `DesignTokens`. One radius pair, one shadow, one spring.

enum Spacing {
    static let s4: CGFloat = 4
    static let s8: CGFloat = 8
    static let s12: CGFloat = 12
    static let s16: CGFloat = 16
    static let s20: CGFloat = 20
    static let s24: CGFloat = 24
    static let s32: CGFloat = 32
    static let s40: CGFloat = 40
    static let s48: CGFloat = 48
}

enum Radius {
    static let card: CGFloat = 16
    static let chip: CGFloat = 10
}

enum Elevation {
    static let hairline: CGFloat = 1
    static let shadow = Color.black.opacity(0.45)
}

enum Motion {
    /// The one spring: grade save and the finished count.
    static let commit = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let ease = Animation.easeOut(duration: 0.22)
}

enum TypeStyle {
    case display
    case title
    case headline
    case body
    case label
    case caption

    func font() -> Font {
        switch self {
        case .display:
            Font.custom(DesignTokens.fontFamily, size: 40, relativeTo: .largeTitle).weight(.bold)
        case .title:
            Font.custom(DesignTokens.fontFamily, size: 28, relativeTo: .title).weight(.bold)
        case .headline:
            Font.custom(DesignTokens.fontFamily, size: 20, relativeTo: .headline).weight(.medium)
        case .body:
            Font.custom(DesignTokens.fontFamily, size: 17, relativeTo: .body).weight(.regular)
        case .label:
            Font.custom(DesignTokens.fontFamily, size: 13, relativeTo: .caption).weight(.medium)
        case .caption:
            Font.custom(DesignTokens.fontFamily, size: 12, relativeTo: .caption2).weight(.regular)
        }
    }
}

enum AppRoute: String, Identifiable {
    case discover
    case queue
    case seen
    case profile
    case settings
    case twist
    case log
    case goals
    case repmarks
    case peel

    var id: String { rawValue }
}

struct AppFont: ViewModifier {
    var style: TypeStyle

    @ViewBuilder
    func body(content: Content) -> some View {
        switch style {
        case .display, .title:
            content.font(style.font()).tracking(-0.3)
        case .label:
            content.font(style.font()).tracking(1.2).textCase(.uppercase)
        case .headline, .body, .caption:
            content.font(style.font())
        }
    }
}

struct CardSurface: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(DesignTokens.muted, lineWidth: Elevation.hairline)
            )
            .compositingGroup()
            .shadow(color: Elevation.shadow, radius: Spacing.s16, x: 0, y: Spacing.s8)
    }
}

extension View {
    func appFont(_ style: TypeStyle) -> some View {
        modifier(AppFont(style: style))
    }

    func cardSurface() -> some View {
        modifier(CardSurface())
    }

    func screenBackground() -> some View {
        background(DesignTokens.bg.ignoresSafeArea())
    }

    func repertoryList() -> some View {
        self
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)
            .contentMargins(.bottom, Spacing.s32, for: .scrollContent)
            .background(DesignTokens.bg)
    }

    func rowChrome() -> some View {
        self
            .listRowInsets(EdgeInsets(top: Spacing.s8, leading: Spacing.s20, bottom: Spacing.s8, trailing: Spacing.s20))
            .listRowBackground(DesignTokens.bg)
            .listRowSeparator(.hidden)
    }
}

struct SoftButtonStyle: ButtonStyle {
    enum Role {
        case primary
        case secondary
        case destructive
    }

    var role: Role = .primary

    func makeBody(configuration: Configuration) -> some View {
        SoftButtonBody(role: role, configuration: configuration)
    }
}

private struct SoftButtonBody: View {
    var role: SoftButtonStyle.Role
    var configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .appFont(.headline)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: Spacing.s48)
            .padding(.horizontal, Spacing.s16)
            .background(background, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(border, lineWidth: Elevation.hairline)
            )
            .compositingGroup()
            .shadow(color: Elevation.shadow, radius: Spacing.s16, x: 0, y: Spacing.s8)
            .scaleEffect(configuration.isPressed && isEnabled && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.72 : 1)
            .animation(Motion.ease, value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }

    private var foreground: Color {
        if !isEnabled { return DesignTokens.muted }
        if role == .primary { return DesignTokens.bg }
        return DesignTokens.ink
    }

    private var background: Color {
        if !isEnabled || role != .primary { return DesignTokens.surface }
        return DesignTokens.accent
    }

    private var border: Color {
        if role == .primary && isEnabled { return DesignTokens.bg }
        return DesignTokens.muted
    }
}

struct ChipButtonStyle: ButtonStyle {
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        ChipButtonBody(prominent: prominent, configuration: configuration)
    }
}

private struct ChipButtonBody: View {
    var prominent: Bool
    var configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .appFont(.label)
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: Spacing.s48)
            .padding(.horizontal, Spacing.s12)
            .background(background, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                    .strokeBorder(DesignTokens.muted, lineWidth: Elevation.hairline)
            )
            .compositingGroup()
            .shadow(color: Elevation.shadow, radius: Spacing.s16, x: 0, y: Spacing.s8)
            .scaleEffect(configuration.isPressed && isEnabled && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.72 : 1)
            .animation(Motion.ease, value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
    }

    private var foreground: Color {
        if !isEnabled { return DesignTokens.muted }
        if prominent { return DesignTokens.bg }
        return DesignTokens.ink
    }

    private var background: Color {
        if prominent && isEnabled { return DesignTokens.accent }
        return DesignTokens.surface
    }
}

struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        RowButtonBody(configuration: configuration)
    }
}

private struct RowButtonBody: View {
    var configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed && isEnabled && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.72 : 1)
            .animation(Motion.ease, value: configuration.isPressed)
            .contentShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        IconButtonBody(configuration: configuration)
    }
}

private struct IconButtonBody: View {
    var configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        configuration.label
            .frame(minWidth: Spacing.s48, minHeight: Spacing.s48)
            .contentShape(Rectangle())
            .background(
                configuration.isPressed ? DesignTokens.surface : DesignTokens.bg,
                in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
            )
            .foregroundStyle(isEnabled ? DesignTokens.ink : DesignTokens.muted)
            .scaleEffect(configuration.isPressed && isEnabled && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed && reduceMotion ? 0.72 : 1)
            .animation(Motion.ease, value: configuration.isPressed)
    }
}

struct ScreenShell<Content: View>: View {
    var title: String
    var showsClose: Bool
    var onClose: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        NavigationStack {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .screenBackground()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(DesignTokens.bg, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .tint(DesignTokens.ink)
                .toolbar {
                    if showsClose {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close", action: onClose)
                                .frame(minWidth: Spacing.s48, minHeight: Spacing.s48)
                        }
                    }
                }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }
}

struct YearKind: View {
    var year: Int?
    var kind: Pass.MediaKind

    var body: some View {
        HStack(spacing: Spacing.s8) {
            if let year {
                Text(year, format: .number.grouping(.never))
            } else {
                Text("unknown")
            }
            Text(kind == .movie ? "Movie" : "Series")
        }
        .appFont(.caption)
        .foregroundStyle(DesignTokens.muted)
    }
}

struct DayText: View {
    var daykey: Int
    var now: Date

    var body: some View {
        Text(DayLabel.words(for: daykey, now: now))
            .appFont(.caption)
            .foregroundStyle(DesignTokens.muted)
    }
}

enum DayLabel {
    static func words(for daykey: Int, now: Date) -> String {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        guard year > 0, (1...12).contains(month), (1...31).contains(day) else { return "unknown" }
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        let calendar = Calendar.current
        guard let date = calendar.date(from: parts) else { return "unknown" }
        let start = calendar.startOfDay(for: now)
        if DayKey.yyyymmdd(start, calendar: calendar) == daykey {
            return "Today"
        }
        return date.formatted(.dateTime.month(.abbreviated).day().year())
    }
}

enum PosterURL {
    static func make(_ path: String?) -> URL? {
        guard let path, path.hasPrefix("/") else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }
}

struct TitlePlate: View {
    var title: String
    var path: String?

    var body: some View {
        ZStack {
            DesignTokens.surface
            if let url = PosterURL.make(path) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        monogram
                    }
                }
            } else {
                monogram
            }
        }
        .frame(width: Spacing.s40, height: Spacing.s48)
        .clipShape(RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
        .clipped()
        .accessibilityHidden(true)
    }

    private var monogram: some View {
        Text(String(title.prefix(1)))
            .appFont(.headline)
            .foregroundStyle(DesignTokens.ink)
    }
}

struct FinishedFigure: View {
    var count: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.s4) {
            countText
            Text("Finished")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
        }
        .padding(Spacing.s12)
        .cardSurface()
        .fixedSize()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Finished")
        .accessibilityValue(Text(count, format: .number.precision(.fractionLength(0))))
    }

    @ViewBuilder
    private var countText: some View {
        if reduceMotion {
            Text(count, format: .number.precision(.fractionLength(0)))
                .appFont(.display)
                .foregroundStyle(DesignTokens.ink)
        } else {
            Text(count, format: .number.precision(.fractionLength(0)))
                .appFont(.display)
                .foregroundStyle(DesignTokens.ink)
                .contentTransition(.numericText(value: Double(count)))
                .animation(Motion.commit, value: count)
        }
    }
}

struct FullEmpty: View {
    var imageName: String
    var title: String
    var line: String
    var actionTitle: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Spacer(minLength: Spacing.s16)
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(maxHeight: Spacing.s48 * 4)
                .accessibilityHidden(true)
            Text(title)
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.s16)
            Button(action: action) {
                Text(actionTitle)
            }
            .buttonStyle(SoftButtonStyle(role: .primary))
        }
        .padding(Spacing.s20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .screenBackground()
    }
}

struct RetryNotice: View {
    var title: String
    var line: String
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s16) {
            Spacer(minLength: Spacing.s16)
            Text(title)
                .appFont(.title)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(line)
                .appFont(.body)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: Spacing.s16)
            Button(action: action) {
                Label("Retry", systemImage: "arrow.clockwise")
            }
            .buttonStyle(SoftButtonStyle(role: .secondary))
        }
        .padding(Spacing.s20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct SaveNote: View {
    @Environment(RepertoryHouse.self) private var house

    var body: some View {
        if let note = house.loadNote {
            VStack(alignment: .leading, spacing: Spacing.s12) {
                Text(note)
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    Task { await house.retrySave() }
                } label: {
                    Label("Retry", systemImage: "arrow.clockwise")
                }
                .buttonStyle(SoftButtonStyle(role: .secondary))
            }
            .padding(Spacing.s16)
            .cardSurface()
        }
    }
}

func refusalText(_ mark: FoldMark?) -> String? {
    switch mark {
    case .empty(let item):
        item.message
    case .double(let item):
        item.message
    case .hush(let item):
        item.message
    default:
        nil
    }
}

struct RefusalNote: View {
    var text: String

    var body: some View {
        Text(text)
            .appFont(.body)
            .foregroundStyle(DesignTokens.ink)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.s16)
            .cardSurface()
    }
}

enum LocalShelf {
    static func make(now: Date) -> [Pass] {
        let rows: [(Int, Pass.MediaKind, String, Int)] = [
            (1001, .movie, "Rashomon", 1950),
            (1002, .movie, "Spirited Away", 2001),
            (1003, .series, "The Wire", 2002),
            (1004, .movie, "Paris, Texas", 1984),
            (1005, .movie, "Chungking Express", 1994),
            (1006, .movie, "Portrait of a Lady on Fire", 2019)
        ]
        return rows.map { id, kind, title, year in
            Pass(
                tmdbID: id,
                mediaKind: kind,
                title: title,
                year: year,
                posterPath: nil,
                stashedAt: now
            )
        }
    }

    static func suggestion(in root: RepertoryRoot, now: Date) -> Pass? {
        var used = Set(root.foyer.passes.map(\.tmdbID))
        used.formUnion(root.rep.map(\.pass.tmdbID))
        if let lit = root.marquee.litPass {
            used.insert(lit.tmdbID)
        }
        return make(now: now).first { !used.contains($0.tmdbID) }
    }
}
