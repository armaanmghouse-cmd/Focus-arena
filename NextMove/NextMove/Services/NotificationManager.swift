import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private enum Prefix {
        static let goal = "nextmove.goal."
        static let nightReflection = "nextmove.night.reflection"
        static let midday = "nextmove.midday.adjustment"
    }

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    // MARK: - Per-goal reminders

    func scheduleReminders(for goal: Goal, settings: AppSettings) {
        cancelReminders(for: goal.id)
        guard settings.notificationsEnabled, !goal.isCompleted else { return }

        let frequency = goal.reminderFrequency
        let intervalMinutes = frequency.intervalMinutes
        let now = Date()
        let calendar = Calendar.current

        let messages = messages(for: goal)

        for (index, message) in messages.enumerated() {
            let fireDate: Date
            if index == 0 {
                fireDate = now.addingTimeInterval(TimeInterval(intervalMinutes * 60 / 2))
            } else {
                fireDate = now.addingTimeInterval(TimeInterval(index * intervalMinutes * 60))
            }

            guard fireDate > now else { continue }
            guard !isInQuietHours(fireDate, settings: settings) else { continue }

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let content = UNMutableNotificationContent()
            content.title = message.title
            content.body = message.body
            content.sound = index >= 2 ? .defaultCritical : .default
            content.userInfo = ["goalId": goal.id.uuidString]

            let id = "\(Prefix.goal)\(goal.id.uuidString).\(index)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            center.add(request)
        }
    }

    func cancelReminders(for goalId: UUID) {
        center.getPendingNotificationRequests { [weak self] requests in
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix("\(Prefix.goal)\(goalId.uuidString)") }
            self?.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func cancelAllGoalReminders() {
        center.getPendingNotificationRequests { [weak self] requests in
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(Prefix.goal) }
            self?.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func reschedule(goals: [Goal], settings: AppSettings) {
        cancelAllGoalReminders()
        guard settings.notificationsEnabled else { return }
        for goal in goals where !goal.isCompleted {
            scheduleReminders(for: goal, settings: settings)
        }
    }

    // MARK: - Daily anchors

    func scheduleNightReflection(settings: AppSettings) {
        center.removePendingNotificationRequests(withIdentifiers: [Prefix.nightReflection])
        guard settings.notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to reflect"
        content.body = "What do you regret not doing today? Take 60 seconds."
        content.sound = .default

        var components = DateComponents()
        components.hour = settings.nightReflectionHour
        components.minute = settings.nightReflectionMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Prefix.nightReflection, content: content, trigger: trigger)
        center.add(request)
    }

    func scheduleMiddayAdjustment(settings: AppSettings) {
        center.removePendingNotificationRequests(withIdentifiers: [Prefix.midday])
        guard settings.notificationsEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Midday check-in"
        content.body = "Are these still your priorities? Adjust if the day shifted."
        content.sound = .default

        var components = DateComponents()
        components.hour = settings.middayAdjustmentHour
        components.minute = settings.middayAdjustmentMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Prefix.midday, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelAllDailyAnchors() {
        center.removePendingNotificationRequests(withIdentifiers: [Prefix.nightReflection, Prefix.midday])
    }

    // MARK: - Message generation (context-aware, escalating)

    private struct ReminderMessage {
        let title: String
        let body: String
    }

    private func messages(for goal: Goal) -> [ReminderMessage] {
        let title = goal.title
        return [
            ReminderMessage(
                title: "You said this mattered today",
                body: "\u{201C}\(title)\u{201D} is still waiting. A 5-minute start counts."
            ),
            ReminderMessage(
                title: "Haven\u{2019}t started yet",
                body: "You haven\u{2019}t started \u{201C}\(title)\u{201D}. What\u{2019}s one small move?"
            ),
            ReminderMessage(
                title: "This was a priority",
                body: "\u{201C}\(title)\u{201D} is the one you\u{2019}ll regret skipping. Do it now."
            ),
            ReminderMessage(
                title: "Last call for \u{201C}\(title)\u{201D}",
                body: "Close out the day strong. Ten minutes beats zero."
            )
        ]
    }

    private func isInQuietHours(_ date: Date, settings: AppSettings) -> Bool {
        let hour = Calendar.current.component(.hour, from: date)
        let start = settings.quietStartHour
        let end = settings.quietEndHour

        if start == end { return false }
        if start < end {
            return hour >= start && hour < end
        } else {
            return hour >= start || hour < end
        }
    }
}
