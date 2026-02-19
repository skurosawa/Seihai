import SwiftUI

struct RootView: View {

    @State private var viewModel = SeihaiViewModel()

    var body: some View {
        ZStack {
            SeihaiTheme.background.ignoresSafeArea()

            VStack(spacing: 12) {
                SeihaiSegment(selection: $viewModel.page)

                TabView(selection: $viewModel.page) {
                    InputView(vm: viewModel)
                        .tag(0)

                    OrganizeView(vm: viewModel)
                        .tag(1)

                    ActionView(vm: viewModel)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .padding(.top, 8)
        }
    }
}

