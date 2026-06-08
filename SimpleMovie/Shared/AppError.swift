import Foundation

struct AppError: Identifiable, Equatable, Sendable {
    let title: String
    let message: String
    let code: Int

    var id: Int { code }

    var codeText: String {
        "Error code: \(code)"
    }

    var alertMessage: String {
        "\(message)\n\n\(codeText)"
    }
}

extension AppError {
    static func movieListLoad(_ error: Error) -> AppError {
        remoteError(title: "Movies could not be loaded", error: error)
    }

    static func movieDetailsLoad(_ error: Error) -> AppError {
        remoteError(title: "Movie details could not be loaded", error: error)
    }

    static func watchlistLoad(_: Error) -> AppError {
        AppError(
            title: "Watchlist could not be loaded",
            message: "Your saved movies could not be read. Please try again.",
            code: 201
        )
    }

    static func watchlistUpdate(_: Error) -> AppError {
        AppError(
            title: "Watchlist could not be updated",
            message: "Your change could not be saved. Please try again.",
            code: 202
        )
    }

    private static func remoteError(title: String, error: Error) -> AppError {
        let reason = RemoteErrorReason(error: error)

        return AppError(
            title: title,
            message: reason.message,
            code: reason.code
        )
    }
}

private enum RemoteErrorReason {
    case invalidRequest
    case invalidResponse
    case unauthorized
    case missingResource
    case rateLimited
    case serviceUnavailable
    case responseFormat
    case noConnection
    case timeout
    case unknown

    init(error: Error) {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                self = .noConnection
            case .timedOut:
                self = .timeout
            default:
                self = .unknown
            }
            return
        }

        guard let clientError = error as? TMDBClientError else {
            self = .unknown
            return
        }

        switch clientError {
        case .invalidURL:
            self = .invalidRequest
        case .invalidResponse:
            self = .invalidResponse
        case let .httpStatus(statusCode):
            self = Self(statusCode: statusCode)
        case .decoding:
            self = .responseFormat
        }
    }

    private init(statusCode: Int) {
        switch statusCode {
        case 401, 403:
            self = .unauthorized
        case 404:
            self = .missingResource
        case 429:
            self = .rateLimited
        case 500...599:
            self = .serviceUnavailable
        default:
            self = .unknown
        }
    }

    var code: Int {
        switch self {
        case .invalidRequest:
            return 101
        case .invalidResponse:
            return 102
        case .unauthorized:
            return 103
        case .missingResource:
            return 104
        case .rateLimited:
            return 105
        case .serviceUnavailable:
            return 106
        case .responseFormat:
            return 107
        case .noConnection:
            return 108
        case .timeout:
            return 109
        case .unknown:
            return 199
        }
    }

    var message: String {
        switch self {
        case .invalidRequest:
            return "The app could not create a valid request. Please try again."
        case .invalidResponse:
            return "The movie service returned an invalid response. Please try again later."
        case .unauthorized:
            return "The movie service could not be reached with the current app configuration."
        case .missingResource:
            return "The requested movie information is no longer available."
        case .rateLimited:
            return "Too many requests were sent in a short time. Please try again later."
        case .serviceUnavailable:
            return "The movie service is currently unavailable. Please try again later."
        case .responseFormat:
            return "The movie service returned data the app could not read."
        case .noConnection:
            return "Please check your internet connection and try again."
        case .timeout:
            return "The request took too long. Please try again."
        case .unknown:
            return "Something unexpected happened. Please try again."
        }
    }
}
