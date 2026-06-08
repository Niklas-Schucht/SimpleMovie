import Foundation

enum TMDBEndpoint {
    case movieList(page: Int = 1)
    case movieDetails(id: Int)

    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3\(path)"
        components.queryItems = queryItems
        return components.url
    }

    private var path: String {
        switch self {
        case .movieList:
            return "/movie/popular"
        case let .movieDetails(id):
            return "/movie/\(id)"
        }
    }

    private var queryItems: [URLQueryItem] {
        switch self {
        case let .movieList(page):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "language", value: "en-US")
            ]
        case .movieDetails:
            return [
                URLQueryItem(name: "language", value: "en-US")
            ]
        }
    }
}
