import Foundation
import LiveKit

public struct Credentials: Decodable {
    let serverUrl: URL
    let participantToken: String
    let participantName: String?
    let roomName: String?
}

public protocol CredentialsProvider: Sendable {
    func credentials() async throws -> Credentials
}

public extension Room {
    func connect(credentialsProvider: CredentialsProvider,
                 connectOptions: ConnectOptions? = nil,
                 roomOptions: RoomOptions? = nil) async throws
    {
        let credentials = try await credentialsProvider.credentials()
        try await connect(url: credentials.serverUrl.absoluteString, token: credentials.participantToken, connectOptions: connectOptions, roomOptions: roomOptions)
    }
}

/// A service for fetching LiveKit authentication tokens.
/// See [docs](https://docs.livekit.io/home/get-started/authentication/) for more information.
public struct Sandbox: CredentialsProvider {
    private static let url: URL = .init(string: "https://cloud-api.livekit.io/api/sandbox/connection-details")!

    enum Error: Swift.Error {
        case noResponse
        case unsuccessfulStatusCode(Int)
        case decoding(Swift.Error)
    }

    let id: String

    public func credentials() async throws -> Credentials {
        var request = URLRequest(url: Self.url)
        request.httpMethod = "POST"
        request.addValue(id.trimmingCharacters(in: CharacterSet(charactersIn: "\"")), forHTTPHeaderField: "X-Sandbox-ID")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.noResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw Error.unsuccessfulStatusCode(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(Credentials.self, from: data)
        } catch {
            throw Error.decoding(error)
        }
    }
}

extension Credentials: CredentialsProvider {
    public func credentials() async throws -> Credentials {
        self
    }
}
