import Foundation
@testable import SimpleMovie

enum TestDataFactory {
    static func movie(
        id: Int = 1,
        title: String? = nil,
        overview: String? = nil
    ) -> Movie {
        Movie(
            id: id,
            title: title ?? "Movie \(id)",
            overview: overview ?? "Overview \(id)",
            popularity: Double(id),
            releaseDate: "2026-01-\(String(format: "%02d", min(id, 28)))",
            voteAverage: Double(id % 10) + 0.5,
            voteCount: id * 10,
            backdropPath: "/backdrop-\(id).jpg",
            posterPath: "/poster-\(id).jpg"
        )
    }

    static func movies(_ ids: [Int]) -> [Movie] {
        ids.map { movie(id: $0) }
    }

    static func movieDetails(
        id: Int = 1,
        title: String? = nil
    ) -> MovieDetails {
        MovieDetails(
            id: id,
            genres: [
                Genre(id: 1, name: "Drama")
            ],
            title: title ?? "Movie \(id)",
            overview: "Overview \(id)",
            tagline: "Tagline \(id)",
            popularity: Double(id),
            releaseDate: "2026-01-\(String(format: "%02d", min(id, 28)))",
            runtime: 120,
            voteAverage: Double(id % 10) + 0.5,
            voteCount: id * 10,
            backdropPath: "/backdrop-\(id).jpg",
            posterPath: "/poster-\(id).jpg"
        )
    }

    static func moviePage(
        ids: [Int],
        page: Int = 1,
        totalPages: Int = 1
    ) -> MoviePage {
        MoviePage(
            movies: movies(ids),
            page: page,
            totalPages: totalPages
        )
    }

    static func watchlistItem(id: Int) -> WatchlistItem {
        WatchlistItem(movie: movie(id: id), addedAt: Date(timeIntervalSince1970: TimeInterval(id)))
    }
}
