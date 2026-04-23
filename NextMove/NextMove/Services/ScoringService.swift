import Foundation

enum ScoringService {
    static func score(for log: DayLog) -> Double {
        guard !log.goals.isEmpty else { return 0 }

        let totalWeight = log.goals.reduce(0) { $0 + $1.priority.weight }
        guard totalWeight > 0 else { return 0 }

        let earned = log.goals
            .filter { $0.isCompleted }
            .reduce(0) { $0 + $1.priority.weight }

        let ratio = earned / totalWeight

        let criticalGoals = log.goals.filter { $0.priority == .critical }
        let criticalCompletedRatio: Double
        if criticalGoals.isEmpty {
            criticalCompletedRatio = 1.0
        } else {
            let done = Double(criticalGoals.filter { $0.isCompleted }.count)
            criticalCompletedRatio = done / Double(criticalGoals.count)
        }

        let combined = ratio * 0.75 + criticalCompletedRatio * 0.25
        return (combined * 100).rounded()
    }

    static func improvementDelta(today: DayLog?, yesterday: DayLog?) -> Double {
        guard let today, let yesterday else { return 0 }
        return today.score - yesterday.score
    }

    static func improvementText(delta: Double) -> String {
        if delta > 1 {
            return "You improved vs yesterday (+\(Int(delta)))"
        } else if delta < -1 {
            return "Down \(Int(abs(delta))) from yesterday"
        } else {
            return "Steady with yesterday"
        }
    }
}
