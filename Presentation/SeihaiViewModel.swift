import Foundation
import SwiftUI
import Observation

@Observable
final class SeihaiViewModel {

    // MARK: - Navigation
    var page: Int = 0

    // MARK: - Input
    var draftText: String = ""

    // MARK: - Thoughts
    var thoughts: [Thought] = []

    // MARK: - Actions
    var actions: [ActionCard] = []

    // MARK: - Undo
    private(set) var lastDeleted: (thought: Thought, index: Int)?
    var showUndoToast: Bool = false

    // MARK: - Persistence
    private let store = UserDefaultsStore()
    private var saveTask: Task<Void, Never>?

    // MARK: - Init
    init() {
        if let snapshot = store.load() {
            draftText = snapshot.draftText
            thoughts = snapshot.thoughts
            actions = snapshot.actions
        }
    }

    // MARK: - Page Events

    /// RootView で page が変わったら呼ぶ
    func onPageChanged() {
        if page == 2 {
            // 行動画面に来たタイミングで、空なら生成
            if actions.isEmpty {
                regenerateActions()
            }
        }
    }

    // MARK: - Add

    func addThoughtFromDraft() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        thoughts.insert(Thought(text: trimmed), at: 0)
        draftText = ""

        // 思考が変わったので、行動は“古い”扱い（次の画面で再生成させる）
        actions = []

        Haptics.soft()
        scheduleSave()
    }

    // MARK: - Reset

    func resetAll() {
        thoughts.removeAll()
        actions.removeAll()
        draftText = ""

        Haptics.light()
        scheduleSave()
    }

    // MARK: - Delete

    func deleteThought(at index: Int) {
        guard thoughts.indices.contains(index) else { return }

        let removed = thoughts.remove(at: index)
        lastDeleted = (removed, index)
        showUndoToast = true

        // 思考が変わったので actions はクリア
        actions = []

        Haptics.light()
        scheduleSave()

        // 3秒後にトースト自動非表示
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if showUndoToast {
                showUndoToast = false
            }
        }
    }

    // MARK: - Undo

    func undoDelete() {
        guard let last = lastDeleted else { return }

        let safeIndex = min(max(0, last.index), thoughts.count)
        thoughts.insert(last.thought, at: safeIndex)

        lastDeleted = nil
        showUndoToast = false

        // 思考が変わったので actions はクリア
        actions = []

        Haptics.soft()
        scheduleSave()
    }

    // MARK: - Move

    func moveThought(from source: IndexSet, to destination: Int) {
        thoughts.move(fromOffsets: source, toOffset: destination)

        // 思考順が変わったので actions はクリア
        actions = []

        Haptics.soft()
        scheduleSave()
    }

    // MARK: - Actions

    func regenerateActions() {
        actions = ActionGenerator.generate(from: thoughts)
        Haptics.soft()
        scheduleSave()
    }

    // MARK: - Auto Save (Debounce)

    func scheduleSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4秒デバウンス

            let snapshot = SeihaiSnapshot(
                draftText: draftText,
                thoughts: thoughts,
                actions: actions
            )
            store.save(snapshot)
        }
    }
}
