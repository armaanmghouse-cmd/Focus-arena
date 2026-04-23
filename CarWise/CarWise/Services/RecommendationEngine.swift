import Foundation

/// Rule-based recommendation engine.
/// Pure function of (profile, catalog) → [Recommendation]. No I/O, no state.
/// Swap target: LLM-assisted ranking layered on top of this as a pre-filter.
struct RecommendationEngine {

    /// Top-level entry. Returns up to `maxResults` recommendations, ranked by matchScore.
    static func recommend(for profile: UserProfile, maxResults: Int = 5) -> [Recommendation] {
        let scored = MockCarDatabase.all.compactMap { car -> (Car, ScoreBreakdown)? in
            let breakdown = score(car: car, profile: profile)
            // Hard filter: if the car is entirely outside of the budget, drop it unless budget is wide.
            guard breakdown.matchScore >= 30 else { return nil }
            return (car, breakdown)
        }

        let sorted = scored.sorted { $0.1.matchScore > $1.1.matchScore }
        let top = Array(sorted.prefix(maxResults))

        return top.map { car, bd in
            Recommendation(
                car: car,
                matchScore: bd.matchScore,
                bestValueScore: bd.bestValueScore,
                confidence: bd.confidence,
                reasoning: buildReasoning(car: car, profile: profile, breakdown: bd),
                matchHighlights: buildHighlights(car: car, profile: profile, breakdown: bd)
            )
        }
    }

    // MARK: - Score breakdown

    struct ScoreBreakdown {
        var budgetPoints: Double       // 0 – 25
        var typePoints: Double         // 0 – 15
        var conditionPoints: Double    // 0 – 5
        var useCasePoints: Double      // 0 – 25
        var featurePoints: Double      // 0 – 20
        var ownershipPoints: Double    // 0 – 8
        var brandPoints: Double        // 0 – 2

        var matchScore: Int {
            let total = budgetPoints + typePoints + conditionPoints +
                useCasePoints + featurePoints + ownershipPoints + brandPoints
            return Int(total.rounded())
        }

        var bestValueScore: Int
        var confidence: Int
    }

    // MARK: - Scoring

    static func score(car: Car, profile: UserProfile) -> ScoreBreakdown {
        // Budget (25 pts) — full points if car price range overlaps user budget midpoint.
        let budget = budgetPoints(for: car, profile: profile)

        // Type (15 pts)
        let type: Double
        if profile.vehicleTypes.isEmpty {
            type = 10 // no preference → moderate credit for every car
        } else if profile.vehicleTypes.contains(car.type) {
            type = 15
        } else if isRelatedType(car.type, selected: profile.vehicleTypes) {
            type = 7
        } else {
            type = 0
        }

        // Condition (5 pts)
        let condition: Double
        switch profile.condition {
        case .either:
            condition = 5
        case .new, .used:
            condition = car.availability.contains(profile.condition) ? 5 : 1
        }

        // Use case (25 pts) — average of fit scores for selected use cases, then scaled
        let useCase: Double
        if profile.useCases.isEmpty {
            useCase = 15
        } else {
            let sum = profile.useCases.reduce(0) { $0 + car.fit(for: $1) }
            let avg = Double(sum) / Double(profile.useCases.count) // 0–10
            useCase = (avg / 10.0) * 25.0
        }

        // Feature priorities (20 pts)
        let features: Double
        if profile.featurePriorities.isEmpty {
            features = 12
        } else {
            let sum = profile.featurePriorities.reduce(0) { $0 + car.score(for: $1) }
            let avg = Double(sum) / Double(profile.featurePriorities.count) // 0–10
            features = (avg / 10.0) * 20.0
        }

        // Ownership length (8 pts) — long ownership boosts reliability weight heavily
        let ownership: Double
        let reliab = Double(car.reliabilityScore) / 10.0
        switch profile.ownershipLength {
        case .short:  ownership = reliab * 4
        case .medium: ownership = reliab * 6
        case .long:   ownership = reliab * 8
        }

        // Brand preference (2 pts)
        let brand: Double = profile.preferredBrands.contains(car.make) ? 2 : 0

        // Best-value score
        let bestValue = valueScore(car: car, profile: profile)

        // Confidence
        let confidence = confidenceScore(car: car, profile: profile)

        return ScoreBreakdown(
            budgetPoints: budget,
            typePoints: type,
            conditionPoints: condition,
            useCasePoints: useCase,
            featurePoints: features,
            ownershipPoints: ownership,
            brandPoints: brand,
            bestValueScore: bestValue,
            confidence: confidence
        )
    }

