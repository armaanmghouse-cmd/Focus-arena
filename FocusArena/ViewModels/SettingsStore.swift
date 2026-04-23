import Foundation
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    @Published var settings: AppSettings {
        didSet { persist() }
    }

    private let filename = "settings.json"

    init() {
        self.settings = PersistenceService.shared.load(AppSettings.self, from: filename, fallback: .default)
        applyHapticPreference()
        applyReminderPreference()
    }

    func toggleStrictMode() {
        settings.strictMode.toggle()
    }

    func setDuration(_ seconds: TimeInterval) {
        settings.defaultDuration = max(60, seconds)
    }

    func setGracePeriod(_ seconds: TimeInterval) {
        settings.gracePeriod = max(0, seconds)
    }

    private func persist() {
        PersistenceService.shared.save(settings, to: filename)
        applyHapticPreference()
        applyReminderPreference()
    }

    private func applyHapticPreference() {
        HapticService.shared.enabled = settings.hapticsEnabled
    }

    private func applyReminderPreference() {
        if settings.dailyReminderEnabled {
            NotificationService.shared.scheduleDailyReminder(
                hour: settings.dailyReminderHour,
                minute: settings.dailyReminderMinute
            )
        } else {
            NotificationService.shared.cancelDailyReminder()
        }
    }
}
