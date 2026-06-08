import Foundation

struct TMDBPagedResponse<Item: Decodable>: Decodable {
    let page: Int
    let results: [Item]
    let totalPages: Int
}

struct TMDBMovieDTO: Decodable {
    let backdropPath: String?
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
}

struct TMDBMovieDetailsDTO: Decodable {
    let backdropPath: String?
    let genres: [TMDBGenreDTO]
    let id: Int
    let title: String
    let overview: String
    let tagline: String?
    let posterPath: String?
    let releaseDate: String?
    let runtime: Int?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
}

struct TMDBGenreDTO: Decodable {
    let id: Int
    let name: String
}