    // MARK: - Sub-scoring

    private static func budgetPoints(for car: Car, profile: UserProfile) -> Double {
        let carLow = car.priceMin
        let carHigh = car.priceMax
        let budgetLow = profile.budgetMin
        let budgetHigh = profile.budgetMax

        // overlap of ranges
        let overlapLow = max(carLow, budgetLow)
        let overlapHigh = min(carHigh, budgetHigh)
        let overlap = max(0, overlapHigh - overlapLow)

        let carRange = max(carHigh - carLow, 1)
        let budgetRange = max(budgetHigh - budgetLow, 1)

        if overlap > 0 {
            let coverage = overlap / min(carRange, budgetRange)    // 0–1
            return 15 + (coverage * 10)                            // 15 – 25
        } else {
            // no overlap — partial credit if close, zero if very far
            let distance: Double
            if carHigh < budgetLow { distance = budgetLow - carHigh }
            else { distance = carLow - budgetHigh }
            let tolerance = budgetRange * 0.25
            if distance <= tolerance {
                let ratio = 1 - (distance / tolerance)
                return ratio * 10
            }
            return 0
        }
    }

    private static func isRelatedType(_ type: VehicleType, selected: Set<VehicleType>) -> Bool {
        // rough related-category map — lets a hatchback slip in for someone asking for sedans, etc.
        let groups: [Set<VehicleType>] = [
            [.sedan, .hatchback, .coupe],
            [.suv, .minivan],
            [.truck, .suv],
            [.ev, .sedan]
        ]
        return groups.contains { $0.contains(type) && !$0.isDisjoint(with: selected) }
    }

    private static func valueScore(car: Car, profile: UserProfile) -> Int {
        // "Value" = total characteristic strength per dollar, normalized for this catalog.
        let totalScore = car.reliabilityScore + car.fuelEconomyScore + car.techScore +
            car.luxuryScore + car.safetyScore + car.performanceScore + car.cargoScore
        let avgPrice = (car.priceMin + car.priceMax) / 2
        let density = Double(totalScore) / (avgPrice / 10_000.0)
        // Observed density across the catalog ranges roughly 8 – 25.
        let clamped = min(max(density, 6), 26)
        let normalized = (clamped - 6) / 20.0   // 0 – 1
        var score = normalized * 100

        // Bonus if the car's midpoint sits in the lower third of the user's budget.
        let third = profile.budgetMin + (profile.budgetMax - profile.budgetMin) / 3
        if avgPrice <= third { score = min(100, score + 8) }

        return Int(score.rounded())
    }

    private static func confidenceScore(car: Car, profile: UserProfile) -> Int {
        var c: Double = 60
        c += profile.vehicleTypes.isEmpty ? 0 : 8
        c += profile.useCases.isEmpty ? 0 : 10
        c += profile.featurePriorities.isEmpty ? 0 : 8
        c += profile.preferredBrands.isEmpty ? 0 : 4
        c += (profile.budgetMax - profile.budgetMin) < 20_000 ? 6 : 2

        // Penalize if car is at the edge of budget
        let avgPrice = (car.priceMin + car.priceMax) / 2
        if avgPrice > profile.budgetMax || avgPrice < profile.budgetMin * 0.6 {
            c -= 6
        }
        return Int(min(max(c, 40), 98).rounded())
    }

    // MARK: - Reasoning

