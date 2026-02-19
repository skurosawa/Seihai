import SwiftUI

struct SeihaiSegment: View {
    @Binding var selection: Int

    private let titles = ["入力", "整理", "行動"]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Button {
                    withAnimation(.easeOut(duration: 0.18)) {
                        selection = i
                    }
                } label: {
                    Text(titles[i])
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection == i ? SeihaiTheme.accent.opacity(0.14) : .clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(SeihaiTheme.border, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white.opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(SeihaiTheme.border, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
}
