import SwiftUI

#if os(visionOS)
/// A platform-specific view that shows all interaction controls with optional chat.
struct VisionInteractionView: View {
    var chat: Bool
    @FocusState.Binding var keyboardFocus: Bool

    var body: some View {
        HStack {
            participants().rotation3DEffect(.degrees(30), axis: .y, anchor: .trailing)
            agent()
            chatView().rotation3DEffect(.degrees(-30), axis: .y, anchor: .leading)
        }
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
        AgentView()
            .frame(width: 175 * .grid)
            .frame(maxHeight: .infinity)
            .glassBackgroundEffect()
    }

    @ViewBuilder
    private func chatView() -> some View {
        VStack {
            if chat {
                ChatView()
                ChatInputView(keyboardFocus: _keyboardFocus)
            }
        }
        .frame(width: 125 * .grid)
        .glassBackgroundEffect()
    }
}
#endif
