import Foundation

struct UserProfile: Codable {
    var totalXP: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
    var totalSuccessfulSessions: Int
    var totalFailedSessions: Int
    var totalFocusTime: TimeInterval

    static let `default` = UserProfile(
        totalXP: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastSessionDate: nil,
        totalSuccessfulSessions: 0,
        totalFailedSessions: 0,
        totalFocusTime: 0
    )

    var level: Int {
        Self.level(for: totalXP)
    }

    var xpInCurrentLevel: Int {
        totalXP - Self.xpRequired(forLevel: level)
    }

    var xpForNextLevel: Int {
        Self.xpRequired(forLevel: level + 1) - Self.xpRequired(forLevel: level)
    }

    var levelProgress: Double {
        guard xpForNextLevel > 0 else { return 0 }
        return Double(xpInCurrentLevel) / Double(xpForNextLevel)
    }

    static func level(for xp: Int) -> Int {
        var level = 1
        while xpRequired(forLevel: level + 1) <= xp && level < 50 {
            level += 1
        }
        return level
    }

    static func xpRequired(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (level - 1) * (level - 1) * 100
    }
}
