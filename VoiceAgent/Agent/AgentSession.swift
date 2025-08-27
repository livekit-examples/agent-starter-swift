import Collections
import Foundation
import LiveKit

@MainActor
final class AgentSession: ObservableObject {
    // MARK: - State

    @Published private(set) var error: Error?

    @Published private(set) var agent: Agent?

    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var isListening = false
    var isAvailable: Bool {
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

    @Published private(set) var localAudioTrack: (any AudioTrack)?
    @Published private(set) var localCameraTrack: (any VideoTrack)?
    @Published private(set) var localScreenShareTrack: (any VideoTrack)?

    // TODO: Move camera switching here (vs Devices)?

    var isMicrophoneEnabled: Bool { localAudioTrack != nil }
    var isCameraEnabled: Bool { localCameraTrack != nil }
    var isScreenShareEnabled: Bool { localScreenShareTrack != nil }

    @Published private(set) var agentAudioTrack: (any AudioTrack)?
    @Published private(set) var avatarCameraTrack: (any VideoTrack)?

    @Published private(set) var messages: OrderedDictionary<ReceivedMessage.ID, ReceivedMessage> = [:]

    var supportedFeatures: Features { features }

    // MARK: - Dependencies

    private let environment: Environment
    private let room: Room
    private let features: Features
    private let senders: [any MessageSender]
    private let receivers: [any MessageReceiver]

    // MARK: - Internal state

    private var waitForAgentTask: Task<Void, Swift.Error>?

    // MARK: - Init

    init(environment: Environment, context: Context = .init(), senders: [any MessageSender]? = nil, receivers: [any MessageReceiver]? = nil) {
        self.environment = environment
        room = context.room
        features = context.features

        let textMessageSender = TextMessageSender(room: room)
        self.senders = senders ?? [textMessageSender]
        self.receivers = receivers ?? [textMessageSender, TranscriptionStreamReceiver(room: room)]

        observeRoom()
        observeReceivers()
    }

    private func observeRoom() {
        Task { [weak self] in
            guard let changes = self?.room.changes else { return }
            for await _ in changes {
                guard let self else { return }

                connectionState = room.connectionState
                agent = room.agentParticipant

                localAudioTrack = room.localParticipant.firstAudioTrack
                localCameraTrack = room.localParticipant.firstCameraVideoTrack
                localScreenShareTrack = room.localParticipant.firstScreenShareVideoTrack

                agentAudioTrack = room.agentParticipant?.audioTracks.first(where: { $0.source == .microphone })?.track as? AudioTrack // remove bg audio tracks
                avatarCameraTrack = room.agentParticipant?.avatarWorker?.firstCameraVideoTrack
            }
        }
    }

    private func observeReceivers() {
        for receiver in receivers {
            Task { [weak self] in
                for await message in try await receiver.messages() {
                    guard let self else { return }
                    messages.updateValue(message, forKey: message.id)
                }
            }
        }
    }

    // MARK: - Public

    func connect(options: ConnectOptions? = nil, roomOptions: RoomOptions? = nil, preConnectAudio: Bool = true, waitForAgent: TimeInterval = 20) async {
        error = nil
        waitForAgentTask?.cancel()

        defer {
            waitForAgentTask = Task {
                try await Task.sleep(for: .seconds(waitForAgent))
                try Task.checkCancellation()
                if connectionState == .connected, agent == nil {
                    await disconnect()
                    self.error = .agentNotConnected
                }
            }
        }

        let connection = { @Sendable in
            let (server, token) = try await self.credentials()
            try await self.room.connect(url: server, token: token, connectOptions: options, roomOptions: roomOptions)
        }

        do {
            if preConnectAudio {
                try await room.withPreConnectAudio(timeout: waitForAgent) {
                    await MainActor.run { self.isListening = true }
                    try await connection()
                    await MainActor.run { self.isListening = false }
                }
            } else {
                try await connection()
            }
        } catch {
            self.error = .failedToConnect(error)
        }
    }

    func disconnect() async {
        await room.disconnect()
    }

    func resetError() {
        error = nil
    }

    func send(message: SentMessage) async {
        do {
            for sender in senders {
                try await sender.send(message)
            }
        } catch {
            self.error = .failedToSend(error)
        }
    }

    func getMessageHistory() -> [ReceivedMessage] {
        messages.values.elements
    }

    func restoreMessageHistory(_ messages: [ReceivedMessage]) {
        self.messages = .init(uniqueKeysWithValues: messages.sorted(by: { $0.timestamp < $1.timestamp }).map { ($0.id, $0) })
    }

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

            // Hm???
//            let device = try await CameraCapturer.captureDevices().first(where: { $0.uniqueID == selectedVideoDeviceID })
            try await room.localParticipant.setCamera(enabled: enable) // captureOptions: CameraCaptureOptions(device: device))
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

    // MARK: - Private

    private func credentials() async throws -> (server: String, token: String) {
        switch environment {
        case let .sandbox(id, room, participant):
            let sandboxConnection = try await Sandbox.getConnection(id: id, roomName: room, participantName: participant)
            return (sandboxConnection.serverUrl, sandboxConnection.participantToken)
        case let .cloud(server, token):
            return (server, token)
        }
    }
}
