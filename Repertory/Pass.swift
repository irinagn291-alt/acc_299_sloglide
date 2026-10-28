import Foundation

/// A stashed title. Identity is the stable `id`, not a row index and not the
/// catalog number. Stash creates one of these and leaves the marquee alone.
struct Pass: Codable, Equatable, Sendable, Identifiable {
    enum MediaKind: String, Codable, Equatable, Sendable {
        case movie
        case series
    }

    var id: UUID
    var tmdbID: Int
    var mediaKind: MediaKind
    var title: String
    var year: Int?
    var posterPath: String?
    var stashedAt: Date

    init(
        id: UUID = UUID(),
        tmdbID: Int,
        mediaKind: MediaKind,
        title: String,
        year: Int?,
        posterPath: String?,
        stashedAt: Date
    ) {
        self.id = id
        self.tmdbID = tmdbID
        self.mediaKind = mediaKind
        self.title = title
        self.year = year
        self.posterPath = posterPath
        self.stashedAt = stashedAt
    }
}
