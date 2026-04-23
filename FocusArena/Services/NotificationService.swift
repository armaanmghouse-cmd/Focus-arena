import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleDailyReminder(hour: Int, minute: Int) {
        let id = "focus.arena.daily.reminder"
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Step into the Arena"
        content.body = "Your streak is waiting. Lock in a focus session."
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["focus.arena.daily.reminder"])
    }

    func scheduleSessionCompletion(after seconds: TimeInterval, task: String) {
        let id = "focus.arena.session.complete"
        center.removePendingNotificationRequests(withIdentifiers: [id])

        let content = UNMutableNotificationContent()
        content.title = "Session Complete"
        content.body = "You held the line on \"\(task)\". Claim your reward."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelSessionCompletion() {
        center.removePendingNotificationRequests(withIdentifiers: ["focus.arena.session.complete"])
    }
}
