import Foundation

struct SeihaiSnapshot: Codable {
    var draftText: String
    var thoughts: [Thought]
    var actionText: String
}
