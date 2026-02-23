import SwiftUI

struct OrganizeView: View {
    @Bindable var vm: SeihaiViewModel
    @State private var editMode: EditMode = .inactive

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack {
                    Text("整理")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button(editMode == .active ? "完了" : "編集") {
                        withAnimation(.easeOut(duration: 0.18)) {
                            editMode = (editMode == .active) ? .inactive : .active
                        }
                        Haptics.soft()
                    }
                    .font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 6)

                List {
                    ForEach(vm.thoughts) { thought in
                        ThoughtCardRow(text: thought.text)
                            .contentShape(Rectangle())
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    vm.deleteThought(id: thought.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onMove { src, dst in
                        vm.moveThought(from: src, to: dst)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .environment(\.editMode, $editMode)
            }

            if vm.showUndoToast {
                UndoToast(message: "消しちゃったにゃ") {
                    vm.undoDelete()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.18), value: vm.showUndoToast)
    }
}

private struct ThoughtCardRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .seihaiCard(.secondary)
    }
}
