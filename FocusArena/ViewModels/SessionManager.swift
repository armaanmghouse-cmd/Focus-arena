import Foundation
import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class SessionManager: ObservableObject {
    enum Phase: Equatable {
        case idle
        case running
        case warning(remainingGrace: TimeInterval)
        case succeeded(FocusSession)
        case failed(FocusSession)
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var activeSession: FocusSession?
    @Published private(set) var elapsed: TimeInterval = 0

    private weak var profileStore: ProfileStore?
    private weak var settingsStore: SettingsStore?
    private weak var historyStore: HistoryStore?

    private var tickTimer: Timer?
    private var graceTimer: Timer?
    private var startReferenceDate: Date?
    private var accumulatedBeforePause: TimeInterval = 0
    private var leftAt: Date?
    private let activeSessionFilename = "active_session.json"

    func bind(profile: ProfileStore, settings: SettingsStore, history: HistoryStore) {
        self.profileStore = profile
        self.settingsStore = settings
        self.historyStore = history
    }

    var timeRemaining: TimeInterval {
        guard let session = activeSession else { return 0 }
        return max(0, session.plannedDuration - elapsed)
    }

    var progress: Double {
        guard let session = activeSession, session.plannedDuration > 0 else { return 0 }
        return min(1, elapsed / session.plannedDuration)
    }

    func start(task: String, duration: TimeInterval) {
        guard let settings = settingsStore else { return }
        cleanupTimers()

        let session = FocusSession(
            task: task.isEmpty ? "Deep Work" : task,
            startedAt: Date(),
            plannedDuration: duration,
            strictMode: settings.settings.strictMode
        )
        activeSession = session
        elapsed = 0
        accumulatedBeforePause = 0
        startReferenceDate = Date()
        leftAt = nil
        phase = .running

        persistActive(session)
        startTickTimer()
        keepScreenAwake(true)
        NotificationService.shared.scheduleSessionCompletion(after: duration, task: session.task)
        if settings.settings.soundEnabled {
            SoundService.shared.startAmbient()
        }
        HapticService.shared.impact(.heavy)
    }

    private func keepScreenAwake(_ awake: Bool) {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = awake
        #endif
    }

    func surrender() {
        finishAsFailure(reason: .userQuit)
    }

    func dismissResultScreen() {
        phase = .idle
        activeSession = nil
        elapsed = 0
    }

    // MARK: - Lifecycle integration

    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        guard let session = activeSession else { return }
        switch phase {
        case .running, .warning:
            switch newPhase {
            case .active:
                handleReturnedToForeground()
            case .inactive:
                handleLeftForeground(strictReason: .interrupted, session: session)
            case .background:
                handleLeftForeground(strictReason: .backgrounded, session: session)
            @unknown default:
                break
            }
        default:
            break
        }
    }

    private func handleLeftForeground(strictReason: FocusSession.FailureReason, session: FocusSession) {
        guard let settings = settingsStore else { return }

        if settings.settings.strictMode || settings.settings.gracePeriod <= 0 {
            finishAsFailure(reason: strictReason)
            return
        }

        if leftAt == nil {
            leftAt = Date()
            HapticService.shared.notify(.warning)
            startGraceTimer(reason: strictReason)
        }
    }

    private func handleReturnedToForeground() {
        guard let leftAt else { return }
        let awayFor = Date().timeIntervalSince(leftAt)
        let grace = settingsStore?.settings.gracePeriod ?? 0

        graceTimer?.invalidate()
        graceTimer = nil
        self.leftAt = nil

        if awayFor > grace {
            finishAsFailure(reason: .leftApp)
        } else {
            phase = .running
            HapticService.shared.impact(.soft)
        }
    }

    func recoverIfNeeded() {
        let stored = PersistenceService.shared.load(FocusSession?.self, from: activeSessionFilename, fallback: nil)
        guard let session = stored else { return }
        var failed = session
        failed.outcome = .failed
        failed.failureReason = .leftApp
        failed.endedAt = Date()
        failed.actualDuration = min(session.plannedDuration, Date().timeIntervalSince(session.startedAt))
        failed.xpEarned = 0
        historyStore?.update(failed)
        profileStore?.registerFailure(session: failed)
        clearPersistedActive()
        phase = .failed(failed)
        activeSession = failed
    }

    // MARK: - Timers

    private func startTickTimer() {
        tickTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    private func tick() {
        guard let session = activeSession, let start = startReferenceDate else { return }
        elapsed = accumulatedBeforePause + Date().timeIntervalSince(start)
        if elapsed >= session.plannedDuration {
            finishAsSuccess()
        }
    }

    private func startGraceTimer(reason: FocusSession.FailureReason) {
        let grace = settingsStore?.settings.gracePeriod ?? 0
        guard grace > 0 else { return }
        phase = .warning(remainingGrace: grace)
        graceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self, let leftAt = self.leftAt else {
                    timer.invalidate()
                    return
                }
                let elapsedAway = Date().timeIntervalSince(leftAt)
                let remaining = grace - elapsedAway
                if remaining <= 0 {
                    timer.invalidate()
                    self.finishAsFailure(reason: reason)
                } else {
                    self.phase = .warning(remainingGrace: remaining)
                }
            }
        }
    }

    private func cleanupTimers() {
        tickTimer?.invalidate(); tickTimer = nil
        graceTimer?.invalidate(); graceTimer = nil
        keepScreenAwake(false)
    }

    // MARK: - Outcomes

    private func finishAsSuccess() {
        guard var session = activeSession else { return }
        cleanupTimers()
        session.endedAt = Date()
        session.actualDuration = session.plannedDuration
        session.outcome = .success
        session.xpEarned = Self.xpReward(for: session.plannedDuration, strict: session.strictMode)

        historyStore?.append(session)
        profileStore?.registerSuccess(session: session)
        clearPersistedActive()
        SoundService.shared.stopAmbient()
        NotificationService.shared.cancelSessionCompletion()
        HapticService.shared.notify(.success)

        activeSession = session
        phase = .succeeded(session)
    }

    private func finishAsFailure(reason: FocusSession.FailureReason) {
        guard var session = activeSession else { return }
        cleanupTimers()
        session.endedAt = Date()
        session.actualDuration = elapsed
        session.outcome = .failed
        session.failureReason = reason
        session.xpEarned = 0

        historyStore?.append(session)
        profileStore?.registerFailure(session: session)
        clearPersistedActive()
        SoundService.shared.stopAmbient()
        NotificationService.shared.cancelSessionCompletion()
        HapticService.shared.notify(.error)

        activeSession = session
        phase = .failed(session)
    }

    // MARK: - Persistence helpers

    private func persistActive(_ session: FocusSession?) {
        PersistenceService.shared.save(session, to: activeSessionFilename)
    }

    private func clearPersistedActive() {
        PersistenceService.shared.save(FocusSession?.none, to: activeSessionFilename)
    }

    static func xpReward(for duration: TimeInterval, strict: Bool) -> Int {
        let base = Int((duration / 60).rounded()) * 4
        let bonus = strict ? Int(Double(base) * 0.5) : 0
        return max(10, base + bonus)
    }
}
