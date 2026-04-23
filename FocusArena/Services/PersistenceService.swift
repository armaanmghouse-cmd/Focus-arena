import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private let fileManager = FileManager.default

    private var documentsURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func url(for filename: String) -> URL {
        documentsURL.appendingPathComponent(filename)
    }

    func load<T: Decodable>(_ type: T.Type, from filename: String, fallback: T) -> T {
        let fileURL = url(for: filename)
        guard fileManager.fileExists(atPath: fileURL.path) else { return fallback }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            return fallback
        }
    }

    func save<T: Encodable>(_ value: T, to filename: String) {
        let fileURL = url(for: filename)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(value)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            #if DEBUG
            print("Persistence write failed for \(filename): \(error)")
            #endif
        }
    }
}
