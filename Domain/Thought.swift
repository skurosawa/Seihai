import Foundation

struct Thought: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    var createdAt: Date

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
    }
}
