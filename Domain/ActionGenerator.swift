import Foundation

enum ActionGenerator {

    static func generate(from rawThoughts: [String]) -> String {
        let thoughts = normalize(rawThoughts)
        guard !thoughts.isEmpty else { return "" }

        var bestText: String = ""
        var bestScore: Int = Int.min

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

    private static func normalize(_ raw: [String]) -> [String] {
        raw.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.hasSuffix("。") ? String($0.dropLast()) : $0 }
            .filter { !$0.isEmpty }
    }

    private static func score(thought t: String) -> Int {
        var score = 0

        // 行動キーワード（含まれてたら強い）
        let actionKeywords = [
            "確認", "連絡", "返信", "送る", "提出", "予約", "片付け", "整理",
            "購入", "支払い", "作る", "修正", "更新", "決める", "メモ", "書く"
        ]
        if actionKeywords.contains(where: { t.contains($0) }) { score += 5 }

        // 行動っぽい終わり
        let actionSuffixes = ["する", "やる", "行く", "買う", "送る", "決める", "書く", "作る", "直す", "片付ける", "整理する"]
        if actionSuffixes.contains(where: { t.hasSuffix($0) }) { score += 4 }

        // 意志/指示っぽさ（含みで少し加点）
        let intentionTokens = ["しよう", "したい", "して", "すべき", "やろう"]
        if intentionTokens.contains(where: { t.contains($0) }) { score += 2 }

        // 具体性（数字 / URL）
        if t.range(of: #"\d"#, options: .regularExpression) != nil { score += 3 }
        if t.contains("http") || t.contains("://") { score += 3 }

        // 長さ：短すぎず長すぎず
        let len = t.count
        if (8...24).contains(len) { score += 2 }
        if len >= 40 { score -= 2 }

        // 抽象/感情だけは弱める
        let vague = ["つらい", "不安", "やばい", "無理", "しんどい", "疲れた"]
        if vague.contains(where: { t == $0 || t.hasSuffix($0) }) { score -= 3 }

        // 否定だけっぽい短文
        if t.contains("できない") && len <= 12 { score -= 2 }

        return score
    }
}
