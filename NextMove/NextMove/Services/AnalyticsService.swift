import Foundation

struct RegretPattern: Identifiable, Hashable {
    let id = UUID()
    let tag: String
    let count: Int
    let suggestion: String
}

enum AnalyticsService {
    private static let stopWords: Set<String> = [
        "the","and","a","an","for","to","of","in","on","at","by","with","from","as",
        "i","me","my","we","our","you","your","it","is","was","were","be","been","being",
        "do","did","doing","does","done","had","has","have","having","not","no","but",
        "this","that","these","those","so","too","very","really","much","more","less",
        "didnt","didn","wasnt","wasn","couldnt","couldn","shouldnt","shouldn","wouldnt","wouldn",
        "just","only","also","than","then","there","here","what","when","why","how","about",
        "today","tomorrow","yesterday","day","time","bit","lot","some","any","all","go","went"
    ]

    private static let intentMap: [String: String] = [
        "study": "studying",
        "studied": "studying",
        "studying": "studying",
        "homework": "studying",
        "exercise": "exercising",
        "exercising": "exercising",
        "workout": "exercising",
        "workouts": "exercising",
        "gym": "exercising",
        "run": "running",
        "running": "running",
        "sleep": "sleeping early",
        "read": "reading",
        "reading": "reading",
        "meditate": "meditating",
        "meditation": "meditating",
        "family": "calling family",
        "call": "calling family",
        "called": "calling family",
        "friends": "reaching out to friends",
        "water": "hydrating",
        "drink": "hydrating",
        "journal": "journaling",
        "write": "journaling"
    ]

    static func extractTags(from text: String) -> [String] {
        let cleaned = text.lowercased()
            .replacingOccurrences(of: "'", with: "")
        let tokens = cleaned
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty && $0.count >= 3 && !stopWords.contains($0) }

        var seen = Set<String>()
        var result: [String] = []
        for token in tokens {
            let normalized = intentMap[token] ?? token
            if seen.insert(normalized).inserted {
                result.append(normalized)
            }
        }
        return result
    }

    static func patterns(from reflections: [Reflection], minCount: Int = 2, limit: Int = 6) -> [RegretPattern] {
        var counts: [String: Int] = [:]
        for reflection in reflections {
            let source = reflection.tags.isEmpty ? extractTags(from: reflection.regret) : reflection.tags
            for tag in source {
                counts[tag, default: 0] += 1
            }
        }

        return counts
            .filter { $0.value >= minCount }
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { tag, count in
                RegretPattern(
                    tag: tag,
                    count: count,
                    suggestion: suggestion(for: tag)
                )
            }
    }

    static func suggestion(for tag: String) -> String {
        switch tag {
        case "studying": return "You frequently regret not studying. Block 30 min tomorrow."
        case "exercising": return "Movement keeps coming up. Schedule a short workout tomorrow."
        case "running": return "Running is on your mind. Plan a route for tomorrow."
        case "sleeping early": return "You value rest. Set a wind-down reminder tonight."
        case "reading": return "Reading is recurring. Add a 20-minute reading goal."
        case "meditating": return "Meditation matters to you. Try 5 minutes tomorrow."
        case "calling family": return "You keep missing family time. Put a call on the calendar."
        case "reaching out to friends": return "Connection is recurring. Message one friend tomorrow."
        case "hydrating": return "Hydration keeps slipping. Set a midday reminder."
        case "journaling": return "Journaling recurs — make it the first goal tomorrow."
        default: return "You frequently regret not \(tag). Make it a goal tomorrow."
        }
    }

    static func suggestedGoals(from patterns: [RegretPattern]) -> [Goal] {
        patterns.prefix(3).map { pattern in
            Goal(
                title: goalTitle(for: pattern.tag),
                priority: .high,
                category: inferredCategory(for: pattern.tag),
                period: .morning,
                notes: "Suggested from repeated regret: \(pattern.tag)"
            )
        }
    }

    private static func goalTitle(for tag: String) -> String {
        switch tag {
        case "studying": return "Study focused block"
        case "exercising": return "Work out"
        case "running": return "Go for a run"
        case "sleeping early": return "Wind down by 10pm"
        case "reading": return "Read 20 minutes"
        case "meditating": return "Meditate 5 minutes"
        case "calling family": return "Call family"
        case "reaching out to friends": return "Message a friend"
        case "hydrating": return "Drink enough water"
        case "journaling": return "Journal entry"
        default: return tag.capitalized
        }
    }

    private static func inferredCategory(for tag: String) -> GoalCategory {
        switch tag {
        case "studying": return .school
        case "exercising", "running": return .sports
        case "meditating", "hydrating", "sleeping early", "journaling": return .health
        case "calling family", "reaching out to friends": return .personal
        default: return .personal
        }
    }
}
