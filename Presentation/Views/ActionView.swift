import SwiftUI

struct ActionView: View {
    @Bindable var vm: SeihaiViewModel

    @State private var showShare: Bool = false
    @State private var showSharedToast: Bool = false

    private var hasAction: Bool {
        !vm.actionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var shareMarkdown: String {
        makeShareMarkdown(action: vm.actionText, items: vm.thoughts)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 12) {
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if !hasAction {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            // 主役カード「次の一手」
                            VStack(alignment: .leading, spacing: 10) {
                                Text("次の一手")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.secondary)

                                Text(vm.actionText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundStyle(.primary)
                                    .lineSpacing(3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .seihaiCard(.primary)
                            .padding(.horizontal, 16)

                            // 整理カード（控えめ）
                            if !vm.thoughts.isEmpty {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("整理")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.secondary)

                                    VStack(alignment: .leading, spacing: 6) {
                                        ForEach(vm.thoughts) { t in
                                            Text("• \(t.text)")
                                                .font(.system(size: 14))
                                                .foregroundStyle(.secondary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                                .seihaiCard(.secondary)
                                .padding(.horizontal, 16)
                            }

                            // 共有ボタン（純正寄せ）
                            HStack {
                                Spacer()
                                Button {
                                    showShare = true
                                } label: {
                                    Label("共有", systemImage: "square.and.arrow.up")
                                        .padding(.vertical, 6) // 見た目は変えずタップ領域だけ確保
                                        .padding(.horizontal, 8)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.borderless)
                                .font(.footnote)
                                .tint(.accentColor)
                                .disabled(shareMarkdown.isEmpty)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 2)
                        }
                        .padding(.vertical, 6)
                    }
                }

                Spacer(minLength: 0)
            }

            if showSharedToast {
                SimpleToast(message: "共有したにゃ")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                // ↑ padding(.bottom, 12) は Toast 側（SeihaiToastContainer）に任せる
            }
        }
        .animation(.easeOut(duration: 0.18), value: showSharedToast)
        .sheet(isPresented: $showShare) {
            ShareSheet(activityItems: [shareMarkdown]) { completed in
                guard completed else { return } // キャンセル時は何もしない

                Haptics.soft()
                showSharedToast = true

                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 1_800_000_000)
                    showSharedToast = false
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("行動")
                .font(.system(size: 20, weight: .bold))
            Spacer()
        }
    }

    // MARK: - Share Markdown

    private func makeShareMarkdown(action: String, items: [Thought]) -> String {
        let a = action.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = items
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var out: [String] = []

        if !a.isEmpty {
            out.append("## 行動")
            out.append("")
            out.append(a)
        }

        if !lines.isEmpty {
            if !out.isEmpty { out.append("") }
            out.append("## 整理")
            out.append("")
            for t in lines {
                out.append("- \(t)")
            }
        }

        return out.joined(separator: "\n")
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("🐱💭")
                .font(.system(size: 36))

            Text("まだ行動がないにゃ")
                .font(.system(size: 16, weight: .semibold))

            Text("整理に思考を追加すると、次の一手が出るにゃ")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }
}
