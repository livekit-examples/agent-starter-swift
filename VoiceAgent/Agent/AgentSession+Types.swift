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

    struct Features: OptionSet {
        let rawValue: Int

        static let voice = Self(rawValue: 1 << 0)
        static let text = Self(rawValue: 1 << 1)
        static let video = Self(rawValue: 1 << 2)

        static let all: Self = [.voice, .text, .video]
    }

    struct Context {
        let room: Room
        let features: Features

        init(room: Room = .init(), features: Features = .all) {
            self.room = room
            self.features = features
        }
    }

    enum Environment {
        // .envfile?
        case sandbox(id: String, room: String = "room-\(Int.random(in: 1000 ... 9999))", participant: String = "participant-\(Int.random(in: 1000 ... 9999))")
        case cloud(server: String, token: String)
    }
}
