import Foundation
import SwiftData

@Model
final class WatchlistMovieEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var overview: String
    var popularity: Double
    var releaseDate: String?
    var voteAverage: Double
    var voteCount: Int
    var backdropPath: String?
    var posterPath: String?
    var addedAt: Date

    init(movie: Movie, addedAt: Date = .now) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.popularity = movie.popularity
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.backdropPath = movie.backdropPath
        self.posterPath = movie.posterPath
        self.addedAt = addedAt
    }
}
