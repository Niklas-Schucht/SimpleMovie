import Foundation

/// Provides movie data to the feature layer.
protocol MovieListRepo {
    /// Loads one page of movies.
    /// - Parameter page: page index requested
    func loadMovies(page: Int) async throws -> MoviePage

    /// Loads detailed information for a single movie.
    /// - Parameter id: The TMDB movie identifier.
    func loadMovieDetails(id: Int) async throws -> MovieDetails
}
