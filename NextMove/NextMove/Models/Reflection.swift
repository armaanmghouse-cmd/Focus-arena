import Foundation

struct Reflection: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var regret: String
    var win: String
    var tags: [String]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        regret: String = "",
        win: String = "",
        tags: [String] = []
    ) {
        self.id = id
        self.date = date
        self.regret = regret
        self.win = win
        self.tags = tags
    }

    var isEmpty: Bool {
        regret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        win.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
