import SwiftUI

/// Search movies and series, then stash into the queue.
/// A failed lookup still leaves the on-device shelf.
struct DiscoverView: View {
    var showsClose: Bool
    var onClose: () -> Void

    @Environment(RepertoryHouse.self) private var house
    @State private var desk = CatalogDesk()
    @State private var query = ""
    @State private var manual = ""
    @State private var kind: Pass.MediaKind = .movie
    @FocusState private var focus: Field?

    private enum Field: Hashable {
        case query
        case manual
    }

    var body: some View {
        ScreenShell(title: "Discover", showsClose: showsClose, onClose: onClose) {
            VStack(alignment: .leading, spacing: Spacing.s12) {
                searchHeader
                List {
                    if let line = failureLine {
                        Section {
                            VStack(alignment: .leading, spacing: Spacing.s12) {
                                Text(line)
                                    .appFont(.body)
                                    .foregroundStyle(DesignTokens.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                                Text("Stash from the list or type a title.")
                                    .appFont(.caption)
                                    .foregroundStyle(DesignTokens.muted)
                                Button {
                                    desk.retry()
                                } label: {
                                    Label("Retry", systemImage: "arrow.clockwise")
                                }
                                .buttonStyle(SoftButtonStyle(role: .secondary))
                            }
                            .padding(Spacing.s16)
                            .cardSurface()
                            .rowChrome()
                        }
                    }
                    if showRedacted {
                        Section {
                            ForEach(["hold-a", "hold-b", "hold-c", "hold-d"], id: \.self) { _ in
                                CatalogRow(title: "Title", year: 2000, kind: kind, path: nil, prominent: false)
                                    .redacted(reason: .placeholder)
                                    .rowChrome()
                            }
                        }
                    } else if !desk.hits.isEmpty {
                        Section {
                            ForEach(desk.hits, id: \.id) { hit in
                                Button {
                                    stash(hit)
                                } label: {
                                    CatalogRow(
                                        title: hit.displayTitle,
                                        year: year(of: hit),
                                        kind: resolvedKind(hit),
                                        path: hit.posterPath,
                                        prominent: hit.id == desk.hits.first?.id
                                    )
                                }
                                .buttonStyle(RowButtonStyle())
                                .disabled(desk.busy)
                                .accessibilityLabel("Stash \(hit.displayTitle)")
                                .rowChrome()
                            }
                            if desk.canLoadMore {
                                Button {
                                    Task { await desk.load(query: query, kind: kind, reset: false, debounce: false) }
                                } label: {
                                    Text("More titles")
                                }
                                .buttonStyle(SoftButtonStyle(role: .secondary))
                                .disabled(desk.busy)
                                .rowChrome()
                            }
                        }
                    } else if trimmedQuery.isEmpty || desk.failure != nil || !desk.didSettle {
                        shelfSection
                    } else {
                        Section {
                            Text("No matches.")
                                .appFont(.title)
                                .foregroundStyle(DesignTokens.ink)
                                .frame(maxWidth: .infinity, minHeight: Spacing.s48 * 3, alignment: .leading)
                                .rowChrome()
                        }
                    }
                    manualSection
                }
                .repertoryList()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Close") { focus = nil }
                        .frame(minWidth: Spacing.s48, minHeight: Spacing.s48)
                }
            }
        }
        .task(id: searchKey) {
            await desk.load(query: query, kind: kind, reset: true, debounce: true)
        }
    }

