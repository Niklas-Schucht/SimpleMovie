@testable import SimpleMovie

final class MockWatchlistRepository: WatchlistRepo {
    var items: [WatchlistItem]
    var loadError: Error?
    var containsError: Error?
    var addError: Error?
    var removeError: Error?

    private(set) var addedMovies: [Movie] = []
    private(set) var removedMovieIds: [Int] = []
    private(set) var containsMovieIds: [Int] = []

    init(items: [WatchlistItem] = []) {
        self.items = items
    }

    func loadWatchlist() async throws -> [WatchlistItem] {
        if let loadError {
            throw loadError
        }

        return items
    }

    func contains(movieId: Int) async throws -> Bool {
        containsMovieIds.append(movieId)

        if let containsError {
            throw containsError
        }

        return items.contains { $0.id == movieId }
    }

    func add(_ movie: Movie) async throws {
        if let addError {
            throw addError
        }

        addedMovies.append(movie)

        if let index = items.firstIndex(where: { $0.id == movie.id }) {
            items[index] = WatchlistItem(movie: movie)
        } else {
            items.append(WatchlistItem(movie: movie))
        }
    }

    func remove(movieId: Int) async throws {
        if let removeError {
            throw removeError
        }

        removedMovieIds.append(movieId)
        items.removeAll { $0.id == movieId }
    }
}
