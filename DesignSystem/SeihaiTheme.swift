import SwiftUI

enum SeihaiTheme {
    // MARK: - Geometry (Tokens)

    static let cornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 18

    static let cardPaddingPrimary: CGFloat = 16
    static let cardPaddingSecondary: CGFloat = 14

    static let cardBorderWidthPrimary: CGFloat = 0.5
    static let cardBorderWidthSecondary: CGFloat = 0.5

    static let cardMinHeightPrimary: CGFloat = 120

    // MARK: - Emphasis

    /// 整理カードの控えめ度（仕様：0.90〜0.92）
    static let secondaryCardOpacity: Double = 0.92

    // MARK: - Shadow (Minimal)

    static let shadowRadiusPrimary: CGFloat = 6
    static let shadowYPrimary: CGFloat = 2

    static let shadowRadiusSecondary: CGFloat = 4
    static let shadowYSecondary: CGFloat = 1
}
