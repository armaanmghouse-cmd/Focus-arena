import Foundation

struct DayLog: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var goals: [Goal]
    var reflection: Reflection?
    var middayAdjustmentDone: Bool
    var score: Double

    init(
        id: UUID = UUID(),
        date: Date,
        goals: [Goal] = [],
        reflection: Reflection? = nil,
        middayAdjustmentDone: Bool = false,
        score: Double = 0
    ) {
        self.id = id
        self.date = date
        self.goals = goals
        self.reflection = reflection
        self.middayAdjustmentDone = middayAdjustmentDone
        self.score = score
    }

    var completedCount: Int {
        goals.filter { $0.isCompleted }.count
    }

    var totalCount: Int { goals.count }

    var completionRatio: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }

    var progressText: String { "\(completedCount)/\(totalCount)" }
}

extension DayLog {
    static func startOfDay(_ date: Date = Date()) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func isSameDay(_ a: Date, _ b: Date) -> Bool {
        Calendar.current.isDate(a, inSameDayAs: b)
    }
}
