import Foundation

struct FocusSession: Identifiable, Codable, Hashable {
    enum Outcome: String, Codable {
        case success
        case failed
        case inProgress
    }

    enum FailureReason: String, Codable {
        case leftApp = "Left the arena"
        case backgrounded = "App was backgrounded"
        case lockedScreen = "Screen was locked"
        case interrupted = "Interrupted by system"
        case userQuit = "Surrendered"
        case unknown = "Unknown breach"
    }

    var id: UUID
    var task: String
    var startedAt: Date
    var endedAt: Date?
    var plannedDuration: TimeInterval
    var actualDuration: TimeInterval
    var outcome: Outcome
    var failureReason: FailureReason?
    var xpEarned: Int
    var strictMode: Bool

    init(id: UUID = UUID(),
         task: String,
         startedAt: Date = Date(),
         endedAt: Date? = nil,
         plannedDuration: TimeInterval,
         actualDuration: TimeInterval = 0,
         outcome: Outcome = .inProgress,
         failureReason: FailureReason? = nil,
         xpEarned: Int = 0,
         strictMode: Bool = false) {
        self.id = id
        self.task = task
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.outcome = outcome
        self.failureReason = failureReason
        self.xpEarned = xpEarned
        self.strictMode = strictMode
    }

    var timeRemaining: TimeInterval {
        max(0, plannedDuration - actualDuration)
    }
}
