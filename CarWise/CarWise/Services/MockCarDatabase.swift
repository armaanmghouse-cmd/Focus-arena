import Foundation

/// Static, embedded catalog. No network. Used by the recommendation engine and chat service.
enum MockCarDatabase {
    static let all: [Car] = [
        // MARK: Sedans
        Car(
            id: "toyota-camry",
            make: "Toyota", model: "Camry",
            yearRange: "2020–2024", type: .sedan,
            priceMin: 18_000, priceMax: 34_000,
            availability: [.new, .used],
            mpgCity: 28, mpgHighway: 39,
            horsepower: 203, seatingCapacity: 5, cargoCubicFeet: 15.1,
            drivetrain: "FWD", transmission: "Automatic",
            reliabilityScore: 9, fuelEconomyScore: 8, techScore: 6,
            luxuryScore: 5, safetyScore: 9, performanceScore: 5, cargoScore: 5,
            commuteFit: 9, familyFit: 8, sportFit: 3, offroadFit: 2,
            roadTripFit: 8, cargoFit: 5,
            pros: ["Bulletproof reliability", "Excellent resale value", "Strong highway MPG", "Standard safety suite"],
            cons: ["Drive feels anonymous", "Interior is functional, not exciting"],
            summary: "The default answer when you want a car that just works for a decade.",
            symbol: "car.side.fill"
        ),
        Car(
            id: "honda-accord",
            make: "Honda", model: "Accord",
            yearRange: "2020–2024", type: .sedan,
            priceMin: 19_000, priceMax: 36_000,
            availability: [.new, .used],
            mpgCity: 29, mpgHighway: 37,
            horsepower: 192, seatingCapacity: 5, cargoCubicFeet: 16.7,
            drivetrain: "FWD", transmission: "CVT",
            reliabilityScore: 9, fuelEconomyScore: 8, techScore: 7,
            luxuryScore: 6, safetyScore: 9, performanceScore: 6, cargoScore: 6,
            commuteFit: 9, familyFit: 8, sportFit: 4, offroadFit: 2,
            roadTripFit: 8, cargoFit: 5,
            pros: ["Best-in-class driving feel for the segment", "Spacious rear seat", "Honda Sensing standard"],
            cons: ["CVT sounds strained under load", "Infotainment could be snappier"],
            summary: "The Camry's slightly sharper cousin — the enthusiast's Toyota.",
            symbol: "car.side.fill"
        ),
        Car(
            id: "honda-civic",
            make: "Honda", model: "Civic",
            yearRange: "2022–2024", type: .sedan,
            priceMin: 17_000, priceMax: 29_000,
            availability: [.new, .used],
            mpgCity: 31, mpgHighway: 40,
            horsepower: 158, seatingCapacity: 5, cargoCubicFeet: 14.8,
            drivetrain: "FWD", transmission: "CVT",
            reliabilityScore: 9, fuelEconomyScore: 9, techScore: 7,
            luxuryScore: 4, safetyScore: 9, performanceScore: 5, cargoScore: 4,
            commuteFit: 9, familyFit: 6, sportFit: 5, offroadFit: 1,
            roadTripFit: 7, cargoFit: 4,
            pros: ["Class-leading fuel economy", "Premium-feeling cabin for the price", "Long ownership record"],
            cons: ["Base engine is modest", "Smaller trunk than mid-size sedans"],
            summary: "The smart-money compact for commuters who want to spend less on gas and repairs.",
            symbol: "car.side.fill"
        ),
        Car(
            id: "toyota-corolla",
            make: "Toyota", model: "Corolla",
            yearRange: "2020–2024", type: .sedan,
            priceMin: 15_000, priceMax: 26_000,
            availability: [.new, .used],
            mpgCity: 32, mpgHighway: 41,
            horsepower: 169, seatingCapacity: 5, cargoCubicFeet: 13.1,
            drivetrain: "FWD", transmission: "CVT",
            reliabilityScore: 10, fuelEconomyScore: 9, techScore: 6,
            luxuryScore: 3, safetyScore: 9, performanceScore: 4, cargoScore: 4,
            commuteFit: 10, familyFit: 6, sportFit: 2, offroadFit: 1,
            roadTripFit: 7, cargoFit: 3,
            pros: ["Cheapest long-term ownership in the segment", "Hybrid trim available", "Proven powertrain"],
            cons: ["Plain styling", "Rear seat is tight for adults"],
            summary: "If 'lowest total cost of ownership' was a car.",
            symbol: "car.side.fill"
        ),
        Car(
            id: "mazda-3",
            make: "Mazda", model: "Mazda3",
            yearRange: "2020–2024", type: .hatchback,
            priceMin: 20_000, priceMax: 32_000,
            availability: [.new, .used],
            mpgCity: 27, mpgHighway: 36,
            horsepower: 186, seatingCapacity: 5, cargoCubicFeet: 20.1,
            drivetrain: "AWD", transmission: "Automatic",
            reliabilityScore: 8, fuelEconomyScore: 7, techScore: 7,
            luxuryScore: 7, safetyScore: 9, performanceScore: 6, cargoScore: 6,
            commuteFit: 8, familyFit: 6, sportFit: 6, offroadFit: 2,
            roadTripFit: 7, cargoFit: 6,
            pros: ["Genuinely premium interior", "Sharp handling", "AWD available"],
            cons: ["Rear visibility is poor", "Infotainment controls take adjustment"],
            summary: "The anti-Corolla: a compact that actually wants to be driven.",
            symbol: "car.side.fill"
        ),
        Car(
            id: "bmw-3-series",
            make: "BMW", model: "3 Series",
            yearRange: "2019–2023", type: .sedan,
            priceMin: 28_000, priceMax: 55_000,
            availability: [.new, .used],
            mpgCity: 26, mpgHighway: 36,
            horsepower: 255, seatingCapacity: 5, cargoCubicFeet: 17.0,
            drivetrain: "RWD", transmission: "Automatic",
            reliabilityScore: 6, fuelEconomyScore: 6, techScore: 9,
            luxuryScore: 8, safetyScore: 8, performanceScore: 9, cargoScore: 5,
            commuteFit: 7, familyFit: 6, sportFit: 9, offroadFit: 2,
            roadTripFit: 8, cargoFit: 5,
            pros: ["Reference-grade driving dynamics", "Strong tech suite", "Turbo power at every trim"],
            cons: ["Premium fuel required", "Out-of-warranty repairs get expensive"],
            summary: "Still the sport-sedan benchmark — if you can stomach the service costs.",
            symbol: "car.side.fill"
        ),
        Car(
            id: "lexus-es",
            make: "Lexus", model: "ES",
            yearRange: "2019–2024", type: .sedan,
            priceMin: 28_000, priceMax: 48_000,
            availability: [.new, .used],
            mpgCity: 25, mpgHighway: 34,
            horsepower: 203, seatingCapacity: 5, cargoCubicFeet: 16.7,
            drivetrain: "FWD", transmission: "Automatic",
            reliabilityScore: 9, fuelEconomyScore: 7, techScore: 7,
            luxuryScore: 9, safetyScore: 9, performanceScore: 5, cargoScore: 5,
            commuteFit: 8, familyFit: 7, sportFit: 4, offroadFit: 2,
            roadTripFit: 9, cargoFit: 5,
            pros: ["Luxury that doesn't break", "Whisper-quiet cabin", "Hybrid trim available"],
            cons: ["Front-wheel drive feels less premium than rivals", "Infotainment trackpad is dated"],
            summary: "The practical luxury pick — Toyota reliability wearing a Lexus suit.",
            symbol: "car.side.fill"
        ),

        // MARK: SUVs
        Car(
            id: "honda-crv",
            make: "Honda", model: "CR-V",
            yearRange: "2020–2024", type: .suv,
            priceMin: 22_000, priceMax: 38_000,
            availability: [.new, .used],
            mpgCity: 28, mpgHighway: 34,
            horsepower: 190, seatingCapacity: 5, cargoCubicFeet: 39.3,
            drivetrain: "AWD", transmission: "CVT",
            reliabilityScore: 9, fuelEconomyScore: 8, techScore: 7,
            luxuryScore: 6, safetyScore: 9, performanceScore: 5, cargoScore: 8,
            commuteFit: 8, familyFit: 9, sportFit: 3, offroadFit: 4,
            roadTripFit: 8, cargoFit: 8,
            pros: ["Huge rear seat", "Easy to live with", "Strong resale"],
            cons: ["Styling is safe", "Not exciting to drive"],
            summary: "The rational family SUV choice. Boring is a feature here.",
            symbol: "car.fill"
        ),
        Car(
            id: "toyota-rav4",
            make: "Toyota", model: "RAV4",
            yearRange: "2020–2024", type: .suv,
            priceMin: 23_000, priceMax: 40_000,
            availability: [.new, .used],
            mpgCity: 27, mpgHighway: 35,
            horsepower: 203, seatingCapacity: 5, cargoCubicFeet: 37.6,
            drivetrain: "AWD", transmission: "Automatic",
            reliabilityScore: 9, fuelEconomyScore: 8, techScore: 7,
            luxuryScore: 5, safetyScore: 9, performanceScore: 5, cargoScore: 8,
            commuteFit: 8, familyFit: 9, sportFit: 3, offroadFit: 5,
            roadTripFit: 8, cargoFit: 8,
            pros: ["Best-selling SUV for a reason", "Hybrid and Prime trims available", "Light off-road capability"],
            cons: ["Ride can be busy", "Road noise on highway"],
            summary: "The default family/all-purpose SUV. Extremely hard to go wrong.",
            symbol: "car.fill"
        ),
        Car(
            id: "mazda-cx5",
            make: "Mazda", model: "CX-5",
            yearRange: "2020–2024", type: .suv,
            priceMin: 24_000, priceMax: 39_000,
            availability: [.new, .used],
            mpgCity: 26, mpgHighway: 31,
            horsepower: 187, seatingCapacity: 5, cargoCubicFeet: 30.9,
            drivetrain: "AWD", transmission: "Automatic",
            reliabilityScore: 8, fuelEconomyScore: 7, techScore: 7,
            luxuryScore: 8, safetyScore: 9, performanceScore: 6, cargoScore: 6,
            commuteFit: 8, familyFit: 8, sportFit: 5, offroadFit: 3,
            roadTripFit: 8, cargoFit: 6,
            pros: ["Best driving feel in the segment", "Near-luxury interior", "Standard AWD"],
            cons: ["Smaller cargo than rivals", "Rear seat fine but not huge"],
            summary: "The 'I don't want to look like I gave up on driving' compact SUV.",
            symbol: "car.fill"
        ),
        Car(
            id: "subaru-outback",
            make: "Subaru", model: "Outback",
            yearRange: "2020–2024", type: .suv,
            priceMin: 25_000, priceMax: 42_000,
            availability: [.new, .used],
            mpgCity: 26, mpgHighway: 33,
            horsepower: 182, seatingCapacity: 5, cargoCubicFeet: 32.5,
            drivetrain: "AWD", transmission: "CVT",
            reliabilityScore: 8, fuelEconomyScore: 7, techScore: 6,
            luxuryScore: 5, safetyScore: 10, performanceScore: 5, cargoScore: 8,
            commuteFit: 7, familyFit: 8, sportFit: 3, offroadFit: 8,
            roadTripFit: 9, cargoFit: 8,
            pros: ["Standard AWD", "Genuinely capable on dirt roads", "Top-tier safety ratings"],
            cons: ["CVT drone under acceleration", "Interior tech is average"],
            summary: "The do-everything wagon for people whose weekends go past the pavement.",
            symbol: "car.fill"
        ),
        Car(
            id: "lexus-rx",
            make: "Lexus", model: "RX",
            yearRange: "2020–2024", type: .suv,
            priceMin: 35_000, priceMax: 62_000,
            availability: [.new, .used],
            mpgCity: 22, mpgHighway: 29,
            horsepower: 275, seatingCapacity: 5, cargoCubicFeet: 32.7,
            drivetrain: "AWD", transmission: "Automatic",
            reliabilityScore: 9, fuelEconomyScore: 6, techScore: 8,
            luxuryScore: 9, safetyScore: 9, performanceScore: 6, cargoScore: 7,
            commuteFit: 7, familyFit: 8, sportFit: 4, offroadFit: 4,
            roadTripFit: 9, cargoFit: 7,
            pros: ["Lexus reliability in a luxury SUV", "Quiet, calm cabin", "Hybrid trims available"],
            cons: ["Not exciting to drive", "Premium fuel recommended on some trims"],
            summary: "Long-term luxury ownership without the service-bay surprises.",
            symbol: "car.fill"
        ),

        // MARK: Trucks
        Car(
            id: "ford-f150",
            make: "Ford", model: "F-150",
            yearRange: "2021–2024", type: .truck,
            priceMin: 33_000, priceMax: 75_000,
            availability: [.new, .used],
            mpgCity: 20, mpgHighway: 26,
            horsepower: 325, seatingCapacity: 5, cargoCubicFeet: 77.4,
            drivetrain: "4WD", transmission: "Automatic",
            reliabilityScore: 7, fuelEconomyScore: 5, techScore: 8,
            luxuryScore: 7, safetyScore: 8, performanceScore: 8, cargoScore: 10,
            commuteFit: 5, familyFit: 7, sportFit: 4, offroadFit: 7,
            roadTripFit: 8, cargoFit: 10,
            pros: ["Massive tow and payload", "Onboard generator on Hybrid trim", "Trim range from work to luxury"],
            cons: ["Tight parking in cities", "Fuel costs add up"],
            summary: "The truck that does everything — from jobsite to family hauler.",
            symbol: "truck.pickup.side.fill"
        ),
        Car(
            id: "toyota-tacoma",
            make: "Toyota", model: "Tacoma",
            yearRange: "2020–2023", type: .truck,
            priceMin: 28_000, priceMax: 48_000,
            availability: [.new, .used],
            mpgCity: 18, mpgHighway: 22,
            horsepower: 278, seatingCapacity: 5, cargoCubicFeet: 39.9,
            drivetrain: "4WD", transmission: "Automatic",
            reliabilityScore: 9, fuelEconomyScore: 4, techScore: 6,
            luxuryScore: 5, safetyScore: 8, performanceScore: 7, cargoScore: 7,
            commuteFit: 5, familyFit: 6, sportFit: 4, offroadFit: 10,
            roadTripFit: 7, cargoFit: 7,
            pros: ["Legendary resale value", "TRD Off-Road is genuinely capable", "Small enough for real-world parking"],
            cons: ["Thirsty", "Interior falls behind rivals"],
            summary: "The mid-size truck people keep for a decade.",
            symbol: "truck.pickup.side.fill"
        ),

        // MARK: Sport / Coupe
        Car(
            id: "mazda-miata",
            make: "Mazda", model: "MX-5 Miata",
            yearRange: "2019–2024", type: .coupe,
            priceMin: 27_000, priceMax: 38_000,
            availability: [.new, .used],
            mpgCity: 26, mpgHighway: 35,
            horsepower: 181, seatingCapacity: 2, cargoCubicFeet: 4.6,
            drivetrain: "RWD", transmission: "Manual",
            reliabilityScore: 9, fuelEconomyScore: 8, techScore: 6,
            luxuryScore: 5, safetyScore: 7, performanceScore: 8, cargoScore: 1,
            commuteFit: 5, familyFit: 1, sportFit: 10, offroadFit: 1,
            roadTripFit: 5, cargoFit: 1,
            pros: ["Pure driving joy per dollar", "Convertible top", "Cheap to maintain"],
            cons: ["Two seats only", "Impractical for daily duties if you haul anything"],
            summary: "The correct answer to 'what's the most fun car you can buy new?'.",
            symbol: "car.side.fill"
        ),
        Car(
            id: "ford-mustang-gt",
            make: "Ford", model: "Mustang GT",
            yearRange: "2020–2023", type: .coupe,
            priceMin: 32_000, priceMax: 52_000,
            availability: [.new, .used],
            mpgCity: 15, mpgHighway: 24,
            horsepower: 460, seatingCapacity: 4, cargoCubicFeet: 13.5,
            drivetrain: "RWD", transmission: "Automatic",
            reliabilityScore: 7, fuelEconomyScore: 3, techScore: 7,
            luxuryScore: 5, safetyScore: 7, performanceScore: 9, cargoScore: 4,
            commuteFit: 4, familyFit: 3, sportFit: 9, offroadFit: 1,
            roadTripFit: 6, cargoFit: 3,
            pros: ["V8 muscle at a reasonable price", "Manual still offered", "Loud and proud"],
            cons: ["Bad in snow", "Back seat is theoretical"],
            summary: "American V8 character without the exotic-car price tag.",
            symbol: "car.side.fill"
        ),

        // MARK: EVs
        Car(
            id: "tesla-model-3",
            make: "Tesla", model: "Model 3",
            yearRange: "2020–2024", type: .ev,
            priceMin: 30_000, priceMax: 52_000,
            availability: [.new, .used],
            mpgCity: 132, mpgHighway: 126,
            horsepower: 283, seatingCapacity: 5, cargoCubicFeet: 19.8,
            drivetrain: "RWD", transmission: "Automatic",
            reliabilityScore: 7, fuelEconomyScore: 10, techScore: 10,
            luxuryScore: 7, safetyScore: 9, performanceScore: 8, cargoScore: 6,
            commuteFit: 10, familyFit: 7, sportFit: 7, offroadFit: 2,
            roadTripFit: 8, cargoFit: 6,
            pros: ["Supercharger network is unmatched", "Low running costs", "Software-first experience"],
            cons: ["Minimal physical controls", "Service wait times vary by region"],
            summary: "The EV benchmark — especially if you take road trips.",
            symbol: "bolt.car.fill"
        ),
        Car(
            id: "hyundai-ioniq-5",
            make: "Hyundai", model: "Ioniq 5",
            yearRange: "2022–2024", type: .ev,
            priceMin: 38_000, priceMax: 56_000,
            availability: [.new, .used],
            mpgCity: 132, mpgHighway: 98,
            horsepower: 225, seatingCapacity: 5, cargoCubicFeet: 27.2,
            drivetrain: "AWD", transmission: "Automatic",
            reliabilityScore: 8, fuelEconomyScore: 10, techScore: 9,
            luxuryScore: 8, safetyScore: 9, performanceScore: 7, cargoScore: 7,
            commuteFit: 9, familyFit: 8, sportFit: 5, offroadFit: 2,
            roadTripFit: 7, cargoFit: 7,
            pros: ["800V charging — very fast DC fills", "Distinctive design", "Roomy flat-floor interior"],
            cons: ["Non-Tesla charging network still maturing", "Range varies with battery size"],
            summary: "If the Model 3 feels too austere, this is the EV with personality.",
            symbol: "bolt.car.fill"
        ),

        // MARK: Minivan
        Car(
            id: "toyota-sienna",
            make: "Toyota", model: "Sienna",
            yearRange: "2021–2024", type: .minivan,
            priceMin: 35_000, priceMax: 52_000,
            availability: [.new, .used],
            mpgCity: 36, mpgHighway: 36,
            horsepower: 245, seatingCapacity: 8, cargoCubicFeet: 101.0,
            drivetrain: "AWD", transmission: "CVT",
            reliabilityScore: 9, fuelEconomyScore: 9, techScore: 7,
            luxuryScore: 6, safetyScore: 9, performanceScore: 5, cargoScore: 10,
            commuteFit: 6, familyFit: 10, sportFit: 2, offroadFit: 2,
            roadTripFit: 10, cargoFit: 10,
            pros: ["Hybrid-only: 36 MPG in a minivan", "AWD available", "Best-in-class space"],
            cons: ["Not exciting to drive", "You drive a minivan"],
            summary: "The honest family vehicle — more space, fewer compromises than a 3-row SUV.",
            symbol: "car.2.fill"
        )
    ]

    static let allBrands: [String] = {
        Array(Set(all.map { $0.make })).sorted()
    }()

    static func car(id: String) -> Car? {
        all.first(where: { $0.id == id })
    }

    static func cars(ids: [String]) -> [Car] {
        ids.compactMap { car(id: $0) }
    }

    /// Find cars by fuzzy name match — used by chat parsing.
    static func match(query: String) -> [Car] {
        let q = query.lowercased()
        return all.filter {
            q.contains($0.make.lowercased()) ||
            q.contains($0.model.lowercased()) ||
            q.contains($0.displayName.lowercased())
        }
    }
}
