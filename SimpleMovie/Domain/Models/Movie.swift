import Foundation

struct Movie: Identifiable, Hashable, Codable, Sendable {

    let id: Int
    let title: String
    let overview: String
    let popularity: Double
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let backdropPath: String?
    let posterPath: String?
}

extension Movie {
    init(details: MovieDetails) {
        self.id = details.id
        self.title = details.title
        self.overview = details.overview
        self.popularity = details.popularity
        self.releaseDate = details.releaseDate
        self.voteAverage = details.voteAverage
        self.voteCount = details.voteCount
        self.backdropPath = details.backdropPath
        self.posterPath = details.posterPath
    }
}
