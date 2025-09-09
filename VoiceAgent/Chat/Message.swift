import Foundation

/// A message received from the agent.
struct ReceivedMessage: Identifiable, Equatable, Codable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Codable, Sendable {
        case agentTranscript(String)
        case userTranscript(String)
        case userText(String)
    }
}

/// A message sent to the agent.
struct SentMessage: Identifiable, Equatable, Codable, Sendable {
    let id: String
    let timestamp: Date
    let content: Content

    enum Content: Equatable, Codable, Sendable {
        case userText(String)
    }
}
