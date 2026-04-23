import Foundation

enum BookingStatus: String, Codable, CaseIterable {
    case confirmed, pending, cancelled, completed
}

enum BookingTopic: String, Codable, CaseIterable, Identifiable {
    case firstTimeBuyer
    case negotiation
    case leaseVsBuy
    case tradeInReview
    case specificCar
    case general

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .firstTimeBuyer: return "First-time buyer"
        case .negotiation: return "Price negotiation strategy"
        case .leaseVsBuy: return "Lease vs. buy decision"
        case .tradeInReview: return "Trade-in review"
        case .specificCar: return "Advice on a specific car"
        case .general: return "General consulting"
        }
    }
}

struct Booking: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var durationMinutes: Int
    var topic: BookingTopic
    var notes: String
    var phone: String
    var status: BookingStatus
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date,
        durationMinutes: Int = 30,
        topic: BookingTopic,
        notes: String = "",
        phone: String,
        status: BookingStatus = .confirmed,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
        self.topic = topic
        self.notes = notes
        self.phone = phone
        self.status = status
        self.createdAt = createdAt
    }
}
