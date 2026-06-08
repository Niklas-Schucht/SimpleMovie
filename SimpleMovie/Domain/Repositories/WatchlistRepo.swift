import Foundation

/// Provides access to the user's watchlist.
protocol WatchlistRepo {
    /// Loads the saved watchlist items.
    func loadWatchlist() async throws -> [WatchlistItem]

    /// Checks whether a movie is already saved.
    /// - Parameter movieId: The TMDB movie identifier.
    func contains(movieId: Int) async throws -> Bool

    /// Adds or updates a movie in the watchlist.
    /// - Parameter movie: movie data needed by list rows.
    func add(_ movie: Movie) async throws

    /// Removes a movie from the watchlist.
    /// - Parameter movieId: The TMDB movie identifier.
    func remove(movieId: Int) async throws
}
