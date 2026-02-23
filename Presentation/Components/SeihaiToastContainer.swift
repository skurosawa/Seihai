import SwiftUI

struct SeihaiToastContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(uiColor: .separator), lineWidth: 0.5)
            }
            .shadow(radius: 6, x: 0, y: 2)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .accessibilityElement(children: .contain)
    }
}
