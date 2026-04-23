import Foundation

struct Car: Codable, Identifiable, Equatable, Hashable {
    let id: String            // slug, e.g. "honda-accord"
    let make: String
    let model: String
    let yearRange: String     // e.g. "2020–2024"
    let type: VehicleType
    let priceMin: Double
    let priceMax: Double
    let availability: [Condition]   // e.g. [.new, .used]

    // Specs (typical / representative)
    let mpgCity: Int
    let mpgHighway: Int
    let horsepower: Int
    let seatingCapacity: Int
    let cargoCubicFeet: Double
    let drivetrain: String          // "FWD", "AWD", "RWD", "4WD"
    let transmission: String        // "Automatic", "CVT", "Manual"

    // Characteristic scores (0–10)
    let reliabilityScore: Int
    let fuelEconomyScore: Int
    let techScore: Int
    let luxuryScore: Int
    let safetyScore: Int
    let performanceScore: Int
    let cargoScore: Int

    // Use-case fit (0–10)
    let commuteFit: Int
    let familyFit: Int
    let sportFit: Int
    let offroadFit: Int
    let roadTripFit: Int
    let cargoFit: Int

    let pros: [String]
    let cons: [String]
    let summary: String
    let symbol: String    // SF symbol used as placeholder visual

    var displayName: String { "\(make) \(model)" }

    var priceDisplay: String {
        let fmt: (Double) -> String = { v in
            if v >= 1000 { return "$\(Int(v / 1000))k" }
            return "$\(Int(v))"
        }
        return "\(fmt(priceMin)) – \(fmt(priceMax))"
    }

    var mpgDisplay: String { "\(mpgCity)/\(mpgHighway) mpg" }

    func score(for feature: FeaturePriority) -> Int {
        switch feature {
        case .fuelEconomy: return fuelEconomyScore
        case .reliability: return reliabilityScore
        case .tech: return techScore
        case .luxury: return luxuryScore
        case .safety: return safetyScore
        case .performance: return performanceScore
        case .cargo: return cargoScore
        }
    }

    func fit(for useCase: UseCase) -> Int {
        switch useCase {
        case .commute: return commuteFit
        case .family: return familyFit
        case .sport: return sportFit
        case .offroad: return offroadFit
        case .roadTrip: return roadTripFit
        case .cargo: return cargoFit
        }
    }
}
