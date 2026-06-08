import Foundation

/// TMDB-backed movie repository that maps network DTOs into domain models.
struct TMDBMovieList: MovieListRepo {
    private let client: TMDBClient

    init(client: TMDBClient) {
        self.client = client
    }

    /// Loads a page of popular movies from TMDB.
    /// - Parameter page: The 1-based TMDB page number.
    func loadMovies(page: Int = 1) async throws -> MoviePage {
        let response: TMDBPagedResponse<TMDBMovieDTO> = try await client.send(
            .movieList(page: page)
        )

        return MoviePage(
            movies: response.results.map(TMDBMapper.mapMovie),
            page: response.page,
            totalPages: response.totalPages
        )
    }

    /// Loads full movie details from TMDB.
    /// - Parameter id: The TMDB movie identifier.
    func loadMovieDetails(id: Int) async throws -> MovieDetails {
        let dto: TMDBMovieDetailsDTO = try await client.send(
            .movieDetails(id: id)
        )

        return TMDBMapper.mapMovieDetails(dto)
    }
}
