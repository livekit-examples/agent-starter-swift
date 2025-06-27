import SwiftUI

/// A tooltip that indicates that the audio is being recorded
/// e.g. while using pre-connect audio feature to initiate a conversation.
struct AgentListeningView: View {
    var body: some View {
        Text("agent.listening")
            .font(.system(size: 15))
            .shimmering()
            .transition(.blurReplace)
    }
}

#Preview {
    AgentListeningView()
}
