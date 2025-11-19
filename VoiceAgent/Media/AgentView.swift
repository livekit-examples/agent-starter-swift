import LiveKitComponents

/// A view that combines the avatar camera view (if available)
/// or the audio visualizer (if available).
/// - Note: If both are unavailable, the view will show a placeholder visualizer.
struct AgentView: View {
    @EnvironmentObject private var session: Session

    @Environment(\.namespace) private var namespace
    /// Reveals the avatar camera view when true.
    @SceneStorage("videoTransition") private var videoTransition = false

    var body: some View {
        ZStack {
            if let avatarVideoTrack = session.agent.avatarVideoTrack {
                SwiftUIVideoView(avatarVideoTrack)
                    .clipShape(RoundedRectangle(cornerRadius: .cornerRadiusPerPlatform))
                    .aspectRatio(avatarVideoTrack.aspectRatio, contentMode: .fit)
                    .padding(.horizontal, session.agent.avatarVideoTrack?.aspectRatio == 1 ? 4 * .grid : .zero)
                    .shadow(radius: 20, y: 10)
                    .mask(
                        GeometryReader { proxy in
                            let targetSize = max(proxy.size.width, proxy.size.height)
                            Circle()
                                .frame(width: videoTransition ? targetSize : 6 * .grid)
                                .position(x: 0.5 * proxy.size.width, y: 0.5 * proxy.size.height)
                                .scaleEffect(2)
                                .animation(.smooth(duration: 1.5), value: videoTransition)
                        }
                    )
                    .onAppear {
                        videoTransition = true
                    }
            } else if let audioTrack = session.agent.audioTrack {
                BarAudioVisualizer(audioTrack: audioTrack,
                                   agentState: session.agent.agentState ?? .listening,
                                   barCount: 5,
                                   barSpacingFactor: 0.05,
                                   barMinOpacity: 0.1)
                    .frame(maxWidth: 75 * .grid, maxHeight: 48 * .grid)
                    .transition(.opacity)
            } else if session.isConnected {
                BarAudioVisualizer(audioTrack: nil,
                                   agentState: .listening,
                                   barCount: 1,
                                   barMinOpacity: 0.1)
                    .frame(maxWidth: 10.5 * .grid, maxHeight: 48 * .grid)
                    .transition(.opacity)
            }
        }
        .animation(.snappy, value: session.agent.audioTrack?.id)
        .matchedGeometryEffect(id: "agent", in: namespace!)
    }
}
