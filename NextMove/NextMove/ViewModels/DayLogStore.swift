import Foundation
import Combine

final class DayLogStore: ObservableObject {
    @Published private(set) var logs: [DayLog] = []

    private let filename = "nextmove.daylogs.json"

    init() {
        self.logs = PersistenceService.shared.load(
            [DayLog].self,
            from: filename,
            fallback: []
        )
        ensureTodayExists()
    }

    func ensureTodayExists() {
        if !logs.contains(where: { DayLog.isSameDay($0.date, Date()) }) {
            logs.append(DayLog(date: DayLog.startOfDay()))
            persist()
        }
    }

    var today: DayLog {
        if let existing = logs.first(where: { DayLog.isSameDay($0.date, Date()) }) {
            return existing
        }
        return DayLog(date: DayLog.startOfDay())
    }

    var yesterday: DayLog? {
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return logs.first(where: { DayLog.isSameDay($0.date, yesterdayDate) })
    }

    func upsert(_ log: DayLog) {
        if let idx = logs.firstIndex(where: { DayLog.isSameDay($0.date, log.date) }) {
            logs[idx] = log
        } else {
            logs.append(log)
        }
        persist()
    }

    func updateToday(_ mutate: (inout DayLog) -> Void) {
        ensureTodayExists()
        guard var log = logs.first(where: { DayLog.isSameDay($0.date, Date()) }) else { return }
        mutate(&log)
        log.score = ScoringService.score(for: log)
        upsert(log)
    }

    func recentLogs(limit: Int = 14) -> [DayLog] {
        Array(logs.sorted(by: { $0.date > $1.date }).prefix(limit))
    }

    func allReflections() -> [Reflection] {
        logs.compactMap { $0.reflection }.filter { !$0.isEmpty }
    }

    private func persist() {
        PersistenceService.shared.save(logs, to: filename)
    }
}
