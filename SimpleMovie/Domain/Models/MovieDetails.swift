struct MovieDetails: Identifiable, Hashable, Codable, Sendable {

    let id: Int
    let genres: [Genre]
    let title: String
    let overview: String
    let tagline: String?
    let popularity: Double
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let backdropPath: String?
    let posterPath: String?
}
