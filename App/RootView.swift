import SwiftUI

struct RootView: View {

    @State private var viewModel = SeihaiViewModel()

    private let edgeWidth: CGFloat = 24
    private let minSwipeDistance: CGFloat = 70

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                // --- ナビ（うっすら青） ---
                VStack {
                    SeihaiSegment(selection: $viewModel.page)
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color.accentColor.opacity(0.12))
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(Color(uiColor: .separator))
                }

                // --- コンテンツ ---
                ZStack {
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
                Color.clear
                    .frame(width: edgeWidth, height: geo.size.height)
                    .contentShape(Rectangle())
                    .allowsHitTesting(canGoPrev)
                    .gesture(edgeDragGesture(isLeftEdge: true))

                Spacer(minLength: 0)

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

                if isLeftEdge, dx > 0 { goPrev() }
                if !isLeftEdge, dx < 0 { goNext() }
            }
    }
}
