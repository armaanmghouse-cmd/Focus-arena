import Foundation

// MARK: - Enums

enum VehicleType: String, Codable, CaseIterable, Identifiable {
    case sedan, suv, truck, coupe, hatchback, minivan, ev

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sedan: return "Sedan"
        case .suv: return "SUV"
        case .truck: return "Truck"
        case .coupe: return "Coupe"
        case .hatchback: return "Hatchback"
        case .minivan: return "Minivan"
        case .ev: return "EV"
        }
    }

    var systemImage: String {
        switch self {
        case .sedan: return "car.side.fill"
        case .suv: return "car.fill"
        case .truck: return "truck.pickup.side.fill"
        case .coupe: return "car.side.fill"
        case .hatchback: return "car.side.fill"
        case .minivan: return "car.2.fill"
        case .ev: return "bolt.car.fill"
        }
    }
}

enum Condition: String, Codable, CaseIterable, Identifiable {
    case new, used, either

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .new: return "New"
        case .used: return "Used"
        case .either: return "Either"
        }
    }
}

enum UseCase: String, Codable, CaseIterable, Identifiable {
    case commute, family, sport, offroad, roadTrip, cargo

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .commute: return "Daily Commute"
        case .family: return "Family"
        case .sport: return "Sport / Fun"
        case .offroad: return "Off-road"
        case .roadTrip: return "Road Trips"
        case .cargo: return "Hauling / Cargo"
        }
    }

    var systemImage: String {
        switch self {
        case .commute: return "clock.fill"
        case .family: return "person.3.fill"
        case .sport: return "flame.fill"
        case .offroad: return "mountain.2.fill"
        case .roadTrip: return "map.fill"
        case .cargo: return "shippingbox.fill"
        }
    }
}

enum FeaturePriority: String, Codable, CaseIterable, Identifiable {
    case fuelEconomy, reliability, tech, luxury, safety, performance, cargo

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .fuelEconomy: return "Fuel Economy"
        case .reliability: return "Reliability"
        case .tech: return "Tech"
        case .luxury: return "Luxury"
        case .safety: return "Safety"
        case .performance: return "Performance"
        case .cargo: return "Cargo Space"
        }
    }

    var systemImage: String {
        switch self {
        case .fuelEconomy: return "fuelpump.fill"
        case .reliability: return "checkmark.shield.fill"
        case .tech: return "cpu.fill"
        case .luxury: return "sparkles"
        case .safety: return "airbag.fill"
        case .performance: return "speedometer"
        case .cargo: return "shippingbox.fill"
        }
    }
}

enum OwnershipLength: String, Codable, CaseIterable, Identifiable {
    case short, medium, long

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .short: return "< 3 years"
        case .medium: return "3–6 years"
        case .long: return "6+ years"
        }
    }
}

// MARK: - UserProfile

struct UserProfile: Codable, Equatable {
    var budgetMin: Double
    var budgetMax: Double
    var vehicleTypes: Set<VehicleType>
    var condition: Condition
    var useCases: Set<UseCase>
    var featurePriorities: Set<FeaturePriority>
    var ownershipLength: OwnershipLength
    var preferredBrands: Set<String>
    var isComplete: Bool
    var completedAt: Date?

    static let empty = UserProfile(
        budgetMin: 20_000,
        budgetMax: 40_000,
        vehicleTypes: [],
        condition: .either,
        useCases: [],
        featurePriorities: [],
        ownershipLength: .long,
        preferredBrands: [],
        isComplete: false,
        completedAt: nil
    )

    var budgetSummary: String {
        let fmt: (Double) -> String = { v in
            if v >= 1000 { return "$\(Int(v / 1000))k" }
            return "$\(Int(v))"
        }
        return "\(fmt(budgetMin)) – \(fmt(budgetMax))"
    }
}
