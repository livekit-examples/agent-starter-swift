@preconcurrency import AVFoundation
import Combine
import LiveKit
import Observation

/// The main view model encapsulating root states and behaviors of the app
/// such as connection, published tracks, etc.
///
/// It consumes `LiveKit.Room` object, observing its internal state and propagating appropriate changes.
/// It does not expose any publicly mutable state, encouraging unidirectional data flow.
@MainActor
@Observable
final class AppViewModel {
    // MARK: - Constants

    private enum Constants {
        static let agentConnectionTimeout: TimeInterval = 20
    }

    // MARK: - Errors

    enum Error: LocalizedError {
        case agentNotConnected

        var errorDescription: String? {
            switch self {
            case .agentNotConnected:
                "Agent did not connect to the Room"
            }
        }
    }

    // MARK: - Modes

    enum InteractionMode {
        case voice
        case text
    }

    let agentFeatures: AgentFeatures

    // MARK: - State

    // MARK: Connection

    private(set) var connectionState: ConnectionState = .disconnected
    private(set) var isListening = false
    var isInteractive: Bool {
        switch connectionState {
        case .disconnected where isListening,
             .connecting where isListening,
             .connected,
             .reconnecting:
            true
        default:
            false
        }
    }

    private(set) var agent: Participant?

    private(set) var interactionMode: InteractionMode = .voice

    // MARK: Tracks

    private(set) var isMicrophoneEnabled = false
    private(set) var audioTrack: (any AudioTrack)?
    private(set) var isCameraEnabled = false
    private(set) var cameraTrack: (any VideoTrack)?
    private(set) var isScreenShareEnabled = false
    private(set) var screenShareTrack: (any VideoTrack)?

    private(set) var agentAudioTrack: (any AudioTrack)?
    private(set) var avatarCameraTrack: (any VideoTrack)?

    // MARK: Devices

    private(set) var audioDevices: [AudioDevice] = AudioManager.shared.inputDevices
    private(set) var selectedAudioDeviceID: String = AudioManager.shared.inputDevice.deviceId

    private(set) var videoDevices: [AVCaptureDevice] = []
    private(set) var selectedVideoDeviceID: String?

    private(set) var canSwitchCamera = false

    // MARK: - Dependencies

    @ObservationIgnored
    @Dependency(\.room) private var room
    @ObservationIgnored
    @Dependency(\.tokenService) private var tokenService
    @ObservationIgnored
    @Dependency(\.errorHandler) private var errorHandler

    // MARK: - Initialization

    init(agentFeatures: AgentFeatures = .current) {
        self.agentFeatures = agentFeatures

        observeRoom()
        observeDevices()
    }

    private func observeRoom() {
        Task { [weak self] in
            guard let changes = self?.room.changes else { return }
            for await _ in changes {
                guard let self else { return }

                connectionState = room.connectionState
                agent = room.agentParticipant

                isMicrophoneEnabled = room.localParticipant.isMicrophoneEnabled()
                audioTrack = room.localParticipant.firstAudioTrack
                isCameraEnabled = room.localParticipant.isCameraEnabled()
                cameraTrack = room.localParticipant.firstCameraVideoTrack
                isScreenShareEnabled = room.localParticipant.isScreenShareEnabled()
                screenShareTrack = room.localParticipant.firstScreenShareVideoTrack

                agentAudioTrack = room.agentParticipant?.audioTracks
                    .first(where: { $0.source == .microphone })?.track as? AudioTrack
                avatarCameraTrack = room.agentParticipant?.avatarWorker?.firstCameraVideoTrack
            }
        }
    }

    private func observeDevices() {
        do {
            try AudioManager.shared.set(microphoneMuteMode: .inputMixer) // don't play mute sound effect
            try AudioManager.shared.setRecordingAlwaysPreparedMode(true)
        } catch {
            errorHandler(error)
        }

        AudioManager.shared.onDeviceUpdate = { [weak self] _ in
            Task { @MainActor in
                self?.audioDevices = AudioManager.shared.inputDevices
                self?.selectedAudioDeviceID = AudioManager.shared.defaultInputDevice.deviceId
            }
        }

        Task {
            do {
                canSwitchCamera = try await CameraCapturer.canSwitchPosition()
                videoDevices = try await CameraCapturer.captureDevices()
                selectedVideoDeviceID = videoDevices.first?.uniqueID
            } catch {
                errorHandler(error)
            }
        }
    }

