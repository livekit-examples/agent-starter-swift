import Foundation

/// A message received from the agent.
struct ReceivedMessage: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Sendable {
        case agentTranscript(String)
        case userTranscript(String)
    }
}

/// A message sent to the agent.
struct SentMessage: Identifiable, Equatable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Sendable {
        case userText(String)
    }
}
