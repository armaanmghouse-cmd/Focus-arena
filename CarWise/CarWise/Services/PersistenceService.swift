import Foundation

/// JSON-encoded persistence using UserDefaults. Simple, sync, good enough for MVP.
/// Future swap target: Core Data or a SQLite wrapper.
final class PersistenceService {
    static let shared = PersistenceService()

    private let defaults = UserDefaults.standard
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    private enum Keys {
        static let profile = "carwise.profile.v1"
        static let saved = "carwise.saved.v1"
        static let bookings = "carwise.bookings.v1"
        static let chat = "carwise.chat.v1"
    }

    private init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - Generic helpers

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        } catch {
            #if DEBUG
            print("[CarWise] persist encode failure for \(key): \(error)")
            #endif
        }
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        do {
            return try decoder.decode(type, from: data)
        } catch {
            #if DEBUG
            print("[CarWise] persist decode failure for \(key): \(error)")
            #endif
            return nil
        }
    }

    // MARK: - Profile

    func saveProfile(_ profile: UserProfile) { save(profile, forKey: Keys.profile) }
    func loadProfile() -> UserProfile? { load(UserProfile.self, forKey: Keys.profile) }

    // MARK: - Saved cars

    func saveSaved(_ cars: [SavedCar]) { save(cars, forKey: Keys.saved) }
    func loadSaved() -> [SavedCar] { load([SavedCar].self, forKey: Keys.saved) ?? [] }

    // MARK: - Bookings

    func saveBookings(_ bookings: [Booking]) { save(bookings, forKey: Keys.bookings) }
    func loadBookings() -> [Booking] { load([Booking].self, forKey: Keys.bookings) ?? [] }

    // MARK: - Chat history

    func saveChat(_ messages: [ChatMessage]) { save(messages, forKey: Keys.chat) }
    func loadChat() -> [ChatMessage] { load([ChatMessage].self, forKey: Keys.chat) ?? [] }

    // MARK: - Reset

    func wipeAll() {
        defaults.removeObject(forKey: Keys.profile)
        defaults.removeObject(forKey: Keys.saved)
        defaults.removeObject(forKey: Keys.bookings)
        defaults.removeObject(forKey: Keys.chat)
    }
}
