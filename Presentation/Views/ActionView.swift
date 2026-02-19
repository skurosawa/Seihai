import SwiftUI

struct ActionView: View {
    @Bindable var vm: SeihaiViewModel
    @State private var showShare: Bool = false

    var shareText: String {
        vm.actions
            .map { "【\($0.title)】\n\($0.body)" }
            .joined(separator: "\n\n")
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Button("再生成") {
                    vm.regenerateActions()
                }
                .buttonStyle(.bordered)

                Button("共有") {
                    showShare = true
                    Haptics.light()
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.actions.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            if vm.actions.isEmpty {
                Spacer()
                Text("整理した思考から、次の一手を作ります")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(vm.actions) { card in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(card.title)
                                    .font(.system(size: 16, weight: .bold))

                                Text(card.body)
                                    .font(.system(size: 15))
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white.opacity(0.75))
                            .overlay(
                                RoundedRectangle(cornerRadius: SeihaiTheme.cardCornerRadius)
                                    .stroke(SeihaiTheme.border, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SeihaiTheme.cardCornerRadius))
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: [shareText])
        }
    }
}


