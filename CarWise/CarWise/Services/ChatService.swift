import Foundation

/// Rule-based chat assistant. Parses intent, pulls data from MockCarDatabase,
/// and writes a grounded reply informed by the user's profile.
/// Swap target: replace `answer(...)` with an LLM call that receives the profile + catalog.
struct ChatService {

    enum Intent {
        case reliability(Car)
        case worthIt(Car)
        case comparison(Car, Car)
        case fuelEconomy(Car)
        case safetyQuestion(Car)
        case bestFor(FeaturePriority?)
        case budgetFit(Car)
        case general(Car?)
        case unknown
    }

    // MARK: - Entry point

    static func answer(to userText: String, profile: UserProfile) -> ChatMessage {
        let intent = classify(userText)
        let (content, refs) = respond(to: intent, userText: userText, profile: profile)
        return ChatMessage(role: .assistant, content: content, referencedCarIds: refs)
    }

    // MARK: - Intent classification

    static func classify(_ text: String) -> Intent {
        let lower = text.lowercased()
        let matched = MockCarDatabase.match(query: lower)

        // Comparison: "X or Y", "X vs Y", "better, X or Y"
        if matched.count >= 2 && (lower.contains(" vs ") || lower.contains(" or ") || lower.contains("better")) {
            return .comparison(matched[0], matched[1])
        }

        if let car = matched.first {
            if lower.contains("reliab") || lower.contains("dependable") || lower.contains("break") {
                return .reliability(car)
            }
            if lower.contains("worth") || lower.contains("value") || lower.contains("price") {
                return .worthIt(car)
            }
            if lower.contains("mpg") || lower.contains("fuel") || lower.contains("gas") || lower.contains("efficien") {
                return .fuelEconomy(car)
            }
            if lower.contains("safe") || lower.contains("crash") || lower.contains("iihs") {
                return .safetyQuestion(car)
            }
            if lower.contains("budget") || lower.contains("afford") {
                return .budgetFit(car)
            }
            return .general(car)
        }

        // Best-for without a named car
        for f in FeaturePriority.allCases {
            if lower.contains(f.displayName.lowercased()) || lower.contains(f.rawValue.lowercased()) {
                return .bestFor(f)
            }
        }
        if lower.contains("commute") { return .bestFor(.fuelEconomy) }
        if lower.contains("family") { return .bestFor(.safety) }
        if lower.contains("fun") || lower.contains("sport") { return .bestFor(.performance) }

        return .unknown
    }

    // MARK: - Response builders

    private static func respond(to intent: Intent, userText: String, profile: UserProfile) -> (String, [String]) {
        switch intent {
        case .reliability(let car):
            return (reliabilityBlurb(car: car, profile: profile), [car.id])

        case .worthIt(let car):
            return (worthItBlurb(car: car, profile: profile), [car.id])

        case .comparison(let a, let b):
            return (comparisonBlurb(a: a, b: b, profile: profile), [a.id, b.id])

        case .fuelEconomy(let car):
            return (fuelBlurb(car: car, profile: profile), [car.id])

        case .safetyQuestion(let car):
            return (safetyBlurb(car: car, profile: profile), [car.id])

        case .bestFor(let feature):
            return bestForBlurb(feature: feature, profile: profile)

        case .budgetFit(let car):
            return (budgetBlurb(car: car, profile: profile), [car.id])

        case .general(let car):
            return (generalBlurb(car: car, profile: profile, userText: userText),
                    car.map { [$0.id] } ?? [])

        case .unknown:
            return (fallback(profile: profile), [])
        }
    }

    // MARK: - Blurb writers

