import Foundation
import Combine

@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profile: UserProfile

    private let filename = "profile.json"

    init() {
        self.profile = PersistenceService.shared.load(UserProfile.self, from: filename, fallback: .default)
    }

    func registerSuccess(session: FocusSession) {
        var p = profile
        p.totalXP += session.xpEarned
        p.totalSuccessfulSessions += 1
        p.totalFocusTime += session.actualDuration
        p.currentStreak = updatedStreak(after: session.startedAt, current: p.currentStreak, last: p.lastSessionDate)
        p.longestStreak = max(p.longestStreak, p.currentStreak)
        p.lastSessionDate = session.startedAt
        profile = p
        save()
    }

    func registerFailure(session: FocusSession) {
        var p = profile
        p.totalFailedSessions += 1
        let penalty = min(p.totalXP, max(20, session.xpEarned))
        p.totalXP = max(0, p.totalXP - penalty)
        p.currentStreak = 0
        profile = p
        save()
    }

    private func updatedStreak(after date: Date, current: Int, last: Date?) -> Int {
        let cal = Calendar.current
        guard let last else { return 1 }
        if cal.isDate(date, inSameDayAs: last) { return max(current, 1) }
        if let yesterday = cal.date(byAdding: .day, value: -1, to: cal.startOfDay(for: date)),
           cal.isDate(yesterday, inSameDayAs: last) {
            return current + 1
        }
        return 1
    }

    private func save() {
        PersistenceService.shared.save(profile, to: filename)
    }
}
