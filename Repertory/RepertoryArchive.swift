import Foundation

/// Disk projection of the in-memory root. Writes are atomic. A corrupt file is
/// kept aside, then the previous backup is tried, then an empty house.
/// The main actor never calls these methods directly. The house awaits them.
actor RepertoryArchive {
    static let storageKey = "rep.chart.v1"

    struct LoadResult: Sendable {
        var root: RepertoryRoot
        var note: String?
        var data: Data?
    }

    let directory: URL
    private let fileURL: URL
    private let backupURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(directory: URL) {
        self.directory = directory
        fileURL = directory.appendingPathComponent("repertory.json")
        backupURL = directory.appendingPathComponent("repertory.json.backup")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    static var live: RepertoryArchive {
        RepertoryArchive(directory: supportDirectory())
    }

    func load() -> LoadResult {
        ensureDirectory()
        if let data = read(fileURL), let root = decode(data) {
            return LoadResult(root: root, note: nil, data: data)
        }
        if fileExists(fileURL) {
            quarantine(fileURL)
        }
        if let data = read(backupURL), let root = decode(data) {
            return LoadResult(
                root: root,
                note: "The last save was unreadable. Restored the previous copy.",
                data: data
            )
        }
        return LoadResult(
            root: .empty,
            note: fileExists(backupURL) || quarantineExists()
                ? "Saved repertory could not be read. Started from an empty house."
                : nil,
            data: nil
        )
    }

    func save(_ root: RepertoryRoot) throws -> Data {
        ensureDirectory()
        let data = try encoder.encode(root)
        let temp = directory.appendingPathComponent("repertory-\(UUID().uuidString).json")
        try data.write(to: temp, options: .atomic)
        if fileExists(fileURL) {
            if fileExists(backupURL) {
                try FileManager.default.removeItem(at: backupURL)
            }
            try FileManager.default.copyItem(at: fileURL, to: backupURL)
            _ = try FileManager.default.replaceItemAt(fileURL, withItemAt: temp)
        } else {
            try FileManager.default.moveItem(at: temp, to: fileURL)
        }
        return data
    }

    func reset() throws {
        for url in [fileURL, backupURL, quarantineURL] where fileExists(url) {
            try FileManager.default.removeItem(at: url)
        }
    }

    private func decode(_ data: Data) -> RepertoryRoot? {
        try? decoder.decode(RepertoryRoot.self, from: data)
    }

    private func read(_ url: URL) -> Data? {
        guard fileExists(url) else { return nil }
        return try? Data(contentsOf: url)
    }

    private func ensureDirectory() {
        do {
            try FileManager.default.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        } catch {
            return
        }
    }

    private var quarantineURL: URL {
        directory.appendingPathComponent("repertory.json.corrupt")
    }

    private func quarantineExists() -> Bool {
        fileExists(quarantineURL)
    }

    private func quarantine(_ url: URL) {
        let destination = quarantineURL
        do {
            if fileExists(destination) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: url, to: destination)
        } catch {
            return
        }
    }

    private func fileExists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    private static func supportDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let root = base ?? FileManager.default.temporaryDirectory
        return root.appendingPathComponent("Sloglide", isDirectory: true)
    }
}
