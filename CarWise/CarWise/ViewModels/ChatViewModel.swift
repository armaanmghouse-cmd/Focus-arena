import Foundation
import SwiftUI

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var draftText: String = ""
    @Published var isResponding: Bool = false

    unowned let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    var messages: [ChatMessage] { appState.chatMessages }

    func sendDraftIfPossible() async {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isResponding else { return }

        let userMessage = ChatMessage(role: .user, content: trimmed)
        appState.appendChatMessage(userMessage)
        draftText = ""

        await respond(to: trimmed)
    }

    func send(text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isResponding else { return }
        appState.appendChatMessage(ChatMessage(role: .user, content: trimmed))
        await respond(to: trimmed)
    }

    private func respond(to userText: String) async {
        isResponding = true
        // Simulated thinking delay — keeps the "typing" indicator meaningful.
        try? await Task.sleep(nanoseconds: 600_000_000)
        let reply = ChatService.answer(to: userText, profile: appState.profile)
        appState.appendChatMessage(reply)
        isResponding = false
    }

    func seedWelcomeIfNeeded() {
        if appState.chatMessages.isEmpty {
            let welcome = ChatService.welcome(profile: appState.profile)
            appState.appendChatMessage(welcome)
        }
    }

    func clear() {
        appState.clearChat()
        seedWelcomeIfNeeded()
    }

    // Suggested prompts — change with profile state
    var suggestedPrompts: [String] {
        if let first = appState.savedCars.first,
           let car = MockCarDatabase.car(id: first.id) {
            return [
                "Is the \(car.displayName) reliable?",
                "Is the \(car.displayName) worth it for my budget?",
                "Best for fuel economy?"
            ]
        }
        return [
            "Best for daily commute?",
            "Honda Accord or Toyota Camry?",
            "Is the Mazda CX-5 worth it for my budget?"
        ]
    }
}
