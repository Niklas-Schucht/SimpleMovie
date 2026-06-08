import Foundation

/// Small HTTP client responsible for authenticated TMDB requests and JSON decoding.
struct TMDBClient {
    private let accessToken: String
    private let session: URLSession
    private let decoder: JSONDecoder

    init(accessToken: String, session: URLSession = .shared) {
        self.accessToken = accessToken
        self.session = session

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    /// Sends a GET request to TMDB and decodes the response into the expected DTO.
    /// - Parameter endpoint: The TMDB endpoint to call.
    func send<Response: Decodable>(_ endpoint: TMDBEndpoint) async throws -> Response {
        guard let url = endpoint.url else {
            throw TMDBClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TMDBClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw TMDBClientError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw TMDBClientError.decoding
        }
    }
}
