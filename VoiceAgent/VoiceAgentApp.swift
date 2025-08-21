import LiveKit
import SwiftUI

@main
struct VoiceAgentApp: App {
    // Create the root view model
    private let viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(viewModel)
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

/// A set of flags that define the features supported by the agent.
/// Enable them based on your agent capabilities.
struct AgentFeatures: OptionSet {
    let rawValue: Int

    static let voice = Self(rawValue: 1 << 0)
    static let text = Self(rawValue: 1 << 1)
    static let video = Self(rawValue: 1 << 2)

    static let current: Self = [.voice, .text]
}
