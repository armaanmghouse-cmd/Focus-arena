import Foundation
import SwiftUI

enum GoalPriority: String, Codable, CaseIterable, Identifiable {
    case low
    case medium
    case high
    case critical

    var id: String { rawValue }

    var label: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }

    var weight: Double {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 5
        }
    }

    var color: Color {
        switch self {
        case .low: return Theme.priorityLow
        case .medium: return Theme.priorityMedium
        case .high: return Theme.priorityHigh
        case .critical: return Theme.priorityCritical
        }
    }

    var symbol: String {
        switch self {
        case .low: return "leaf.fill"
        case .medium: return "flag.fill"
        case .high: return "flame.fill"
        case .critical: return "bolt.fill"
        }
    }
}

enum GoalCategory: String, Codable, CaseIterable, Identifiable {
    case school
    case sports
    case personal
    case work
    case health
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .school: return "School"
        case .sports: return "Sports"
        case .personal: return "Personal"
        case .work: return "Work"
        case .health: return "Health"
        case .other: return "Other"
        }
    }

    var symbol: String {
        switch self {
        case .school: return "book.closed.fill"
        case .sports: return "figure.run"
        case .personal: return "heart.fill"
        case .work: return "briefcase.fill"
        case .health: return "cross.case.fill"
        case .other: return "sparkles"
        }
    }

    var color: Color {
        switch self {
        case .school: return Theme.catSchool
        case .sports: return Theme.catSports
        case .personal: return Theme.catPersonal
        case .work: return Theme.catWork
        case .health: return Theme.catHealth
        case .other: return Theme.catOther
        }
    }
}

enum GoalPeriod: String, Codable {
    case morning
    case midday
}

enum ReminderFrequency: String, Codable, CaseIterable, Identifiable {
    case gentle
    case normal
    case urgent

    var id: String { rawValue }

    var label: String {
        switch self {
        case .gentle: return "Gentle"
        case .normal: return "Normal"
        case .urgent: return "Urgent"
        }
    }

    var intervalMinutes: Int {
        switch self {
        case .gentle: return 180
        case .normal: return 90
        case .urgent: return 45
        }
    }
}

struct Goal: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var priority: GoalPriority
    var category: GoalCategory
    var deadline: Date?
    var createdAt: Date
    var completedAt: Date?
    var period: GoalPeriod
    var reminderFrequency: ReminderFrequency
    var notes: String

    init(
        id: UUID = UUID(),
        title: String,
        priority: GoalPriority = .medium,
        category: GoalCategory = .personal,
        deadline: Date? = nil,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        period: GoalPeriod = .morning,
        reminderFrequency: ReminderFrequency = .normal,
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.priority = priority
        self.category = category
        self.deadline = deadline
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.period = period
        self.reminderFrequency = reminderFrequency
        self.notes = notes
    }

    var isCompleted: Bool { completedAt != nil }

    var isOverdue: Bool {
        guard let deadline, !isCompleted else { return false }
        return deadline < Date()
    }
}
