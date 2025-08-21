import LiveKit
import SwiftUI

enum AppFeatures {
    static let voice = true
    static let video = true
    static let text = true
}

@main
struct VoiceAgentApp: App {
    // To use the LiveKit Cloud sandbox (development only)
    // - Enable your sandbox here https://cloud.livekit.io/projects/p_/sandbox/templates/token-server
    // - Create .env.xcconfig with your LIVEKIT_SANDBOX_ID
    private static let sandboxId = Bundle.main.object(forInfoDictionaryKey: "LiveKitSandboxId") as! String
    private let conversation = Conversation(credentials: CachingCredentialsProvider(SandboxTokenServer(id: Self.sandboxId)),
                                            // agentName: ...
                                            room: Room(roomOptions: RoomOptions(defaultScreenShareCaptureOptions: ScreenShareCaptureOptions(useBroadcastExtension: true))))

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(conversation)
                .environmentObject(LocalMedia(conversation: conversation))
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
