import SwiftUI

/// A drop-in replacement `Button` that executes an async action and shows a busy label when in progress.
///
/// - Parameters:
///   - action: The async action to execute.
///   - label: The label to show when not busy.
///   - busyLabel: The label to show when busy. Defaults to an empty view.
struct AsyncButton<Label: View, BusyLabel: View>: View {
    private let action: () async -> Void

    @ViewBuilder private let label: Label
    @ViewBuilder private let busyLabel: BusyLabel

    @State private var isBusy = false

    init(
        action: @escaping () async -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder busyLabel: () -> BusyLabel = EmptyView.init
    ) {
        self.action = action
        self.label = label()
        self.busyLabel = busyLabel()
    }

    var body: some View {
        Button {
            isBusy = true
            Task {
                await action()
                isBusy = false
            }
        } label: {
            if isBusy {
                if busyLabel is EmptyView {
                    label
                } else {
                    busyLabel
                }
            } else {
                label
            }
        }
        .disabled(isBusy)
    }
}
