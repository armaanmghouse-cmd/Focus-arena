import Foundation

struct AppSettings: Codable, Equatable {
    var notificationsEnabled: Bool
    var globalReminderFrequency: ReminderFrequency
    var nightReflectionHour: Int
    var nightReflectionMinute: Int
    var middayAdjustmentHour: Int
    var middayAdjustmentMinute: Int
    var quietStartHour: Int
    var quietEndHour: Int
    var useDarkMode: Bool
    var hasOnboarded: Bool

    static let `default` = AppSettings(
        notificationsEnabled: true,
        globalReminderFrequency: .normal,
        nightReflectionHour: 21,
        nightReflectionMinute: 30,
        middayAdjustmentHour: 13,
        middayAdjustmentMinute: 0,
        quietStartHour: 22,
        quietEndHour: 7,
        useDarkMode: false,
        hasOnboarded: false
    )
}
