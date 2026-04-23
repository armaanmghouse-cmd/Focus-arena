import Foundation
import Combine

@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var sessions: [FocusSession]

    private let filename = "sessions.json"

    init() {
        self.sessions = PersistenceService.shared.load([FocusSession].self, from: filename, fallback: [])
    }

    func append(_ session: FocusSession) {
        sessions.insert(session, at: 0)
        save()
    }

    func update(_ session: FocusSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
            save()
        } else {
            append(session)
        }
    }

    func sessions(on day: Date) -> [FocusSession] {
        let cal = Calendar.current
        return sessions.filter { cal.isDate($0.startedAt, inSameDayAs: day) }
    }

    func successCount(on day: Date) -> Int {
        sessions(on: day).filter { $0.outcome == .success }.count
    }

    func focusTime(on day: Date) -> TimeInterval {
        sessions(on: day).filter { $0.outcome == .success }.reduce(0) { $0 + $1.actualDuration }
    }

    func dailyTotals(lastDays: Int = 7) -> [DailyTotal] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<lastDays).reversed().map { offset in
            let day = cal.date(byAdding: .day, value: -offset, to: today) ?? today
            return DailyTotal(date: day, focusSeconds: focusTime(on: day), successCount: successCount(on: day))
        }
    }

    private func save() {
        PersistenceService.shared.save(sessions, to: filename)
    }
}

struct DailyTotal: Identifiable {
    var id: Date { date }
    let date: Date
    let focusSeconds: TimeInterval
    let successCount: Int
}
