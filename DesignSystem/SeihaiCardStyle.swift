import SwiftUI

// MARK: - Public API

public enum SeihaiCardRole {
    case primary   // 主役カード（次の一手）
    case secondary // 控えめカード（整理カードなど）
}

public struct SeihaiCardTokens {
    public var cornerRadius: CGFloat
    public var padding: CGFloat
    public var borderWidth: CGFloat
    public var minHeight: CGFloat?

    public var shadowRadius: CGFloat
    public var shadowY: CGFloat

    /// secondary の控えめ感（仕様：0.90〜0.92）
    public var secondaryOpacity: Double
    public var secondaryScale: CGFloat

    public init(
        cornerRadius: CGFloat,
        padding: CGFloat,
        borderWidth: CGFloat,
        minHeight: CGFloat?,
        shadowRadius: CGFloat,
        shadowY: CGFloat,
        secondaryOpacity: Double,
        secondaryScale: CGFloat
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.borderWidth = borderWidth
        self.minHeight = minHeight
        self.shadowRadius = shadowRadius
        self.shadowY = shadowY
        self.secondaryOpacity = secondaryOpacity
        self.secondaryScale = secondaryScale
    }

    /// ロールごとのデフォルト（Themeから一元参照）
    public static func `default`(_ role: SeihaiCardRole) -> SeihaiCardTokens {
        switch role {
        case .primary:
            return .init(
                cornerRadius: SeihaiTheme.cardCornerRadius,
                padding: SeihaiTheme.cardPaddingPrimary,
                borderWidth: SeihaiTheme.cardBorderWidthPrimary,
                minHeight: SeihaiTheme.cardMinHeightPrimary,
                shadowRadius: SeihaiTheme.shadowRadiusPrimary,
                shadowY: SeihaiTheme.shadowYPrimary,
                secondaryOpacity: SeihaiTheme.secondaryCardOpacity,
                secondaryScale: 1.0
            )

        case .secondary:
            return .init(
                cornerRadius: SeihaiTheme.cardCornerRadius,
                padding: SeihaiTheme.cardPaddingSecondary,
                borderWidth: SeihaiTheme.cardBorderWidthSecondary,
                minHeight: nil,
                shadowRadius: SeihaiTheme.shadowRadiusSecondary,
                shadowY: SeihaiTheme.shadowYSecondary,
                secondaryOpacity: SeihaiTheme.secondaryCardOpacity,
                secondaryScale: 1.0
            )
        }
    }
}

public extension View {
    /// Seihaiの基本カードスタイル（Material + 微細ボーダー + 最小影）
    func seihaiCard(_ role: SeihaiCardRole) -> some View {
        modifier(SeihaiCardModifier(role: role, tokens: .default(role)))
    }

    /// 必要時のみ微調整（v0.9ではなるべく使わない）
    func seihaiCard(_ role: SeihaiCardRole, tokens: SeihaiCardTokens) -> some View {
        modifier(SeihaiCardModifier(role: role, tokens: tokens))
    }
}

// MARK: - Implementation

private struct SeihaiCardModifier: ViewModifier {
    let role: SeihaiCardRole
    let tokens: SeihaiCardTokens

    func body(content: Content) -> some View {
        content
            .padding(tokens.padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .ifLet(tokens.minHeight) { view, minHeight in
                view.frame(minHeight: minHeight, alignment: .leading)
            }
            .background {
                RoundedRectangle(cornerRadius: tokens.cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: tokens.cornerRadius, style: .continuous)
                    .strokeBorder(Color.seihaiSeparator, lineWidth: tokens.borderWidth)
            }
            .shadow(radius: tokens.shadowRadius, x: 0, y: tokens.shadowY)
            .opacity(role == .secondary ? tokens.secondaryOpacity : 1.0)
            .scaleEffect(role == .secondary ? tokens.secondaryScale : 1.0)
            .accessibilityElement(children: .contain)
    }
}

// MARK: - Helpers

private extension Color {
    /// UIKitのseparator相当。ライト/ダークで破綻しにくい。
    static var seihaiSeparator: Color {
        Color(uiColor: .separator)
    }
}

private extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
