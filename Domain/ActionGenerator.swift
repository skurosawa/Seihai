import Foundation

enum ActionGenerator {

    static func generate(from thoughts: [Thought]) -> [ActionCard] {
        let texts = thoughts
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !texts.isEmpty else {
            return [
                ActionCard(title: "まず1つだけ", body: "思考を1つ入力してみよう。短くてOK。")
            ]
        }

        // 1) 今日やる1つ（先頭を採用）
        let primary = texts.first!

        // 2) 5分タスク（短いものを優先）
        let quick = texts
            .sorted { $0.count < $1.count }
            .first ?? primary

        // 3) 捨てる/保留（最後を採用）
        let later = texts.last!

        return [
            ActionCard(title: "今日やる1つ", body: primary),
            ActionCard(title: "5分で着手", body: quick),
            ActionCard(title: "保留 or 捨てる", body: later)
        ]
    }
}