    private var searchKey: String {
        "\(kind.rawValue)|\(query)|\(desk.retryToken)"
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var showRedacted: Bool {
        desk.showSpinner && desk.hits.isEmpty && !trimmedQuery.isEmpty
    }

    private var failureLine: String? {
        switch desk.failure {
        case .missingCredential:
            "Search is offline."
        case .notFound:
            "No title matched."
        case .transport:
            "Search failed."
        case .decoding:
            "Search could not be read."
        case .cancelled, .none:
            nil
        }
    }

    private var searchHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.s12) {
            TextField(kind == .movie ? "Search movies" : "Search series", text: $query)
                .appFont(.body)
                .foregroundStyle(DesignTokens.ink)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused($focus, equals: .query)
                .onSubmit { focus = .manual }
                .padding(.horizontal, Spacing.s16)
                .frame(minHeight: Spacing.s48)
                .background(DesignTokens.surface, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                        .strokeBorder(focus == .query ? DesignTokens.ink : DesignTokens.muted, lineWidth: Elevation.hairline)
                )
            HStack(spacing: Spacing.s12) {
                kindButton(.movie, title: "Movie")
                kindButton(.series, title: "Series")
            }
            if desk.showSpinner {
                ProgressView()
                    .tint(DesignTokens.ink)
                    .frame(maxWidth: .infinity, minHeight: Spacing.s48)
            }
        }
        .padding(.horizontal, Spacing.s20)
        .padding(.top, Spacing.s16)
    }

    private func kindButton(_ value: Pass.MediaKind, title: String) -> some View {
        Button {
            kind = value
        } label: {
            Text(title)
        }
        .buttonStyle(ChipButtonStyle(prominent: kind == value))
        .accessibilityAddTraits(kind == value ? [.isSelected] : [])
    }

    private var shelfSection: some View {
        Section {
            Text("On this device")
                .appFont(.label)
                .foregroundStyle(DesignTokens.muted)
                .rowChrome()
            ForEach(LocalShelf.make(now: Date()), id: \.tmdbID) { pass in
                Button {
                    house.stash(
                        Pass(
                            tmdbID: pass.tmdbID,
                            mediaKind: pass.mediaKind,
                            title: pass.title,
                            year: pass.year,
                            posterPath: pass.posterPath,
                            stashedAt: Date()
                        )
                    )
                    focus = nil
                } label: {
                    CatalogRow(
                        title: pass.title,
                        year: pass.year,
                        kind: pass.mediaKind,
                        path: pass.posterPath,
                        prominent: pass.tmdbID == LocalShelf.make(now: Date()).first?.tmdbID
                    )
                }
                .buttonStyle(RowButtonStyle())
                .accessibilityLabel("Stash \(pass.title)")
                .rowChrome()
            }
        }
    }

    private var manualSection: some View {
        Section {
            VStack(alignment: .leading, spacing: Spacing.s12) {
                Text("Type a title")
                    .appFont(.label)
                    .foregroundStyle(DesignTokens.muted)
                TextField("Title", text: $manual)
                    .appFont(.body)
                    .foregroundStyle(DesignTokens.ink)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($focus, equals: .manual)
                    .onSubmit { stashManual() }
                    .padding(.horizontal, Spacing.s16)
                    .frame(minHeight: Spacing.s48)
                    .background(DesignTokens.bg, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                            .strokeBorder(focus == .manual ? DesignTokens.ink : DesignTokens.muted, lineWidth: Elevation.hairline)
                    )
                Button(action: stashManual) {
                    Text("Stash")
                }
                .buttonStyle(SoftButtonStyle(role: .primary))
                .disabled(manual.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(Spacing.s16)
            .cardSurface()
            .rowChrome()
        }
    }

    private func stash(_ hit: TitleHitDTO) {
        guard let pass = hit.makePass(kind: kind, stashedAt: Date()) else { return }
        house.stash(pass)
        focus = nil
    }

    private func stashManual() {
        let title = manual.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        house.stash(
            Pass(
                tmdbID: 0,
                mediaKind: kind,
                title: title,
                year: nil,
                posterPath: nil,
                stashedAt: Date()
            )
        )
        manual = ""
        focus = nil
    }

    private func resolvedKind(_ hit: TitleHitDTO) -> Pass.MediaKind {
        if hit.mediaType == "tv" { return .series }
        if hit.mediaType == "movie" { return .movie }
        return kind
    }

    private func year(of hit: TitleHitDTO) -> Int? {
        let raw = resolvedKind(hit) == .series ? (hit.firstAirDate ?? hit.releaseDate) : (hit.releaseDate ?? hit.firstAirDate)
        guard let raw, raw.count >= 4, let year = Int(raw.prefix(4)) else { return nil }
        return year
    }
}

private struct CatalogRow: View {
    var title: String
    var year: Int?
    var kind: Pass.MediaKind
    var path: String?
    var prominent: Bool

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.s12) {
            TitlePlate(title: title, path: path)
            VStack(alignment: .leading, spacing: Spacing.s4) {
                Text(title.isEmpty ? "unknown" : title)
                    .appFont(prominent ? .title : .headline)
                    .foregroundStyle(DesignTokens.ink)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                YearKind(year: year, kind: kind)
            }
            Spacer(minLength: Spacing.s8)
            Text("Stash")
                .appFont(.label)
                .foregroundStyle(prominent ? DesignTokens.bg : DesignTokens.ink)
                .frame(minWidth: Spacing.s48, minHeight: Spacing.s48)
                .padding(.horizontal, Spacing.s12)
                .background(
                    prominent ? DesignTokens.accent : DesignTokens.surface,
                    in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                )
        }
        .padding(Spacing.s16)
        .cardSurface()
    }
}
