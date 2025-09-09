@preconcurrency import AVFoundation
import LiveKit

@MainActor
final class DeviceSwitcher: ObservableObject {
    // MARK: Error

    enum Error: LocalizedError {
        case mediaDevice(Swift.Error)
    }

    // MARK: Devices

    @Published private(set) var error: Error?

    @Published private(set) var localAudioTrack: (any AudioTrack)?
    @Published private(set) var localCameraTrack: (any VideoTrack)?
    @Published private(set) var localScreenShareTrack: (any VideoTrack)?

    var isMicrophoneEnabled: Bool { localAudioTrack != nil }
    var isCameraEnabled: Bool { localCameraTrack != nil }
    var isScreenShareEnabled: Bool { localScreenShareTrack != nil }

    @Published private(set) var audioDevices: [AudioDevice] = AudioManager.shared.inputDevices
    @Published private(set) var selectedAudioDeviceID: String = AudioManager.shared.inputDevice.deviceId

    @Published private(set) var videoDevices: [AVCaptureDevice] = []
    @Published private(set) var selectedVideoDeviceID: String?

    @Published private(set) var canSwitchCamera = false

    // MARK: - Dependencies

    private var room: Room

    // MARK: - Initialization

    init(room: Room) {
        self.room = room

        observeRoom()
        observeDevices()
    }

    private func observeRoom() {
        Task { [weak self] in
            guard let changes = self?.room.changes else { return }
            for await _ in changes {
                guard let self else { return }

                localAudioTrack = room.localParticipant.firstAudioTrack
                localCameraTrack = room.localParticipant.firstCameraVideoTrack
                localScreenShareTrack = room.localParticipant.firstScreenShareVideoTrack
            }
        }
    }

    private func observeDevices() {
        try? AudioManager.shared.set(microphoneMuteMode: .inputMixer) // don't play mute sound effect
        Task {
            try await AudioManager.shared.setRecordingAlwaysPreparedMode(true)
        }

        AudioManager.shared.onDeviceUpdate = { [weak self] _ in
            Task { @MainActor in
                self?.audioDevices = AudioManager.shared.inputDevices
                self?.selectedAudioDeviceID = AudioManager.shared.defaultInputDevice.deviceId
            }
        }

        Task {
            canSwitchCamera = try await CameraCapturer.canSwitchPosition()
            videoDevices = try await CameraCapturer.captureDevices()
            selectedVideoDeviceID = videoDevices.first?.uniqueID
        }
    }

    deinit {
        AudioManager.shared.onDeviceUpdate = nil
    }

    // MARK: - Toggle

    func toggleMicrophone() async {
        do {
            try await room.localParticipant.setMicrophone(enabled: !isMicrophoneEnabled)
        } catch {
            self.error = .mediaDevice(error)
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
            self.error = .mediaDevice(error)
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
            self.error = .mediaDevice(error)
        }
    }

    // MARK: - Select

    func select(audioDevice: AudioDevice) {
        selectedAudioDeviceID = audioDevice.deviceId

        let device = AudioManager.shared.inputDevices.first(where: { $0.deviceId == selectedAudioDeviceID }) ?? AudioManager.shared.defaultInputDevice
        AudioManager.shared.inputDevice = device
    }

    func select(videoDevice: AVCaptureDevice) async {
        selectedVideoDeviceID = videoDevice.uniqueID

        guard let cameraCapturer = getCameraCapturer() else { return }
        let captureOptions = CameraCaptureOptions(device: videoDevice)
        _ = try? await cameraCapturer.set(options: captureOptions)
    }

    func switchCamera() async {
        guard let cameraCapturer = getCameraCapturer() else { return }
        _ = try? await cameraCapturer.switchCameraPosition()
    }

    // MARK: - Private

    private func getCameraCapturer() -> CameraCapturer? {
        guard let cameraTrack = room.localParticipant.firstCameraVideoTrack as? LocalVideoTrack else { return nil }
        return cameraTrack.capturer as? CameraCapturer
    }
}
