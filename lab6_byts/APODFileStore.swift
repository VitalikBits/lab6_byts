import Foundation

struct APODFileStore {
    private let fileManager = FileManager.default

    private func cacheURL() throws -> URL {
        let documents = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return documents.appendingPathComponent("apod-cache.json")
    }

    func save(_ entries: [APODEntry]) throws {
        let url = try cacheURL()
        let data = try JSONEncoder().encode(entries)

        // Замінюємо попередній файл лише після успішного запису.
        try data.write(to: url, options: .atomic)
    }

    func load() throws -> [APODEntry]? {
        let url = try cacheURL()

        // Під час першого запуску кешу ще може не бути.
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([APODEntry].self, from: data)
    }
}
