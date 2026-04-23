import Foundation
import UserNotifications

/// Thin wrapper around UNUserNotificationCenter.
/// The app asks for permission once after onboarding and uses two reminder types.
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    enum ReminderID: String {
        case incompleteOnboarding = "carwise.reminder.onboarding"
        case freshRecommendations = "carwise.reminder.fresh_recs"
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleFinishOnboardingReminder(after hours: Int = 24) {
        let content = UNMutableNotificationContent()
        content.title = "Finish your car search"
        content.body = "Your profile is almost complete — one more step and CarWise will rank your matches."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(hours) * 3600, repeats: false)
        let request = UNNotificationRequest(
            identifier: ReminderID.incompleteOnboarding.rawValue,
            content: content,
            trigger: trigger
        )
        cancel(.incompleteOnboarding)
        center.add(request, withCompletionHandler: nil)
    }

    func scheduleFreshRecommendationsReminder(after days: Int = 7) {
        let content = UNMutableNotificationContent()
        content.title = "New recommendations ready"
        content.body = "Take another look — we've refreshed your top matches."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(days) * 86_400, repeats: false)
        let request = UNNotificationRequest(
            identifier: ReminderID.freshRecommendations.rawValue,
            content: content,
            trigger: trigger
        )
        cancel(.freshRecommendations)
        center.add(request, withCompletionHandler: nil)
    }

    func cancel(_ id: ReminderID) {
        center.removePendingNotificationRequests(withIdentifiers: [id.rawValue])
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
