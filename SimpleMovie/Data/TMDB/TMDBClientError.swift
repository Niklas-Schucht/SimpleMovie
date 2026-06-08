import Foundation

enum TMDBClientError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding
}
