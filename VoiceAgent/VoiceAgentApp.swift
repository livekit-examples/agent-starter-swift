import LiveKit
import SwiftUI

@main
struct VoiceAgentApp: App {
    // To use the LiveKit Cloud sandbox (development only):
    // - Enable your sandbox here: https://cloud.livekit.io/projects/p_/sandbox/templates/token-server
    // - Create a .env.xcconfig file with your LIVEKIT_SANDBOX_ID
    private static let sandboxID = Bundle.main.object(forInfoDictionaryKey: "LiveKitSandboxId") as! String

    // For production, replace the `SandboxTokenSource` with an `EndpointTokenSource` or your own `TokenSourceConfigurable` implementation.
    private let session = Session(
        tokenSource: SandboxTokenSource(id: Self.sandboxID).cached(),
        options: SessionOptions(room: Room(roomOptions: RoomOptions(defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(useBroadcastExtension: true))))
    )

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(session)
                .environmentObject(LocalMedia(session: session))
                .environment(\.voiceEnabled, true)
                .environment(\.videoEnabled, true)
                .environment(\.textEnabled, true)
        }
        #if os(macOS)
        .defaultSize(width: 900, height: 900)
        #endif
        #if os(visionOS)
        .windowStyle(.plain)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 1500, height: 500)
        #endif
    }
}
