import Foundation

struct Recommendation: Identifiable, Equatable, Hashable {
    let id: UUID
    let car: Car
    let matchScore: Int       // 0–100 — overall fit
    let bestValueScore: Int   // 0–100 — value for money given budget
    let confidence: Int       // 0–100 — engine confidence
    let reasoning: String
    let matchHighlights: [String]

    init(
        id: UUID = UUID(),
        car: Car,
        matchScore: Int,
        bestValueScore: Int,
        confidence: Int,
        reasoning: String,
        matchHighlights: [String]
    ) {
        self.id = id
        self.car = car
        self.matchScore = matchScore
        self.bestValueScore = bestValueScore
        self.confidence = confidence
        self.reasoning = reasoning
        self.matchHighlights = matchHighlights
    }
}

struct SavedCar: Codable, Identifiable, Equatable {
    let id: String        // same as Car.id
    var notes: String
    var isTopChoice: Bool
    var savedAt: Date
}
