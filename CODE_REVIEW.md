# Code Review (2026-02-22)

対象: `Presentation/Views/ActionView.swift`

## Findings

### 1. 共有キャンセル時にも「共有したにゃ」トーストが表示される
- `sheet(isPresented:onDismiss:)` の `onDismiss` 内で、共有の成否に関わらず `showSharedToast = true` を実行しています。
- iOS の共有シートはユーザーが「キャンセル」で閉じるケースがあり、その場合でも成功トーストが表示されるため、ユーザー誤認につながります。
- 対応案:
  - `UIActivityViewController` の `completionWithItemsHandler` を `ShareSheet` 側で受け取り、`completed == true` のときだけトースト表示する。

## Notes
- `makeShareMarkdown(action:items:)` は空文字トリムや空セクション除外ができており、出力仕様としては妥当です。
