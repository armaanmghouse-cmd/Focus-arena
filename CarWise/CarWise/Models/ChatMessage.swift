import Foundation

enum ChatRole: String, Codable {
    case user
    case assistant
    case system
}

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: UUID
    let role: ChatRole
    let content: String
    let timestamp: Date
    var referencedCarIds: [String]
    var isTyping: Bool

    init(
        id: UUID = UUID(),
        role: ChatRole,
        content: String,
        timestamp: Date = Date(),
        referencedCarIds: [String] = [],
        isTyping: Bool = false
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.referencedCarIds = referencedCarIds
        self.isTyping = isTyping
    }
}
