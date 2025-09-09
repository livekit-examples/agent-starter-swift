import Foundation
import LiveKit

typealias Agent = Participant

extension AgentSession {
    enum Error: LocalizedError {
        case agentNotConnected
        case failedToConnect(Swift.Error)
        case failedToSend(Swift.Error)
        case mediaDevice(Swift.Error)

//        var errorDescription: String? {
//            switch self {
//            case .agentNotConnected:
//                "Agent did not connect to the Room"
//            }
//        }
    }

    struct Options {
        let room: Room

        init(room: Room = .init()) {
            self.room = room
        }
    }

    enum Environment {
        // .envfile?
        case sandbox(id: String, room: String = "room-\(Int.random(in: 1000 ... 9999))", participant: String = "participant-\(Int.random(in: 1000 ... 9999))")
        case cloud(server: String, token: String)
    }
}
