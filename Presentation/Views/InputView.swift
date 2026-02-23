import SwiftUI

struct InputView: View {

    @Bindable var vm: SeihaiViewModel
    @FocusState private var isFocused: Bool

    @State private var showResetAlert: Bool = false

    var body: some View {
        VStack(spacing: 12) {

            // Title
            HStack {
                Text("入力")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Draft only (auto-height, max 4 lines)
            TextField("思考を入力するにゃ…", text: $vm.draftText, axis: .vertical)
                .lineLimit(1...4)
                .submitLabel(.done)
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: SeihaiTheme.cornerRadius,
                        style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: SeihaiTheme.cornerRadius,
                        style: .continuous
                    )
                    .strokeBorder(Color(uiColor: .separator), lineWidth: 0.5)
                )
                .focused($isFocused)
                .onSubmit {
                    vm.addThoughtsFromDraftAndGoArrange()
                    isFocused = true
                }
                .onChange(of: vm.draftText) { _, _ in
                    vm.scheduleSave()
                }
                .padding(.horizontal, 16)

            // Helper（メッセージのみ にゃ）
            Text("Enterで追加するにゃ。整理で並べ替えるにゃ。")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            Spacer()
        }
        .safeAreaInset(edge: .bottom) {

            // Sticky toolbar（ボタンは通常表記）
            HStack(spacing: 10) {

                Button("クリア") {
                    vm.draftText = ""
                    vm.scheduleSave()
                    isFocused = true
                }
                .buttonStyle(.bordered)

                Button("リセット") {
                    showResetAlert = true
                }
                .buttonStyle(.bordered)
                .tint(.red)

                Spacer()

                Button("追加") {
                    vm.addThoughtsFromDraftAndGoArrange()
                    isFocused = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    vm.draftText
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .overlay(alignment: .top) {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(Color(uiColor: .separator))
            }
        }
        .alert("ほんとにリセットするにゃ？", isPresented: $showResetAlert) {
            Button("キャンセル", role: .cancel) {}

            Button("リセット", role: .destructive) {
                vm.resetAll()
                isFocused = true
            }
        } message: {
            Text("入力中の文章と、保存された思考と行動がぜんぶ消えるにゃ。")
        }
        .onAppear {
            isFocused = true
        }
    }
}
