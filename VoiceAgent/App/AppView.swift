import LiveKit
import SwiftUI

struct AppView: View {
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var localMedia: LocalMedia

    @State private var chat: Bool = false
    @FocusState private var keyboardFocus: Bool
    @Namespace private var namespace

    var body: some View {
        ZStack(alignment: .top) {
            if session.isReady {
                interactions()
            } else {
                start()
            }

            errors()
        }
        .environment(\.namespace, namespace)
        #if os(visionOS)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                if session.isReady {
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
                if session.isReady, !keyboardFocus {
                    ControlBar(chat: $chat)
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
            }
        #endif
            .background(.bg1)
            .animation(.default, value: chat)
            .animation(.default, value: session.isReady)
            .animation(.default, value: session.error?.localizedDescription)
            .animation(.default, value: localMedia.isCameraEnabled)
            .animation(.default, value: localMedia.isScreenShareEnabled)
        #if os(iOS)
            .sensoryFeedback(.impact, trigger: session.isListening) { !$0 && $1 }
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
               !localMedia.isCameraEnabled,
               !localMedia.isScreenShareEnabled
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
