import Foundation

enum WatchlistMapper {
    static func map(_ entity: WatchlistMovieEntity) -> WatchlistItem {
        WatchlistItem(
            movie: Movie(
                id: entity.id,
                title: entity.title,
                overview: entity.overview,
                popularity: entity.popularity,
                releaseDate: entity.releaseDate,
                voteAverage: entity.voteAverage,
                voteCount: entity.voteCount,
                backdropPath: entity.backdropPath,
                posterPath: entity.posterPath
            ),
            addedAt: entity.addedAt
        )
    }

    static func update(_ entity: WatchlistMovieEntity, with movie: Movie) {
        entity.title = movie.title
        entity.overview = movie.overview
        entity.popularity = movie.popularity
        entity.releaseDate = movie.releaseDate
        entity.voteAverage = movie.voteAverage
        entity.voteCount = movie.voteCount
        entity.backdropPath = movie.backdropPath
        entity.posterPath = movie.posterPath
    }
}
