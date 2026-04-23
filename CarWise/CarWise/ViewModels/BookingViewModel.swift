import Foundation
import SwiftUI

@MainActor
final class BookingViewModel: ObservableObject {

    @Published var selectedDate: Date = BookingViewModel.defaultInitialDay()
    @Published var selectedSlotIndex: Int?
    @Published var topic: BookingTopic = .firstTimeBuyer
    @Published var phone: String = ""
    @Published var notes: String = ""
    @Published var showingConfirmation = false
    @Published var lastBooking: Booking?

    unowned let appState: AppState
    init(appState: AppState) { self.appState = appState }

    // MARK: - Slot generation (mock availability)

    /// Mock availability: 10:00, 11:00, 13:00, 14:30, 16:00, 17:30 on weekdays.
    static let baseHours: [(hour: Int, minute: Int)] = [
        (10, 0), (11, 0), (13, 0), (14, 30), (16, 0), (17, 30)
    ]

    var availableSlots: [Date] {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        guard let day = calendar.date(from: comps) else { return [] }

        let weekday = calendar.component(.weekday, from: day)
        // 1 = Sunday, 7 = Saturday. Simulate "no weekends".
        guard (2...6).contains(weekday) else { return [] }

        return Self.baseHours.compactMap { h in
            calendar.date(bySettingHour: h.hour, minute: h.minute, second: 0, of: day)
        }.filter { $0 > Date() }
    }

    func selectSlot(_ index: Int) {
        selectedSlotIndex = index
    }

    var canBook: Bool {
        guard let i = selectedSlotIndex, availableSlots.indices.contains(i) else { return false }
        return phone.count >= 7
    }

    func book() {
        guard let i = selectedSlotIndex, availableSlots.indices.contains(i) else { return }
        let booking = Booking(
            date: availableSlots[i],
            durationMinutes: 30,
            topic: topic,
            notes: notes,
            phone: phone,
            status: .confirmed
        )
        appState.book(booking)
        lastBooking = booking
        showingConfirmation = true
        resetForm()
    }

    func resetForm() {
        selectedSlotIndex = nil
        notes = ""
    }

    // MARK: - Helpers

    static func defaultInitialDay() -> Date {
        let cal = Calendar.current
        var date = Date()
        // Advance to next weekday
        while true {
            let weekday = cal.component(.weekday, from: date)
            if (2...6).contains(weekday) { break }
            date = cal.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return date
    }

    func formattedSlot(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        return f.string(from: date)
    }
}
