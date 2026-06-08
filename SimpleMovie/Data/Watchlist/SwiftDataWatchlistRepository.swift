import Foundation
import SwiftData

/// SwiftData implementation of the watchlist repository.
@MainActor
final class SwiftDataWatchlistRepository: WatchlistRepo {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Loads all saved movies
    func loadWatchlist() async throws -> [WatchlistItem] {
        let descriptor = FetchDescriptor<WatchlistMovieEntity>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map(WatchlistMapper.map)
    }

    /// Checks if a movie is already stored.
    /// - Parameter movieId: The TMDB movie identifier.
    func contains(movieId: Int) async throws -> Bool {
        try findEntity(movieId: movieId) != nil
    }

    /// Inserts a new movie or refreshes an existing one.
    /// - Parameter movie: The  movie data stored for the watchlist row.
    func add(_ movie: Movie) async throws {
        if let existingEntity = try findEntity(movieId: movie.id) {
            WatchlistMapper.update(existingEntity, with: movie)
        } else {
            modelContext.insert(WatchlistMovieEntity(movie: movie))
        }

        try modelContext.save()
    }

    /// Removes a saved movie if it exists.
    /// - Parameter movieId: The TMDB movie identifier.
    func remove(movieId: Int) async throws {
        guard let entity = try findEntity(movieId: movieId) else { return }

        modelContext.delete(entity)
        try modelContext.save()
    }

    private func findEntity(movieId: Int) throws -> WatchlistMovieEntity? {
        var descriptor = FetchDescriptor<WatchlistMovieEntity>(
            predicate: #Predicate { entity in
                entity.id == movieId
            }
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }
}
