import SwiftUI

struct SimpleToast: View {
    let message: String

    var body: some View {
        SeihaiToastContainer {
            Text(message)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityLabel(message)
    }
}
