import Foundation

struct WatchlistItem: Identifiable, Hashable, Codable, Sendable {
    var id: Int { movie.id }
    let movie: Movie
    let addedAt: Date

    init(movie: Movie, addedAt: Date = .now) {
        self.movie = movie
        self.addedAt = addedAt
    }
}
