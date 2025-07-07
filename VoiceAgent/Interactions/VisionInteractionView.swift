import SwiftUI

#if os(visionOS)
/// A platform-specific view that shows all interaction controls with optional chat.
struct VisionInteractionView: View {
    @Environment(AppViewModel.self) private var viewModel
    @FocusState.Binding var keyboardFocus: Bool

    var body: some View {
        HStack {
            participants()
            agent()
            chat()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func participants() -> some View {
        VStack {
            Spacer()
            ScreenShareView()
            LocalParticipantView()
            Spacer()
        }
        .frame(width: 125 * .grid)
    }

    @ViewBuilder
    private func agent() -> some View {
        AgentParticipantView()
            .frame(width: 175 * .grid)
            .frame(maxHeight: .infinity)
            .glassBackgroundEffect()
    }

    @ViewBuilder
    private func chat() -> some View {
        VStack {
            if case .text = viewModel.interactionMode {
                ChatView()
                ChatTextInputView(keyboardFocus: _keyboardFocus)
            }
        }
        .frame(width: 125 * .grid)
        .glassBackgroundEffect()
    }
}
#endif
