import Foundation
import SwiftUI
import Combine

enum AppTab: Hashable {
    case home, recommendations, chat, saved, expert
}

@MainActor
final class AppState: ObservableObject {
    // MARK: - Persisted state

    @Published var profile: UserProfile { didSet { persistence.saveProfile(profile) } }
    @Published var savedCars: [SavedCar] { didSet { persistence.saveSaved(savedCars) } }
    @Published var bookings: [Booking] { didSet { persistence.saveBookings(bookings) } }
    @Published var chatMessages: [ChatMessage] { didSet { persistence.saveChat(chatMessages) } }

    // MARK: - Transient UI state

    @Published var selectedTab: AppTab = .home
    @Published var hasCompletedOnboarding: Bool

    // MARK: - Dependencies

    let persistence: PersistenceService
    let notifications: NotificationService

    init(
        persistence: PersistenceService = .shared,
        notifications: NotificationService = .shared
    ) {
        self.persistence = persistence
        self.notifications = notifications

        let loadedProfile = persistence.loadProfile() ?? .empty
        self.profile = loadedProfile
        self.savedCars = persistence.loadSaved()
        self.bookings = persistence.loadBookings()
        self.chatMessages = persistence.loadChat()
        self.hasCompletedOnboarding = loadedProfile.isComplete
    }

    // MARK: - Onboarding

    func completeOnboarding(with profile: UserProfile) {
        var p = profile
        p.isComplete = true
        p.completedAt = Date()
        self.profile = p
        self.hasCompletedOnboarding = true
        notifications.cancel(.incompleteOnboarding)
        notifications.scheduleFreshRecommendationsReminder(after: 7)
    }

    func resetOnboarding() {
        profile = .empty
        hasCompletedOnboarding = false
    }

    // MARK: - Saved cars

    func isSaved(carId: String) -> Bool {
        savedCars.contains { $0.id == carId }
    }

    func saved(for carId: String) -> SavedCar? {
        savedCars.first { $0.id == carId }
    }

    func toggleSaved(carId: String) {
        if let idx = savedCars.firstIndex(where: { $0.id == carId }) {
            savedCars.remove(at: idx)
        } else {
            savedCars.append(SavedCar(id: carId, notes: "", isTopChoice: false, savedAt: Date()))
        }
    }

    func updateNotes(carId: String, notes: String) {
        guard let idx = savedCars.firstIndex(where: { $0.id == carId }) else { return }
        savedCars[idx].notes = notes
    }

    func toggleTopChoice(carId: String) {
        guard let idx = savedCars.firstIndex(where: { $0.id == carId }) else { return }
        savedCars[idx].isTopChoice.toggle()
    }

    // MARK: - Bookings

    func book(_ booking: Booking) {
        bookings.insert(booking, at: 0)
    }

    func cancelBooking(id: UUID) {
        guard let idx = bookings.firstIndex(where: { $0.id == id }) else { return }
        bookings[idx].status = .cancelled
    }

    var upcomingBooking: Booking? {
        bookings
            .filter { $0.status == .confirmed && $0.date > Date() }
            .sorted { $0.date < $1.date }
            .first
    }

    // MARK: - Chat

    func appendChatMessage(_ message: ChatMessage) {
        chatMessages.append(message)
    }

    func clearChat() {
        chatMessages.removeAll()
    }
}
