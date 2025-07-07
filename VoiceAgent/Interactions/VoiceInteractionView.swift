import SwiftUI

/// A multiplatform view that shows voice-specific interaction controls.
///
/// Depending on the track availability, the view will show:
/// - agent participant view
/// - local participant camera preview
/// - local participant screen share preview
///
/// - Note: The layout is determined by the horizontal size class.
struct VoiceInteractionView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            regular()
        } else {
            compact()
        }
    }

    @ViewBuilder
    private func regular() -> some View {
        HStack {
            Spacer()
                .frame(width: 50 * .grid)
            AgentParticipantView()
            VStack {
                Spacer()
                ScreenShareView()
                LocalParticipantView()
            }
            .frame(width: 50 * .grid)
        }
        .safeAreaPadding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func compact() -> some View {
        ZStack(alignment: .bottom) {
            AgentParticipantView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            HStack {
                Spacer()
                ScreenShareView()
                LocalParticipantView()
            }
            .frame(height: 50 * .grid)
            .safeAreaPadding()
        }
    }
}
