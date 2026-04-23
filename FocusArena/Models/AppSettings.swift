import Foundation

struct AppSettings: Codable {
    var defaultDuration: TimeInterval
    var gracePeriod: TimeInterval
    var strictMode: Bool
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var dailyReminderEnabled: Bool
    var dailyReminderHour: Int
    var dailyReminderMinute: Int

    static let `default` = AppSettings(
        defaultDuration: 25 * 60,
        gracePeriod: 3,
        strictMode: false,
        hapticsEnabled: true,
        soundEnabled: false,
        dailyReminderEnabled: true,
        dailyReminderHour: 9,
        dailyReminderMinute: 0
    )
}
