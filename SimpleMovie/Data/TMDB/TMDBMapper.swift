import Foundation

enum TMDBMapper {
    static func mapMovie(_ dto: TMDBMovieDTO) -> Movie {
        Movie(
            id: dto.id,
            title: dto.title,
            overview: dto.overview,
            popularity: dto.popularity,
            releaseDate: dto.releaseDate,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            backdropPath: dto.backdropPath,
            posterPath: dto.posterPath
        )
    }

    static func mapMovieDetails(_ dto: TMDBMovieDetailsDTO) -> MovieDetails {
        MovieDetails(
            id: dto.id,
            genres: dto.genres.map { Genre(id: $0.id, name: $0.name) },
            title: dto.title,
            overview: dto.overview,
            tagline: dto.tagline,
            popularity: dto.popularity,
            releaseDate: dto.releaseDate,
            runtime: dto.runtime,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            backdropPath: dto.backdropPath,
            posterPath: dto.posterPath
        )
    }
}
