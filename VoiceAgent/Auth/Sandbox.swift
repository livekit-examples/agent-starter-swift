import Foundation

/// A service for fetching LiveKit authentication tokens.
/// See [docs](https://docs.livekit.io/home/get-started/authentication) for more information.
enum Sandbox {
    enum Error: Swift.Error {
        case noResponse
        case unsuccessfulStatusCode(Int)
        case decoding(Swift.Error)
    }

    struct Connection: Decodable {
        let serverUrl: String
        let participantToken: String
    }

    private static let url: String = "https://cloud-api.livekit.io/api/sandbox/connection-details"

    static func getConnection(id: String, roomName: String, participantName: String) async throws -> Connection {
        var urlComponents = URLComponents(string: url)!
        urlComponents.queryItems = [
            URLQueryItem(name: "roomName", value: roomName),
            URLQueryItem(name: "participantName", value: participantName),
        ]

        var request = URLRequest(url: urlComponents.url!)
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
            return try JSONDecoder().decode(Connection.self, from: data)
        } catch {
            throw Error.decoding(error)
        }
    }
}