    private static func reliabilityBlurb(car: Car, profile: UserProfile) -> String {
        let descriptor: String
        switch car.reliabilityScore {
        case 9...: descriptor = "exceptional"
        case 8: descriptor = "very strong"
        case 7: descriptor = "above average"
        case 6: descriptor = "average"
        default: descriptor = "below average — go in eyes open"
        }
        var lines: [String] = []
        lines.append("The \(car.displayName) has \(descriptor) reliability (\(car.reliabilityScore)/10).")
        if profile.ownershipLength == .long {
            lines.append("Since you plan to keep it 6+ years, that reliability score matters more than almost anything else. This one \(car.reliabilityScore >= 8 ? "holds up" : "may need more attention in years 5+").")
        }
        if car.reliabilityScore >= 8 {
            lines.append("Typical 10-year problem areas are minor — brakes, tires, occasional sensors.")
        } else {
            lines.append("Budget a cushion for post-warranty repairs. Consider an extended warranty if buying new.")
        }
        return lines.joined(separator: " ")
    }

    private static func worthItBlurb(car: Car, profile: UserProfile) -> String {
        let avg = (car.priceMin + car.priceMax) / 2
        let breakdown = RecommendationEngine.score(car: car, profile: profile)
        let valueLabel: String
        switch breakdown.bestValueScore {
        case 80...: valueLabel = "strong value"
        case 60..<80: valueLabel = "fair value"
        default: valueLabel = "priced for what it is, not bargain territory"
        }
        var lines: [String] = []
        lines.append("At \(car.priceDisplay), the \(car.displayName) is \(valueLabel) — best-value score \(breakdown.bestValueScore)/100.")
        if avg >= profile.budgetMin && avg <= profile.budgetMax {
            lines.append("It sits inside your \(profile.budgetSummary) budget, so yes — worth considering.")
        } else if avg > profile.budgetMax {
            let over = Int(avg - profile.budgetMax)
            lines.append("It's about $\(over.formatted()) above your ceiling. Only stretch if the other fit factors are strong.")
        } else {
            lines.append("It's under your budget — leaves room for a better trim, certified-pre-owned options, or an emergency cushion.")
        }
        return lines.joined(separator: " ")
    }

    private static func comparisonBlurb(a: Car, b: Car, profile: UserProfile) -> String {
        let aBreak = RecommendationEngine.score(car: a, profile: profile)
        let bBreak = RecommendationEngine.score(car: b, profile: profile)

        var lines: [String] = []
        lines.append("**\(a.displayName)** vs **\(b.displayName)** — for your profile:")
        lines.append("")
        lines.append("• Match score: \(aBreak.matchScore) vs \(bBreak.matchScore)")
        lines.append("• Price: \(a.priceDisplay) vs \(b.priceDisplay)")
        lines.append("• Reliability: \(a.reliabilityScore)/10 vs \(b.reliabilityScore)/10")
        lines.append("• Fuel economy: \(a.mpgDisplay) vs \(b.mpgDisplay)")
        lines.append("• Tech: \(a.techScore)/10 vs \(b.techScore)/10")
        lines.append("• Horsepower: \(a.horsepower) vs \(b.horsepower)")
        lines.append("")

        let winner = aBreak.matchScore >= bBreak.matchScore ? a : b
        let other = winner.id == a.id ? b : a
        lines.append("**Bottom line:** the \(winner.displayName) is the better fit for what you told us. Pick the \(other.displayName) only if you prioritize something the match score isn't capturing (styling, a specific feature, dealer proximity).")
        return lines.joined(separator: "\n")
    }

    private static func fuelBlurb(car: Car, profile: UserProfile) -> String {
        let annualMiles = 12_000
        let gasPrice: Double = 3.60
        let combined = Double(car.mpgCity + car.mpgHighway) / 2.0
        let annualCost = Int((Double(annualMiles) / combined) * gasPrice)

        if car.type == .ev {
            return "The \(car.displayName) is electric — \(car.mpgCity) MPGe city, \(car.mpgHighway) MPGe highway. Expect roughly $500–$900/year in electricity for 12,000 miles depending on your rate. Much cheaper to fuel than anything with a tank."
        }
        return "The \(car.displayName) gets \(car.mpgDisplay). At 12,000 miles/year and $3.60/gallon, that's about $\(annualCost.formatted())/year in gas. Fuel-economy score: \(car.fuelEconomyScore)/10."
    }

