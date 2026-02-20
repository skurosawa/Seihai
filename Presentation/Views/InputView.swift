import SwiftUI

struct InputView: View {

    @Bindable var vm: SeihaiViewModel
    @FocusState private var isFocused: Bool

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
            TextField("思考を入力…", text: $vm.draftText, axis: .vertical)
                .lineLimit(1...4)
                .submitLabel(.done)
                .padding(14)
                .background(.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(SeihaiTheme.border, lineWidth: 1)
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

            // Optional helper (minimal)
            Text("Enterで追加。整理で並べ替え。")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            Spacer()
        }
        .safeAreaInset(edge: .bottom) {
            // Sticky toolbar
            HStack(spacing: 10) {

                Button("クリア") {
                    vm.draftText = ""
                    vm.scheduleSave()
                    isFocused = true
                }
                .buttonStyle(.bordered)

                Button("リセット") {
                    vm.resetAll()
                    isFocused = true
                }
                .buttonStyle(.bordered)
                .tint(.red)

                Spacer()

                Button("追加") {
                    vm.addThoughtsFromDraftAndGoArrange()
                    isFocused = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(SeihaiTheme.border)
                , alignment: .top
            )
        }
        .onAppear {
            isFocused = true
        }
    }
}
