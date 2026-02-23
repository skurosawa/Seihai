import SwiftUI

struct SeihaiSegment: View {
    @Binding var selection: Int

    private let items: [(title: String, index: Int)] = [
        ("入力", 0),
        ("整理", 1),
        ("行動", 2)
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.index) { item in
                segmentButton(title: item.title, index: item.index)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Segment Button

    @ViewBuilder
    private func segmentButton(title: String, index: Int) -> some View {
        let isSelected = (selection == index)

        Button {
            withAnimation(.easeOut(duration: 0.18)) {
                selection = index
            }
            Haptics.soft()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .foregroundStyle(isSelected ? .primary : .secondary)
        .background(segmentBackground(isSelected: isSelected))
        .clipShape(
            RoundedRectangle(
                cornerRadius: SeihaiTheme.cornerRadius,
                style: .continuous
            )
        )
    }

    // MARK: - Background

    @ViewBuilder
    private func segmentBackground(isSelected: Bool) -> some View {
        let r = SeihaiTheme.cornerRadius

        if #available(iOS 26, *) {

            // --- iOS 26+: 純正Liquid Glass + ほんのり青 ---
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: r, style: .continuous)
                        .fill(Color.accentColor.opacity(0.06)) // ← 超薄青
                }

                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .fill(.clear)
                    .glassEffect(.regular, in: .rect(cornerRadius: r))
            }
            .overlay {
                RoundedRectangle(cornerRadius: r, style: .continuous)
                    .strokeBorder(Color(uiColor: .separator), lineWidth: 0.5)
            }
            .opacity(isSelected ? 1.0 : 0.88)

        } else {

            // --- iOS 17–25: 従来安定版 ---
            RoundedRectangle(cornerRadius: r, style: .continuous)
                .fill(isSelected ? Color.accentColor.opacity(0.18) : .clear)
                .overlay {
                    RoundedRectangle(cornerRadius: r, style: .continuous)
                        .strokeBorder(Color(uiColor: .separator), lineWidth: 0.5)
                        .opacity(isSelected ? 1.0 : 0.5)
                }
        }
    }
}
