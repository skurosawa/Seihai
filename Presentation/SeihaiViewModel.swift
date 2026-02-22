import Foundation
import SwiftUI
import Observation

@Observable
final class SeihaiViewModel {

    // MARK: - Navigation
    var page: Int = 0

    // MARK: - Input
    var draftText: String = ""

    // MARK: - Thoughts (items)
    var thoughts: [Thought] = []

    // MARK: - Action (Web版準拠：1本)
    var actionText: String = ""

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
            actionText = snapshot.actionText
        }
    }

    // MARK: - Page Events
    func onPageChanged() {
        if page == 2 {
            // 行動画面に来たら、必要なら生成
            regenerateActionIfNeeded()
        }
    }

    // MARK: - Input Add (PWA互換)
    func addThoughtsFromDraftAndGoArrange() {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let lines = trimmed
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !lines.isEmpty else { return }

        // 末尾追加（PWA互換）
        for line in lines {
            thoughts.append(Thought(text: line))
        }

        draftText = ""

        // 思考が変わったので action は無効化
        actionText = ""

        Haptics.soft()
        scheduleSave()

        // 整理へ自動遷移
        withAnimation(.easeOut(duration: 0.18)) {
            page = 1
        }
    }

    // MARK: - Reset
    func resetAll() {
        thoughts.removeAll()
        draftText = ""
        actionText = ""

        lastDeleted = nil
        showUndoToast = false

        Haptics.light()
        scheduleSave()
    }

    // MARK: - Delete (ID入口)
    func deleteThought(id: UUID) {
        guard let index = thoughts.firstIndex(where: { $0.id == id }) else { return }
        deleteThought(at: index)
    }

    // MARK: - Delete (Index)
    func deleteThought(at index: Int) {
        guard thoughts.indices.contains(index) else { return }

        let removed = thoughts.remove(at: index)
        lastDeleted = (removed, index)
        showUndoToast = true

        // 思考が変わったので action は無効化
        actionText = ""

        Haptics.light()
        scheduleSave()

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_800_000_000)
            if showUndoToast { showUndoToast = false }
        }
    }

    // MARK: - Undo
    func undoDelete() {
        guard let last = lastDeleted else { return }

        let safeIndex = min(max(0, last.index), thoughts.count)
        thoughts.insert(last.thought, at: safeIndex)

        lastDeleted = nil
        showUndoToast = false

        // 思考が変わったので action は無効化
        actionText = ""

        Haptics.soft()
        scheduleSave()
    }

    // MARK: - Move
    func moveThought(from source: IndexSet, to destination: Int) {
        thoughts.move(fromOffsets: source, toOffset: destination)

        // 思考順が変わったので action は無効化
        actionText = ""

        Haptics.soft()
        scheduleSave()
    }

    // MARK: - Action (1本化)
    func regenerateActionIfNeeded() {
        if thoughts.isEmpty {
            if !actionText.isEmpty {
                actionText = ""
                scheduleSave()
            }
            return
        }

        if actionText.isEmpty {
            actionText = ActionGenerator.generate(
                from: thoughts.map(\.text)
            )

            if !actionText.isEmpty {
                Haptics.soft()
            }

            scheduleSave()
        }
    }

    // MARK: - Auto Save (Debounce)
    func scheduleSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)

            let snapshot = SeihaiSnapshot(
                draftText: draftText,
                thoughts: thoughts,
                actionText: actionText
            )
            store.save(snapshot)
        }
    }
}
