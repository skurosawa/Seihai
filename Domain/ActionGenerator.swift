import Foundation

enum ActionGenerator {

    /// thoughts（文字列配列）から「次の一手」を1つだけ返す
    /// - 方針：要約や自動改変はしない。最も行動らしい行を「そのまま」採用する。
    /// - フォールバック：弱い場合は固定テンプレを返す。
    static func generate(from rawThoughts: [String]) -> String {
        let thoughts = normalize(rawThoughts)
        guard !thoughts.isEmpty else { return "" }

        var bestText = ""
        var bestScore = Int.min

        for t in thoughts {
            let s = score(thought: t)
            if s > bestScore {
                bestScore = s
                bestText = t
            }
        }

        // 閾値：低いなら固定テンプレ（改変しない思想）
        if bestScore >= 4 {
            return bestText
        } else {
            return "次にやることを1つ決める"
        }
    }

    // MARK: - Normalize

    private static func normalize(_ raw: [String]) -> [String] {
        raw.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { t in
                // UI的に気持ちいい最小整形（意味改変はしない）
                t.hasSuffix("。") ? String(t.dropLast()) : t
            }
            .filter { !$0.isEmpty }
    }

    // MARK: - Scoring (gentle improved)

    /// 「行動らしさ」を軽量スコアで判定（過度に賢くしない）
    private static func score(thought t: String) -> Int {
        var score = 0

        // 行動キーワード（少しだけ拡張）
        let strongKeywords = [
            "連絡", "送る", "予約", "片付け", "購入",
            "作る", "修正", "決める", "調べる",
            "見る", "読む", "書く"
        ]
        if strongKeywords.contains(where: { t.contains($0) }) {
            score += 5
        }

        // 行動っぽい終わり（そのまま採用を優先）
        let actionEnds = [
            "する", "やる", "行く", "買う",
            "決める", "書く", "片付ける",
            "整理する", "調べる", "確認する"
        ]
        if actionEnds.contains(where: { t.hasSuffix($0) }) {
            score += 4
        }

        // 意志/指示っぽさ（含みで少し加点）
        let intentionTokens = ["しよう", "したい", "して", "すべき", "やろう"]
        if intentionTokens.contains(where: { t.contains($0) }) {
            score += 2
        }

        // 具体性（数字）
        if t.range(of: #"\d"#, options: .regularExpression) != nil {
            score += 3
        }

        // 具体性（日時っぽい語）
        if t.range(of: #"今日|明日|午前|午後|時|分"#,
                   options: .regularExpression) != nil {
            score += 3
        }

        // 長さ（自然な範囲を少し広めに）
        let len = t.count
        if (8...28).contains(len) {
            score += 2
        } else if (29...35).contains(len) {
            score += 1
        }
        if len >= 50 {
            score -= 2
        }

        // 抽象/感情だけは弱める（強すぎない）
        let negatives = [
            "無理", "できない", "つらい",
            "疲れた", "やめたい", "嫌", "憂鬱"
        ]
        if negatives.contains(where: { t.contains($0) }) {
            score -= 3
        }

        // 否定だけっぽい短文
        if t.contains("できない") && len <= 12 {
            score -= 2
        }

        return score
    }
}
