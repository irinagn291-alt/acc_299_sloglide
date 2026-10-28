import Foundation

/// Catalog lookup for movie and series search. DTOs match the JSON.
/// Domain passes are mapped afterwards. A changed query must cancel the
/// previous task before a new page is admitted.
struct TitleHitDTO: Decodable, Equatable, Sendable {
    var id: Int
    var title: String?
    var name: String?
    var releaseDate: String?
    var firstAirDate: String?
    var posterPath: String?
    var mediaType: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case posterPath = "poster_path"
        case mediaType = "media_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try FlexibleJSON.int(container, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDate)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        mediaType = try container.decodeIfPresent(String.self, forKey: .mediaType)
    }

    var displayTitle: String {
        let movie = title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !movie.isEmpty { return movie }
        return name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func makePass(kind: Pass.MediaKind, stashedAt: Date) -> Pass? {
        let name = displayTitle
        guard !name.isEmpty else { return nil }
        let resolved: Pass.MediaKind
        if mediaType == "tv" {
            resolved = .series
        } else if mediaType == "movie" {
            resolved = .movie
        } else {
            resolved = kind
        }
        let rawDate = resolved == .series ? (firstAirDate ?? releaseDate) : (releaseDate ?? firstAirDate)
        return Pass(
            tmdbID: id,
            mediaKind: resolved,
            title: name,
            year: TitleHitDTO.year(from: rawDate),
            posterPath: posterPath,
            stashedAt: stashedAt
        )
    }

    private static func year(from raw: String?) -> Int? {
        guard let raw, raw.count >= 4 else { return nil }
        return Int(raw.prefix(4))
    }
}

struct SearchEnvelopeDTO: Decodable, Equatable, Sendable {
    var page: Int
    var results: [TitleHitDTO]
    var totalPages: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        page = try FlexibleJSON.int(container, forKey: .page)
        results = try container.decodeIfPresent([TitleHitDTO].self, forKey: .results) ?? []
        totalPages = (try? FlexibleJSON.int(container, forKey: .totalPages)) ?? page
    }
}

enum FlexibleJSON {
    static func int<K: CodingKey>(_ container: KeyedDecodingContainer<K>, forKey key: K) throws -> Int {
        if let value = try? container.decode(Int.self, forKey: key) { return value }
        if let value = try? container.decode(Double.self, forKey: key) { return Int(value) }
        if let value = try? container.decode(String.self, forKey: key), let parsed = Int(value) {
            return parsed
        }
        throw DecodingError.dataCorruptedError(
            forKey: key,
            in: container,
            debugDescription: "Expected a number or a numeric string."
        )
    }
}

enum CatalogError: Error, Equatable {
    case missingCredential
    case notFound
    case transport
    case decoding
    case cancelled
}

struct TitleClient: Sendable {
    static let userAgent = "Sloglide/1.0 (iOS; +https://repertory-marquee.space)"
    static let timeout: TimeInterval = 15

    var apiKey: String
    var transport: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)

    func searchMovies(_ query: String, page: Int) async throws -> SearchEnvelopeDTO {
        try await search(path: "/3/search/movie", query: query, page: page)
    }

    func searchSeries(_ query: String, page: Int) async throws -> SearchEnvelopeDTO {
        try await search(path: "/3/search/tv", query: query, page: page)
    }

    private func search(path: String, query: String, page: Int) async throws -> SearchEnvelopeDTO {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return SearchEnvelopeDTO.empty
        }
        let data = try await load(path: path, queryItems: [
            URLQueryItem(name: "query", value: trimmed),
            URLQueryItem(name: "page", value: String(max(page, 1))),
            URLQueryItem(name: "include_adult", value: "false")
        ])
        return try decode(data)
    }

    private func load(path: String, queryItems: [URLQueryItem]) async throws -> Data {
        try Task.checkCancellation()
        let request = try makeRequest(path: path, queryItems: queryItems)
        do {
            return try await send(request)
        } catch is CancellationError {
            throw CatalogError.cancelled
        } catch let error as CatalogError {
            throw error
        } catch let error as URLError {
            if error.code == .cancelled { throw CatalogError.cancelled }
            do {
                return try await send(request)
            } catch is CancellationError {
                throw CatalogError.cancelled
            } catch let error as CatalogError {
                throw error
            } catch {
                throw CatalogError.transport
            }
        } catch {
            throw CatalogError.transport
        }
    }

    private func send(_ request: URLRequest) async throws -> Data {
        try Task.checkCancellation()
        let (data, response) = try await transport(request)
        if response.statusCode == 404 { throw CatalogError.notFound }
        guard (200...299).contains(response.statusCode) else { throw CatalogError.transport }
        return data
    }

    private func makeRequest(path: String, queryItems: [URLQueryItem]) throws -> URLRequest {
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else { throw CatalogError.missingCredential }
        guard var components = URLComponents(string: "https://api.themoviedb.org\(path)") else {
            throw CatalogError.transport
        }
        components.queryItems = queryItems + [URLQueryItem(name: "api_key", value: key)]
        guard let url = components.url else { throw CatalogError.transport }
        var request = URLRequest(url: url, timeoutInterval: Self.timeout)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private func decode(_ data: Data) throws -> SearchEnvelopeDTO {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        do {
            return try decoder.decode(SearchEnvelopeDTO.self, from: data)
        } catch {
            throw CatalogError.decoding
        }
    }
}

extension SearchEnvelopeDTO {
    static let empty = SearchEnvelopeDTO(page: 1, results: [], totalPages: 1)

    init(page: Int, results: [TitleHitDTO], totalPages: Int) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
    }
}

extension TitleHitDTO {
    init(
        id: Int,
        title: String?,
        name: String?,
        releaseDate: String?,
        firstAirDate: String?,
        posterPath: String?,
        mediaType: String?
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.releaseDate = releaseDate
        self.firstAirDate = firstAirDate
        self.posterPath = posterPath
        self.mediaType = mediaType
    }
}

/// Drops a stale search page when a newer query has already been issued.
enum SearchAdmission {
    static func admit(token: Int, current: Int, cancelled: Bool) -> Bool {
        !cancelled && token == current
    }
}

/// Poster and metadata cache. Lives in Caches and is excluded from backup.
actor PosterShelf {
    let directory: URL

    init(directory: URL) {
        self.directory = directory
    }

    func store(tmdbID: Int, payload: Data) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var folder = directory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try folder.setResourceValues(values)
        let url = directory.appendingPathComponent("\(tmdbID).json")
        try payload.write(to: url, options: .atomic)
    }

    func payload(tmdbID: Int) -> Data? {
        let url = directory.appendingPathComponent("\(tmdbID).json")
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return try? Data(contentsOf: url)
    }

    /// Every cached title payload. A later search can read these when the network fails.
    func payloads() -> [Data] {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return []
        }
        return urls.compactMap { url in
            guard url.pathExtension == "json" else { return nil }
            return try? Data(contentsOf: url)
        }
    }
}