    private static func safetyBlurb(car: Car, profile: UserProfile) -> String {
        let label: String
        switch car.safetyScore {
        case 9...: label = "top-tier"
        case 8: label = "strong"
        case 7: label = "solid"
        default: label = "decent, not class-leading"
        }
        return "Safety on the \(car.displayName) is \(label) (\(car.safetyScore)/10). Modern driver-assist (adaptive cruise, lane keeping, automatic emergency braking) is standard or widely available. \(profile.useCases.contains(.family) ? "For family duty, this one clears the bar." : "")"
    }

    private static func bestForBlurb(feature: FeaturePriority?, profile: UserProfile) -> (String, [String]) {
        guard let feature = feature else {
            return (fallback(profile: profile), [])
        }
        let ranked = MockCarDatabase.all
            .filter { car in
                let avg = (car.priceMin + car.priceMax) / 2
                return avg >= profile.budgetMin * 0.8 && avg <= profile.budgetMax * 1.1
            }
            .sorted { $0.score(for: feature) > $1.score(for: feature) }
            .prefix(3)

        guard !ranked.isEmpty else {
            return ("I couldn't find a great \(feature.displayName.lowercased()) pick inside your budget. Widen the range in onboarding and try again.", [])
        }

        var lines = ["Top picks for **\(feature.displayName.lowercased())** in your \(profile.budgetSummary) budget:"]
        for (i, car) in ranked.enumerated() {
            lines.append("\(i + 1). \(car.displayName) — \(car.score(for: feature))/10 (\(car.priceDisplay))")
        }
        return (lines.joined(separator: "\n"), ranked.map { $0.id })
    }

    private static func budgetBlurb(car: Car, profile: UserProfile) -> String {
        let avg = (car.priceMin + car.priceMax) / 2
        if avg < profile.budgetMin {
            return "The \(car.displayName) (\(car.priceDisplay)) is below your budget floor of \(profile.budgetSummary). That's usually a green light — look at a better trim or buy certified-pre-owned for extra assurance."
        } else if avg > profile.budgetMax {
            let over = Int(avg - profile.budgetMax)
            return "The \(car.displayName) runs about $\(over.formatted()) over your ceiling. Stretch only if it scores very well on your other priorities, or look for a 2–3 year old example to reset the math."
        } else {
            return "The \(car.displayName) lands neatly inside your \(profile.budgetSummary) budget at \(car.priceDisplay). That leaves room for tax, a modest options package, and a small cushion."
        }
    }

    private static func generalBlurb(car: Car?, profile: UserProfile, userText: String) -> String {
        guard let car = car else { return fallback(profile: profile) }
        return "\(car.summary) Short version: \(car.pros.first ?? "solid all-rounder"). Trade-off: \(car.cons.first ?? "nothing glaring"). Ask me a more specific question — reliability, fuel economy, whether it fits your budget — and I'll get sharper."
    }

    private static func fallback(profile: UserProfile) -> String {
        let starter = profile.isComplete
            ? "I have your profile — \(profile.budgetSummary) budget, \(profile.useCases.isEmpty ? "no specific use case yet" : "focused on " + profile.useCases.map { $0.displayName.lowercased() }.joined(separator: " and "))."
            : "Finish onboarding first and I can give you grounded answers."
        return """
        \(starter)

        Try asking:
        • "Is the Toyota Camry reliable?"
        • "Honda Accord or Toyota Camry?"
        • "Is the Mazda CX-5 worth it for my budget?"
        • "Best for fuel economy?"
        """
    }

    // MARK: - Starter messages

    static func welcome(profile: UserProfile) -> ChatMessage {
        let body: String
        if profile.isComplete {
            body = """
            Hey — I've got your profile loaded. Ask me anything about specific cars, trade-offs, or whether something's worth it for your budget. I'll ground every answer in what you told us during onboarding.
            """
        } else {
            body = """
            Hey — you can ask me about cars, compare two models, or check if something fits your budget. Finishing onboarding first will make my answers much sharper.
            """
        }
        return ChatMessage(role: .assistant, content: body)
    }
}

private extension Int {
    func formatted() -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f.string(from: NSNumber(value: self)) ?? String(self)
    }
}
