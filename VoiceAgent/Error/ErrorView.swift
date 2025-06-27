import SwiftUI

/// A view that shows an error snackbar.
struct ErrorView: View {
    let error: Error
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 2 * .grid) {
            HStack(spacing: 2 * .grid) {
                Image(systemName: "exclamationmark.triangle")
                Text("error.title")
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 15, weight: .semibold))

            Text(error.localizedDescription)
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(3 * .grid)
        .background(.bgSerious)
        .foregroundStyle(.fgSerious)
        .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: .cornerRadiusSmall)
                .stroke(.separatorSerious, lineWidth: 1)
        )
        .safeAreaPadding(4 * .grid)
    }
}

#Preview {
    ErrorView(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Sample error message"]), onDismiss: {})
}
