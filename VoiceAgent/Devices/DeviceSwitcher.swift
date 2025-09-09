@preconcurrency import AVFoundation
import LiveKit

@MainActor
final class DeviceSwitcher: ObservableObject {
    // MARK: Devices

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

        observeDevices()
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

    // MARK: - Actions

    #if os(macOS)
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
    #endif

    // TODO: Move that to session?
    func switchCamera() async {
        guard let cameraCapturer = getCameraCapturer() else { return }
        _ = try? await cameraCapturer.switchCameraPosition()
    }

    private func getCameraCapturer() -> CameraCapturer? {
        guard let cameraTrack = room.localParticipant.firstCameraVideoTrack as? LocalVideoTrack else { return nil }
        return cameraTrack.capturer as? CameraCapturer
    }
}
