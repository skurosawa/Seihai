import Foundation

enum ActionGenerator {
    static func generate(from thoughts: [Thought]) -> String {
        let texts = thoughts
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !texts.isEmpty else { return "" }

        // Web版準拠の「次の一手」：まずは最上段（=整理後の先頭）を採用
        // ※将来ロジックを賢くしても、返すのは常に1本の文字列
        return texts.first ?? ""
    }
}
