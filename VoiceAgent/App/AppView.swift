import SwiftUI

struct AppView: View {
    @Environment(AppViewModel.self) private var viewModel
    @State private var chatViewModel = ChatViewModel()

    @State private var error: Error?
    @FocusState private var keyboardFocus: Bool

    @Namespace private var namespace

    var body: some View {
        ZStack(alignment: .top) {
            if viewModel.isInteractive {
                interactions()
            } else {
                start()
            }

            errors()
        }
        .environment(\.namespace, namespace)
        #if os(visionOS)
            .ornament(attachmentAnchor: .scene(.bottom)) {
                if viewModel.isInteractive {
                    ControlBar()
                        .glassBackgroundEffect()
                }
            }
            .alert("warning.reconnecting", isPresented: .constant(viewModel.connectionState == .reconnecting)) {}
            .alert(error?.localizedDescription ?? "error.title", isPresented: .constant(error != nil)) {
                Button("error.ok") { error = nil }
            }
        #else
            .safeAreaInset(edge: .bottom) {
                if viewModel.isInteractive, !keyboardFocus {
                    ControlBar()
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                }
            }
        #endif
            .background(.bg1)
            .animation(.default, value: viewModel.isInteractive)
            .animation(.default, value: viewModel.interactionMode)
            .animation(.default, value: viewModel.isCameraEnabled)
            .animation(.default, value: viewModel.isScreenShareEnabled)
            .animation(.default, value: error?.localizedDescription)
            .onAppear {
                Dependencies.shared.errorHandler = { error = $0 }
            }
        #if os(iOS)
            .sensoryFeedback(.impact, trigger: viewModel.isListening)
        #endif
    }

    @ViewBuilder
    private func start() -> some View {
        StartView()
    }

    @ViewBuilder
    private func interactions() -> some View {
        #if os(visionOS)
        VisionInteractionView(keyboardFocus: $keyboardFocus)
            .environment(chatViewModel)
            .overlay(alignment: .bottom) {
                agentListening()
                    .padding(16 * .grid)
            }
        #else
        switch viewModel.interactionMode {
        case .text:
            TextInteractionView(keyboardFocus: $keyboardFocus)
                .environment(chatViewModel)
        case .voice:
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
        if case .reconnecting = viewModel.connectionState {
            WarningView(warning: "warning.reconnecting")
        }

        if let error {
            ErrorView(error: error) { self.error = nil }
        }
        #endif
    }

    @ViewBuilder
    private func agentListening() -> some View {
        ZStack {
            if chatViewModel.messages.isEmpty,
               !viewModel.isCameraEnabled,
               !viewModel.isScreenShareEnabled
            {
                AgentListeningView()
            }
        }
        .animation(.default, value: chatViewModel.messages.isEmpty)
    }
}

#Preview {
    AppView()
}
