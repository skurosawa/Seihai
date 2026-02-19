import SwiftUI

struct InputView: View {

    @Bindable var vm: SeihaiViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Input Field

            TextField("思考を入力…（Enterで追加）", text: $vm.draftText, axis: .vertical)
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(false)
                .lineLimit(1...6)
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
                    vm.addThoughtFromDraft()
                    isFocused = true
                }
                .onChange(of: vm.draftText) { _, _ in
                    vm.scheduleSave()
                }

            // MARK: - Action Buttons

            HStack(spacing: 12) {

                Button("クリア") {
                    vm.draftText = ""
                    isFocused = true
                }
                .buttonStyle(.bordered)

                Button("リセット") {
                    vm.resetAll()
                    isFocused = true
                }
                .buttonStyle(.borderedProminent)
            }

            // MARK: - Thought Preview List

            if vm.thoughts.isEmpty {
                Spacer()
                Text("まだ思考はありません")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(vm.thoughts) { thought in
                        Text(thought.text)
                            .padding(.vertical, 6)
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .padding(16)
        .onAppear {
            isFocused = true
        }
    }
}

