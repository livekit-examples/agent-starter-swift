import Foundation
import LiveKit

typealias Agent = Participant

extension AgentSession {
    enum Error: LocalizedError {
        case agentNotConnected
        case failedToConnect(Swift.Error)
        case failedToSend(Swift.Error)

//        var errorDescription: String? {
//            switch self {
//            case .agentNotConnected:
//                "Agent did not connect to the Room"
//            }
//        }
    }
}
