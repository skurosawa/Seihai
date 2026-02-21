import SwiftUI

struct RootView: View {

    @State private var viewModel = SeihaiViewModel()

    private let edgeWidth: CGFloat = 24
    private let minSwipeDistance: CGFloat = 70

    var body: some View {
        ZStack {
            SeihaiTheme.background.ignoresSafeArea()

            VStack(spacing: 12) {
                SeihaiSegment(selection: $viewModel.page)

                ZStack {
                    // ---- 現在ページ（ページングは使わない）----
                    Group {
                        switch viewModel.page {
                        case 0:
                            InputView(vm: viewModel)
                        case 1:
                            OrganizeView(vm: viewModel)
                        default:
                            ActionView(vm: viewModel)
                        }
                    }
                    .transition(.opacity)

                    // ---- ✅ 全ページ共通：エッジスワイプでページ遷移 ----
                    EdgePagingOverlay(
                        edgeWidth: edgeWidth,
                        minSwipeDistance: minSwipeDistance,
                        canGoPrev: viewModel.page > 0,
                        canGoNext: viewModel.page < 2,
                        goPrev: {
                            withAnimation(.easeOut(duration: 0.18)) {
                                viewModel.page = max(viewModel.page - 1, 0)
                                viewModel.onPageChanged()
                            }
                        },
                        goNext: {
                            withAnimation(.easeOut(duration: 0.18)) {
                                viewModel.page = min(viewModel.page + 1, 2)
                                viewModel.onPageChanged()
                            }
                        }
                    )
                }
            }
            .padding(.top, 8)
        }
    }
}

private struct EdgePagingOverlay: View {
    let edgeWidth: CGFloat
    let minSwipeDistance: CGFloat

    let canGoPrev: Bool
    let canGoNext: Bool
    let goPrev: () -> Void
    let goNext: () -> Void

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // 左端：右スワイプで前へ
                Color.clear
                    .frame(width: edgeWidth, height: geo.size.height)
                    .contentShape(Rectangle())
                    .allowsHitTesting(canGoPrev)
                    .gesture(edgeDragGesture(isLeftEdge: true))

                Spacer(minLength: 0)

                // 右端：左スワイプで次へ
                Color.clear
                    .frame(width: edgeWidth, height: geo.size.height)
                    .contentShape(Rectangle())
                    .allowsHitTesting(canGoNext)
                    .gesture(edgeDragGesture(isLeftEdge: false))
            }
        }
    }

    private func edgeDragGesture(isLeftEdge: Bool) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height
                let isHorizontal = abs(dx) > abs(dy)
                guard isHorizontal, abs(dx) > minSwipeDistance else { return }

                if isLeftEdge, dx > 0 {
                    goPrev()
                }
                if !isLeftEdge, dx < 0 {
                    goNext()
                }
            }
    }
}
