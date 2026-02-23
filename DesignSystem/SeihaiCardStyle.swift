import SwiftUI

public enum SeihaiCardRole {
    case primary
    case secondary
}

public struct SeihaiCardTokens {
    public var cornerRadius: CGFloat
    public var padding: CGFloat
    public var borderWidth: CGFloat
    public var minHeight: CGFloat?

    public var shadowRadius: CGFloat
    public var shadowY: CGFloat

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
    func seihaiCard(_ role: SeihaiCardRole) -> some View {
        modifier(SeihaiCardModifier(role: role, tokens: .default(role)))
    }

    func seihaiCard(_ role: SeihaiCardRole, tokens: SeihaiCardTokens) -> some View {
        modifier(SeihaiCardModifier(role: role, tokens: tokens))
    }
}

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
                    .strokeBorder(Color(uiColor: .separator), lineWidth: tokens.borderWidth)
            }
            .shadow(radius: tokens.shadowRadius, x: 0, y: tokens.shadowY)
            .opacity(role == .secondary ? tokens.secondaryOpacity : 1.0)
            .scaleEffect(role == .secondary ? tokens.secondaryScale : 1.0)
            .accessibilityElement(children: .contain)
    }
}

private extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value { transform(self, value) } else { self }
    }
}