    deinit {
        AudioManager.shared.onDeviceUpdate = nil
    }

    private func resetState() {
        isListening = false
        interactionMode = .voice
    }

    // MARK: - Connection

    func connect() async {
        errorHandler(nil)
        resetState()
        do {
            if agentFeatures.contains(.voice) {
                try await connectWithVoice()
            } else {
                try await connectWithoutVoice()
            }

            try await checkAgentConnected()
        } catch {
            errorHandler(error)
            resetState()
        }
    }

    /// Connect and enable microphone, capture pre-connect audio
    private func connectWithVoice() async throws {
        try await room.withPreConnectAudio {
            await MainActor.run { self.isListening = true }

            let connectionDetails = try await self.getConnection()

            try await self.room.connect(
                url: connectionDetails.serverUrl,
                token: connectionDetails.participantToken,
                connectOptions: .init(enableMicrophone: true)
            )
        }
    }

    /// Connect without enabling microphone
    private func connectWithoutVoice() async throws {
        let connectionDetails = try await getConnection()

        try await room.connect(
            url: connectionDetails.serverUrl,
            token: connectionDetails.participantToken,
            connectOptions: .init(enableMicrophone: false)
        )
    }

    private func getConnection() async throws -> TokenService.ConnectionDetails {
        let roomName = "room-\(Int.random(in: 1000 ... 9999))"
        let participantName = "user-\(Int.random(in: 1000 ... 9999))"

        return try await tokenService.fetchConnectionDetails(
            roomName: roomName,
            participantName: participantName
        )!
    }

    func disconnect() async {
        await room.disconnect()
        resetState()
    }

    private func checkAgentConnected() async throws {
        try await Task.sleep(for: .seconds(Constants.agentConnectionTimeout))
        if connectionState == .connected, agent == nil {
            await disconnect()
            throw Error.agentNotConnected
        }
    }

    // MARK: - Actions

    func toggleTextInput() {
        switch interactionMode {
        case .voice:
            interactionMode = .text
        case .text:
            interactionMode = .voice
        }
    }

    func toggleMicrophone() async {
        do {
            try await room.localParticipant.setMicrophone(enabled: !isMicrophoneEnabled)
        } catch {
            errorHandler(error)
        }
    }

    func toggleCamera() async {
        let enable = !isCameraEnabled
        do {
            // One video track at a time
            if enable, isScreenShareEnabled {
                try await room.localParticipant.setScreenShare(enabled: false)
            }

            let device = try await CameraCapturer.captureDevices().first(where: { $0.uniqueID == selectedVideoDeviceID })
            try await room.localParticipant.setCamera(enabled: enable, captureOptions: CameraCaptureOptions(device: device))
        } catch {
            errorHandler(error)
        }
    }

    func toggleScreenShare() async {
        let enable = !isScreenShareEnabled
        do {
            // One video track at a time
            if enable, isCameraEnabled {
                try await room.localParticipant.setCamera(enabled: false)
            }
            try await room.localParticipant.setScreenShare(enabled: enable)
        } catch {
            errorHandler(error)
        }
    }

    #if os(macOS)
    func select(audioDevice: AudioDevice) {
        selectedAudioDeviceID = audioDevice.deviceId

        let device = AudioManager.shared.inputDevices.first(where: { $0.deviceId == selectedAudioDeviceID }) ?? AudioManager.shared.defaultInputDevice
        AudioManager.shared.inputDevice = device
    }

    func select(videoDevice: AVCaptureDevice) async {
        selectedVideoDeviceID = videoDevice.uniqueID

        guard let cameraCapturer = getCameraCapturer() else { return }
        do {
            let captureOptions = CameraCaptureOptions(device: videoDevice)
            try await cameraCapturer.set(options: captureOptions)
        } catch {
            errorHandler(error)
        }
    }
    #endif

    func switchCamera() async {
        guard let cameraCapturer = getCameraCapturer() else { return }
        do {
            try await cameraCapturer.switchCameraPosition()
        } catch {
            errorHandler(error)
        }
    }

    private func getCameraCapturer() -> CameraCapturer? {
        guard let cameraTrack = cameraTrack as? LocalVideoTrack else { return nil }
        return cameraTrack.capturer as? CameraCapturer
    }
}
