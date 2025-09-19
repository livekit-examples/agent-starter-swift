import LiveKit
import SwiftUI

struct AppView: View {
    @LiveKitConversation private var conversation
    @LiveKitLocalMedia private var localMedia

    @State private var chat: Bool = false
    @FocusState private var keyboardFocus: Bool
    @Namespace private var namespace

    var body: some View {
        ZStack(alignment: .top) {
            if conversation.isReady {
                interactions()
            } else {
                start()
            }

            errors()
        }
        .environment(\.namespace, namespace)
        #if os(visionOS)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                if conversation.isReady {
                    ControlBar(chat: $chat)
                        .glassBackgroundEffect()
                }
            }
            .alert("warning.reconnecting", isPresented: .constant(conversation.connectionState == .reconnecting)) {}
            .alert(conversation.error?.localizedDescription ?? "error.title", isPresented: .constant(conversation.error != nil)) {
                Button("error.ok") { conversation.resetError() }
            }
        #else
            .safeAreaInset(edge: .bottom) {
                if conversation.isReady, !keyboardFocus {
                    ControlBar(chat: $chat)
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
            }
        #endif
            .background(.bg1)
            .animation(.default, value: chat)
            .animation(.default, value: conversation.isReady)
            .animation(.default, value: conversation.error?.localizedDescription)
            .animation(.default, value: localMedia.isCameraEnabled)
            .animation(.default, value: localMedia.isScreenShareEnabled)
        #if os(iOS)
            .sensoryFeedback(.impact, trigger: conversation.isListening) { !$0 && $1 }
        #endif
    }

    @ViewBuilder
    private func start() -> some View {
        StartView()
            .onAppear {
                chat = false
            }
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
        if case .reconnecting = conversation.connectionState {
            WarningView(warning: "warning.reconnecting")
        }

        if let error = conversation.error {
            ErrorView(error: error) { conversation.resetError() }
        }
        #endif
    }

    @ViewBuilder
    private func agentListening() -> some View {
        ZStack {
            if conversation.messages.isEmpty,
               !localMedia.isCameraEnabled,
               !localMedia.isScreenShareEnabled
            {
                AgentListeningView()
            }
        }
        .animation(.default, value: conversation.messages.isEmpty)
    }
}

#Preview {
    AppView()
}
