import Foundation

/// An example service for fetching LiveKit authentication tokens
///
/// To use the LiveKit Cloud sandbox (development only)
/// - Enable your sandbox here https://cloud.livekit.io/projects/p_/sandbox/templates/token-server
/// - Create .env.xcconfig with your LIVEKIT_SANDBOX_ID
///
/// To use a hardcoded token (development only)
/// - Generate a token: https://docs.livekit.io/home/cli/cli-setup/#generate-access-token
/// - Set `hardcodedServerUrl` and `hardcodedToken` below
///
/// To use your own server (production applications)
/// - Add a token endpoint to your server with a LiveKit Server SDK https://docs.livekit.io/home/server/generating-tokens/
/// - Modify or replace this class as needed to connect to your new token server
/// - Rejoice in your new production-ready LiveKit application!
///
/// See [docs](https://docs.livekit.io/home/get-started/authentication) for more information.
actor TokenService {
    struct ConnectionDetails: Codable {
        let serverUrl: String
        let roomName: String
        let participantName: String
        let participantToken: String
    }

    func fetchConnectionDetails(roomName: String, participantName: String) async throws -> ConnectionDetails? {
        if let hardcodedConnectionDetails = fetchHardcodedConnectionDetails(roomName: roomName, participantName: participantName) {
            return hardcodedConnectionDetails
        }

        return try await fetchConnectionDetailsFromSandbox(roomName: roomName, participantName: participantName)
    }

    private let hardcodedServerUrl: String? = nil
    private let hardcodedToken: String? = nil

    private let sandboxId: String? = {
        if let value = Bundle.main.object(forInfoDictionaryKey: "LiveKitSandboxId") as? String {
            // LK CLI will add unwanted double quotes
            return value.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        }
        return nil
    }()

    private let sandboxUrl: String = "https://cloud-api.livekit.io/api/sandbox/connection-details"
    private func fetchConnectionDetailsFromSandbox(roomName: String, participantName: String) async throws -> ConnectionDetails? {
        guard let sandboxId else {
            return nil
        }

        var urlComponents = URLComponents(string: sandboxUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "roomName", value: roomName),
            URLQueryItem(name: "participantName", value: participantName),
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        request.addValue(sandboxId, forHTTPHeaderField: "X-Sandbox-ID")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            debugPrint("Failed to connect to LiveKit Cloud sandbox")
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            debugPrint("Error from LiveKit Cloud sandbox: \(httpResponse.statusCode), response: \(httpResponse)")
            return nil
        }

        guard let connectionDetails = try? JSONDecoder().decode(ConnectionDetails.self, from: data) else {
            debugPrint("Error parsing connection details from LiveKit Cloud sandbox, response: \(httpResponse)")
            return nil
        }

        return connectionDetails
    }

    private func fetchHardcodedConnectionDetails(roomName: String, participantName: String) -> ConnectionDetails? {
        guard let serverUrl = hardcodedServerUrl, let token = hardcodedToken else {
            return nil
        }

        return .init(
            serverUrl: serverUrl,
            roomName: roomName,
            participantName: participantName,
            participantToken: token
        )
    }
}
