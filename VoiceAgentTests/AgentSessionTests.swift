import Testing
@testable import VoiceAgent

@MainActor
struct AgentSessionTests {
    @Test func multipleReceivers() async throws {
        let receiver1 = MockMessageReceiver()
        let receiver2 = MockMessageReceiver()

        let message1 = ReceivedMessage(
            id: "1",
            timestamp: .init(),
            content: .userTranscript("Hello")
        )
        let message2 = ReceivedMessage(
            id: "2",
            timestamp: .init(),
            content: .agentTranscript("Hi there")
        )

        let session = AgentSession(environment: .sandbox(id: ""), receivers: [receiver1, receiver2])

        try await Task.sleep(for: .milliseconds(100))
        await receiver1.postMessage(message1)
        try await Task.sleep(for: .milliseconds(100))
        await receiver2.postMessage(message2)
        try await Task.sleep(for: .milliseconds(100))

        #expect(session.messages.count == 2)
        #expect(session.messages["1"]?.content == .userTranscript("Hello"))
        #expect(session.messages["2"]?.content == .agentTranscript("Hi there"))

        let orderedMessages = session.getMessageHistory()
        #expect(orderedMessages.count == 2)
        #expect(orderedMessages[0].id == "1")
        #expect(orderedMessages[1].id == "2")
    }
}

actor MockMessageReceiver: MessageReceiver {
    private var continuation: AsyncStream<ReceivedMessage>.Continuation?

    func messages() async throws -> AsyncStream<ReceivedMessage> {
        let (stream, continuation) = AsyncStream.makeStream(of: ReceivedMessage.self)
        self.continuation = continuation
        return stream
    }

    func postMessage(_ message: ReceivedMessage) {
        continuation?.yield(message)
    }
}
