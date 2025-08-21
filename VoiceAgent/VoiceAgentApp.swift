import LiveKit
import SwiftUI

@main
struct VoiceAgentApp: App {
    // To use the LiveKit Cloud sandbox (development only)
    // - Enable your sandbox here https://cloud.livekit.io/projects/p_/sandbox/templates/token-server
    // - Create .env.xcconfig with your LIVEKIT_SANDBOX_ID
    private let sandboxID = Bundle.main.object(forInfoDictionaryKey: "LiveKitSandboxId") as! String
    private let room = Room(roomOptions: RoomOptions(defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(useBroadcastExtension: true)))

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(DeviceSwitcher(room: room))
                .environmentObject(AgentSession(environment: .sandbox(id: sandboxID), context: .init(room: room)))
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
