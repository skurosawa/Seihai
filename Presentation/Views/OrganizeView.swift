import SwiftUI

struct OrganizeView: View {
    @Bindable var vm: SeihaiViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(Array(vm.thoughts.enumerated()), id: \.element.id) { index, t in
                    Text(t.text)
                        .padding(.vertical, 6)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                vm.deleteThought(at: index)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                }
                .onMove { src, dst in
                    vm.moveThought(from: src, to: dst)
                }
            }
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active)) // いつでもドラッグ可能に（純正っぽく）
            .padding(.top, 4)

            if vm.showUndoToast {
                UndoToast(message: "削除しました") {
                    vm.undoDelete()
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.18), value: vm.showUndoToast)
        .padding(.horizontal, 0)
        .padding(.bottom, 0)
    }
}

