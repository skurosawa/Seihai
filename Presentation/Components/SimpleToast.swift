import SwiftUI

struct SimpleToast: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(SeihaiTheme.border, lineWidth: 1)
            )
            .shadow(radius: 1)
            .padding(.horizontal, 16)
    }
}
