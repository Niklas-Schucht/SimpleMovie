import Foundation

struct MoviePage: Equatable, Sendable {
    let movies: [Movie]
    let page: Int
    let totalPages: Int

    var hasMorePages: Bool {
        page < totalPages
    }
}
