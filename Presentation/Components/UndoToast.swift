import SwiftUI

struct UndoToast: View {
    let message: String
    let onUndo: () -> Void

    var body: some View {
        SeihaiToastContainer {
            HStack(spacing: 12) {
                Text(message)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Button("元に戻す") {
                    onUndo()
                    Haptics.soft()
                }
                .buttonStyle(.borderless)
                .font(.footnote.weight(.semibold))
                .tint(.accentColor)
                .contentShape(Rectangle())
            }
        }
        .accessibilityElement(children: .combine)
    }
}
