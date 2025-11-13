import LiveKitComponents

/// A multiplatform view that shows the control bar: audio/video and chat controls.
/// Available controls depend on the agent features and the track availability.
/// - SeeAlso: ``AgentFeatures``
struct ControlBar: View {
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var localMedia: LocalMedia

    @Binding var chat: Bool
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.voiceEnabled) private var voiceEnabled
    @Environment(\.videoEnabled) private var videoEnabled
    @Environment(\.textEnabled) private var textEnabled

    private enum Constants {
        static let buttonWidth: CGFloat = 16 * .grid
        static let buttonHeight: CGFloat = 11 * .grid
    }

    var body: some View {
        HStack(spacing: .zero) {
            biggerSpacer()
            if voiceEnabled {
                audioControls()
                flexibleSpacer()
            }
            if videoEnabled {
                videoControls()
                flexibleSpacer()
                screenShareButton()
                flexibleSpacer()
            }
            if textEnabled {
                textInputButton()
                flexibleSpacer()
            }
            disconnectButton()
            biggerSpacer()
        }
        .buttonStyle(
            ControlBarButtonStyle(
                foregroundColor: .fg1,
                backgroundColor: .bg2,
                borderColor: .separator1
            )
        )
        .font(.system(size: 17, weight: .medium))
        .frame(height: 15 * .grid)
        #if !os(visionOS)
            .overlay(
                RoundedRectangle(cornerRadius: 7.5 * .grid)
                    .stroke(.separator1, lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 7.5 * .grid)
                    .fill(.bg1)
                    .shadow(color: .black.opacity(0.1), radius: 10, y: 10)
            )
            .safeAreaPadding(.bottom, 8 * .grid)
            .safeAreaPadding(.horizontal, 16 * .grid)
        #endif
    }

    @ViewBuilder
    private func flexibleSpacer() -> some View {
        Spacer()
            .frame(maxWidth: horizontalSizeClass == .regular ? 8 * .grid : 2 * .grid)
    }

    @ViewBuilder
    private func biggerSpacer() -> some View {
        Spacer()
            .frame(maxWidth: horizontalSizeClass == .regular ? 8 * .grid : .infinity)
    }

    @ViewBuilder
    private func separator() -> some View {
        Rectangle()
            .fill(.separator1)
            .frame(width: 1, height: 3 * .grid)
    }

    @ViewBuilder
    private func audioControls() -> some View {
        HStack(spacing: .zero) {
            Spacer()
            AsyncButton(action: localMedia.toggleMicrophone) {
                HStack(spacing: .grid) {
                    Image(systemName: localMedia.isMicrophoneEnabled ? "microphone.fill" : "microphone.slash.fill")
                        .transition(.symbolEffect)
                    BarAudioVisualizer(audioTrack: localMedia.microphoneTrack, barColor: .fg1, barCount: 3, barSpacingFactor: 0.1)
                        .frame(width: 2 * .grid, height: 0.5 * Constants.buttonHeight)
                        .frame(maxHeight: .infinity)
                        .id(localMedia.microphoneTrack?.id)
                }
                .frame(height: Constants.buttonHeight)
                .padding(.horizontal, 2 * .grid)
                .contentShape(Rectangle())
            }
            #if os(macOS)
            separator()
            AudioDeviceSelector()
                .frame(height: Constants.buttonHeight)
            #endif
            Spacer()
        }
        .frame(width: Constants.buttonWidth)
    }

    @ViewBuilder
    private func videoControls() -> some View {
        HStack(spacing: .zero) {
            Spacer()
            AsyncButton {
                await localMedia.toggleCamera(disableScreenShare: true)
            } label: {
                Image(systemName: localMedia.isCameraEnabled ? "video.fill" : "video.slash.fill")
                    .transition(.symbolEffect)
                    .frame(height: Constants.buttonHeight)
                    .padding(.horizontal, 2 * .grid)
                    .contentShape(Rectangle())
            }
            #if os(macOS)
            separator()
            VideoDeviceSelector()
                .frame(height: Constants.buttonHeight)
            #endif
            Spacer()
        }
        .frame(width: Constants.buttonWidth)
        .disabled(!session.agent.isConnected)
    }

    @ViewBuilder
    private func screenShareButton() -> some View {
        AsyncButton {
            await localMedia.toggleScreenShare(disableCamera: true)
        } label: {
            Image(systemName: "arrow.up.square.fill")
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(
            ControlBarButtonStyle(
                isToggled: localMedia.isScreenShareEnabled,
                foregroundColor: .fg1,
                backgroundColor: .bg2,
                borderColor: .separator1
            )
        )
        .disabled(!session.agent.isConnected)
    }

    @ViewBuilder
    private func textInputButton() -> some View {
        Button {
            chat.toggle()
        } label: {
            Image(systemName: "ellipsis.message.fill")
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(
            ControlBarButtonStyle(
                isToggled: chat,
                foregroundColor: .fg1,
                backgroundColor: .bg2,
                borderColor: .separator1
            )
        )
        .disabled(!session.agent.isConnected)
    }

    @ViewBuilder
    private func disconnectButton() -> some View {
        AsyncButton {
            await session.end()
            session.restoreMessageHistory([])
        } label: {
            Image(systemName: "phone.down.fill")
                .frame(width: Constants.buttonWidth, height: Constants.buttonHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(
            ControlBarButtonStyle(
                foregroundColor: .fgSerious,
                backgroundColor: .bgSerious,
                borderColor: .separatorSerious
            )
        )
        .disabled(!session.isConnected)
    }
}
