import LiveKit
import SwiftUI

/// A multiplatform view that shows text-specific interaction controls.
///
/// Depending on the track availability, the view will show:
/// - agent participant view
/// - local participant camera preview
/// - local participant screen share preview
///
/// Additionally, the view shows a complete chat view with text input capabilities.
struct TextInteractionView: View {
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var localMedia: LocalMedia

    @FocusState.Binding var keyboardFocus: Bool

    var body: some View {
        VStack {
            VStack {
                participants()
                ChatView()
                #if os(macOS)
                    .frame(maxWidth: 128 * .grid)
                #endif
                    .blurredTop()
            }
            #if os(iOS)
            .contentShape(Rectangle())
            .onTapGesture {
                keyboardFocus = false
            }
            #endif
            ChatInputView(keyboardFocus: _keyboardFocus)
        }
    }

    @ViewBuilder
    private func participants() -> some View {
        HStack {
            Spacer()
            AgentView()
                .frame(maxWidth: session.agent.avatarVideoTrack != nil ? 50 * .grid : 25 * .grid)
            ScreenShareView()
            LocalParticipantView()
            Spacer()
        }
        .frame(height: localMedia.isCameraEnabled || localMedia.isScreenShareEnabled || session.agent.avatarVideoTrack != nil ? 50 * .grid : 25 * .grid)
        .safeAreaPadding()
    }
}
