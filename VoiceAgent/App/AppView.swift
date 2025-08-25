import SwiftUI

struct AppView: View {
    @EnvironmentObject private var session: AgentSession
    @State private var chat: Bool = false

    @FocusState private var keyboardFocus: Bool
    @Namespace private var namespace

    var body: some View {
        ZStack(alignment: .top) {
            if session.isAvailable {
                interactions()
            } else {
                start()
            }

            errors()
        }
        .environment(\.namespace, namespace)
        #if os(visionOS)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                if session.isAvailable {
                    ControlBar(chat: $chat)
                        .glassBackgroundEffect()
                }
            }
            .alert("warning.reconnecting", isPresented: .constant(session.connectionState == .reconnecting)) {}
            .alert(session.error?.localizedDescription ?? "error.title", isPresented: .constant(session.error != nil)) {
                Button("error.ok") { session.resetError() }
            }
        #else
            .safeAreaInset(edge: .bottom) {
                if session.isAvailable, !keyboardFocus {
                    ControlBar(chat: $chat)
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
            }
        #endif
            .background(.bg1)
            .animation(.default, value: chat)
            .animation(.default, value: session.isAvailable)
            .animation(.default, value: session.isCameraEnabled)
            .animation(.default, value: session.isScreenShareEnabled)
            .animation(.default, value: session.error?.localizedDescription)
        #if os(iOS)
            .sensoryFeedback(.impact, trigger: session.isListening) { !$0 && $1 }
        #endif
    }

    @ViewBuilder
    private func start() -> some View {
        StartView()
    }

    @ViewBuilder
    private func interactions() -> some View {
        #if os(visionOS)
        VisionInteractionView(chat: chat, keyboardFocus: $keyboardFocus)
            .overlay(alignment: .bottom) {
                agentListening()
                    .padding(16 * .grid)
            }
        #else
        if chat {
            TextInteractionView(keyboardFocus: $keyboardFocus)
        } else {
            VoiceInteractionView()
                .overlay(alignment: .bottom) {
                    agentListening()
                        .padding()
                }
        }
        #endif
    }

    @ViewBuilder
    private func errors() -> some View {
        #if !os(visionOS)
        if case .reconnecting = session.connectionState {
            WarningView(warning: "warning.reconnecting")
        }

        if let error = session.error {
            ErrorView(error: error) { session.resetError() }
        }
        #endif
    }

    @ViewBuilder
    private func agentListening() -> some View {
        ZStack {
            if session.messages.isEmpty,
               !session.isCameraEnabled,
               !session.isScreenShareEnabled
            {
                AgentListeningView()
            }
        }
        .animation(.default, value: session.messages.isEmpty)
    }
}

#Preview {
    AppView()
}
