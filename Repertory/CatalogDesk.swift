import Foundation

/// Movie and series search. A new query cancels the previous page.
/// Offline, the local shelf still stashes a title.
@MainActor
@Observable
final class CatalogDesk {
    private(set) var hits: [TitleHitDTO] = []
    private(set) var page = 1
    private(set) var totalPages = 1
    private(set) var failure: CatalogError?
    private(set) var showSpinner = false
    private(set) var busy = false
    private(set) var didSettle = false
    private(set) var retryToken = 0

    private var generation = 0
    private let client: TitleClient
    private let shelf: PosterShelf

    init() {
        let key = ProcessInfo.processInfo.environment["TMDB_API_KEY"] ?? ""
        client = TitleClient(apiKey: key, transport: { request in
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw CatalogError.transport
            }
            return (data, http)
        })
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        shelf = PosterShelf(directory: caches.appendingPathComponent("rep-posters", isDirectory: true))
    }

    var canLoadMore: Bool {
        page < totalPages && failure == nil && !hits.isEmpty
    }

    func retry() {
        retryToken += 1
    }

    func load(query: String, kind: Pass.MediaKind, reset: Bool, debounce: Bool) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        generation += 1
        let token = generation
        if trimmed.isEmpty {
            hits = []
            failure = nil
            didSettle = false
            showSpinner = false
            busy = false
            page = 1
            totalPages = 1
            return
        }
        if reset {
            hits = []
            failure = nil
            didSettle = false
        }
        if debounce {
            do {
                try await Task.sleep(for: .milliseconds(300))
            } catch {
                return
            }
            guard token == generation, !Task.isCancelled else { return }
        }
        let requestedPage = reset ? 1 : page + 1
        busy = true
        let spin = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(150))
            guard !Task.isCancelled, token == generation else { return }
            showSpinner = true
        }
        defer {
            spin.cancel()
            if token == generation {
                showSpinner = false
                busy = false
            }
        }
        do {
            let envelope: SearchEnvelopeDTO
            switch kind {
            case .movie:
                envelope = try await client.searchMovies(trimmed, page: requestedPage)
            case .series:
                envelope = try await client.searchSeries(trimmed, page: requestedPage)
            }
            guard SearchAdmission.admit(token: token, current: generation, cancelled: Task.isCancelled) else {
                return
            }
            await remember(envelope.results)
            guard SearchAdmission.admit(token: token, current: generation, cancelled: Task.isCancelled) else {
                return
            }
            if reset {
                hits = envelope.results
            } else {
                hits.append(contentsOf: envelope.results)
            }
            page = envelope.page
            totalPages = max(envelope.totalPages, envelope.page)
            failure = nil
            didSettle = true
        } catch let error as CatalogError {
            guard token == generation else { return }
            if error == .cancelled { return }
            await restoreCachedHits(matching: trimmed)
            guard token == generation else { return }
            failure = error
            didSettle = true
        } catch is CancellationError {
            return
        } catch {
            guard token == generation else { return }
            await restoreCachedHits(matching: trimmed)
            guard token == generation else { return }
            failure = .transport
            didSettle = true
        }
    }

    private func remember(_ results: [TitleHitDTO]) async {
        for hit in results {
            guard let payload = HitCache.encode(hit) else { continue }
            try? await shelf.store(tmdbID: hit.id, payload: payload)
        }
    }

    private func restoreCachedHits(matching query: String) async {
        guard hits.isEmpty else { return }
        let payloads = await shelf.payloads()
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let decoded = payloads.compactMap { data in
            try? decoder.decode(TitleHitDTO.self, from: data)
        }
        let matched = decoded.filter { hit in
            trimmed.isEmpty || hit.displayTitle.range(of: trimmed, options: .caseInsensitive) != nil
        }
        if !matched.isEmpty {
            hits = matched
        }
    }
}

enum HitCache {
    static func encode(_ hit: TitleHitDTO) -> Data? {
        var object: [String: Any] = ["id": hit.id]
        if let title = hit.title { object["title"] = title }
        if let name = hit.name { object["name"] = name }
        if let releaseDate = hit.releaseDate { object["release_date"] = releaseDate }
        if let firstAirDate = hit.firstAirDate { object["first_air_date"] = firstAirDate }
        if let posterPath = hit.posterPath { object["poster_path"] = posterPath }
        if let mediaType = hit.mediaType { object["media_type"] = mediaType }
        return try? JSONSerialization.data(withJSONObject: object)
    }
}
