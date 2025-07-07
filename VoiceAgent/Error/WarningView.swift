import SwiftUI

/// A view that shows a warning snackbar.
struct WarningView: View {
    let warning: LocalizedStringKey

    var body: some View {
        VStack(spacing: 2 * .grid) {
            HStack(spacing: 2 * .grid) {
                Image(systemName: "exclamationmark.triangle")
                Text("warning.title")
                Spacer()
            }
            .font(.system(size: 15, weight: .semibold))

            Text(warning)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(3 * .grid)
        .foregroundStyle(.fgModerate)
        .background(.bgModerate)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                .stroke(.separatorModerate, lineWidth: 1)
        )
        .safeAreaPadding(4 * .grid)
    }
}

#Preview {
    WarningView(warning: "Sample warning message")
}
