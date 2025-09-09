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
    var isReady: Bool {
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

    @Published private(set) var agentAudioTrack: (any AudioTrack)?
    @Published private(set) var avatarCameraTrack: (any VideoTrack)?

    @Published private(set) var messages: OrderedDictionary<ReceivedMessage.ID, ReceivedMessage> = [:]

    var _room: Room { room }

    // MARK: - Dependencies

    private let credentials: any CredentialsProvider
    private let room: Room
    private let senders: [any MessageSender]
    private let receivers: [any MessageReceiver]

    // MARK: - Internal state

    private var waitForAgentTask: Task<Void, Swift.Error>?

    // MARK: - Init

    init(credentials: CredentialsProvider, room: Room = .init(), senders: [any MessageSender]? = nil, receivers: [any MessageReceiver]? = nil) {
        self.credentials = credentials
        self.room = room

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

    func connect(preConnectAudio: Bool = true, waitForAgent: TimeInterval = 20, options: ConnectOptions? = nil, roomOptions: RoomOptions? = nil) async {
        guard connectionState == .disconnected else { return }

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

        do {
            if preConnectAudio {
                try await room.withPreConnectAudio(timeout: waitForAgent) {
                    await MainActor.run { self.isListening = true }
                    try await self.room.connect(credentialsProvider: self.credentials, connectOptions: options, roomOptions: roomOptions)
                    await MainActor.run { self.isListening = false }
                }
            } else {
                try await room.connect(credentialsProvider: credentials, connectOptions: options, roomOptions: roomOptions)
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

    // MARK: - Messages

    @discardableResult
    func send(text: String) async -> SentMessage {
        let message = SentMessage(id: UUID().uuidString, timestamp: Date(), content: .userInput(text))
        do {
            for sender in senders {
                try await sender.send(message)
            }
        } catch {
            self.error = .failedToSend(error)
        }
        return message
    }

    func getMessageHistory() -> [ReceivedMessage] {
        messages.values.elements
    }

    func restoreMessageHistory(_ messages: [ReceivedMessage]) {
        self.messages = .init(uniqueKeysWithValues: messages.sorted(by: { $0.timestamp < $1.timestamp }).map { ($0.id, $0) })
    }
}