    private static func buildReasoning(car: Car, profile: UserProfile, breakdown: ScoreBreakdown) -> String {
        var lines: [String] = []

        // Opening — why this car
        lines.append("\(car.displayName) scored \(breakdown.matchScore)/100 for your profile. Here's the math:")
        lines.append("")

        // Budget
        let avg = (car.priceMin + car.priceMax) / 2
        if avg >= profile.budgetMin && avg <= profile.budgetMax {
            lines.append("• Price: \(car.priceDisplay) sits comfortably inside your \(profile.budgetSummary) budget.")
        } else if avg < profile.budgetMin {
            lines.append("• Price: \(car.priceDisplay) — below your budget floor. Leaves headroom for options, tax, or a better trim.")
        } else {
            lines.append("• Price: \(car.priceDisplay) is slightly above your stated ceiling — worth stretching only if the other fit factors are strong.")
        }

        // Type
        if profile.vehicleTypes.contains(car.type) {
            lines.append("• Type: \(car.type.displayName) — exactly what you asked for.")
        } else if !profile.vehicleTypes.isEmpty && isRelatedType(car.type, selected: profile.vehicleTypes) {
            lines.append("• Type: \(car.type.displayName) — adjacent to your preference. Included because it scored unusually well on your use cases.")
        }

        // Use cases
        if !profile.useCases.isEmpty {
            let matched = profile.useCases
                .filter { car.fit(for: $0) >= 7 }
                .map { $0.displayName.lowercased() }
            if !matched.isEmpty {
                lines.append("• Use case: strong fit for \(oxfordList(matched)).")
            }
        }

        // Features
        if !profile.featurePriorities.isEmpty {
            let topFeatures = profile.featurePriorities
                .sorted { car.score(for: $0) > car.score(for: $1) }
                .prefix(3)
                .map { "\($0.displayName.lowercased()) (\(car.score(for: $0))/10)" }
            lines.append("• Your priorities: \(topFeatures.joined(separator: ", ")).")
        }

        // Ownership weight
        if profile.ownershipLength == .long {
            lines.append("• Long-term ownership: reliability weighted heavily — this car scores \(car.reliabilityScore)/10.")
        }

        // Brand
        if profile.preferredBrands.contains(car.make) {
            lines.append("• Brand: matches your preferred list.")
        }

        lines.append("")
        lines.append("Confidence: \(breakdown.confidence)% — " + confidenceBlurb(breakdown.confidence))

        return lines.joined(separator: "\n")
    }

    private static func confidenceBlurb(_ c: Int) -> String {
        switch c {
        case 90...: return "very high. Your profile is specific and this car matches cleanly across every axis."
        case 80..<90: return "high. Strong match with minor trade-offs."
        case 70..<80: return "solid. A few inputs could sharpen the ranking — consider narrowing budget or priorities."
        case 60..<70: return "moderate. Add more priorities in onboarding to tighten this up."
        default: return "low. Sparse inputs — treat this as a starting point and refine your profile."
        }
    }

    private static func buildHighlights(car: Car, profile: UserProfile, breakdown: ScoreBreakdown) -> [String] {
        var highlights: [String] = []

        if breakdown.budgetPoints >= 20 { highlights.append("In budget") }
        if profile.vehicleTypes.contains(car.type) { highlights.append("Preferred type") }

        let featureMatches = profile.featurePriorities.filter { car.score(for: $0) >= 8 }
        for f in featureMatches.prefix(2) { highlights.append(f.displayName) }

        let useMatches = profile.useCases.filter { car.fit(for: $0) >= 8 }
        for u in useMatches.prefix(2) { highlights.append(u.displayName) }

        if profile.ownershipLength == .long && car.reliabilityScore >= 8 {
            highlights.append("Long-term reliable")
        }

        if breakdown.bestValueScore >= 75 { highlights.append("Great value") }

        if highlights.isEmpty { highlights.append("Balanced pick") }
        return Array(highlights.prefix(4))
    }

    private static func oxfordList(_ items: [String]) -> String {
        switch items.count {
        case 0: return ""
        case 1: return items[0]
        case 2: return "\(items[0]) and \(items[1])"
        default:
            let head = items.dropLast().joined(separator: ", ")
            return "\(head), and \(items.last!)"
        }
    }
}
