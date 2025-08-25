import SwiftUI

#if os(visionOS)
/// A platform-specific view that shows all interaction controls with optional chat.
struct VisionInteractionView: View {
    var chat: Bool
    @FocusState.Binding var keyboardFocus: Bool

    var body: some View {
        HStack {
            participants()
            agent()
            chats()
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
    private func chats() -> some View {
        VStack {
            if chat {
                ChatView()
                ChatTextInputView(keyboardFocus: _keyboardFocus)
            }
        }
        .frame(width: 125 * .grid)
        .glassBackgroundEffect()
    }
}
#endif
