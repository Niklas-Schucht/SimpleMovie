import SwiftData
import XCTest
@testable import SimpleMovie

@MainActor
final class SwiftDataWatchlistRepositoryTests: XCTestCase {
    func testAddLoadContainsAndRemoveMovie() async throws {
        let sut = try makeSUT()
        let movie = TestDataFactory.movie(id: 1)

        let isInitiallySaved = try await sut.repository.contains(movieId: movie.id)
        XCTAssertFalse(isInitiallySaved)

        try await sut.repository.add(movie)

        let isSaved = try await sut.repository.contains(movieId: movie.id)
        let savedIds = try await sut.repository.loadWatchlist().map(\.id)
        XCTAssertTrue(isSaved)
        XCTAssertEqual(savedIds, [movie.id])

        try await sut.repository.remove(movieId: movie.id)

        let isSavedAfterRemoval = try await sut.repository.contains(movieId: movie.id)
        let isWatchlistEmpty = try await sut.repository.loadWatchlist().isEmpty
        XCTAssertFalse(isSavedAfterRemoval)
        XCTAssertTrue(isWatchlistEmpty)
    }

    func testAddExistingMovieUpdatesSnapshotWithoutDuplicatingItem() async throws {
        let sut = try makeSUT()
        let originalMovie = TestDataFactory.movie(id: 1, title: "Original")
        let updatedMovie = TestDataFactory.movie(id: 1, title: "Updated")

        try await sut.repository.add(originalMovie)
        try await sut.repository.add(updatedMovie)

        let items = try await sut.repository.loadWatchlist()
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.movie.title, "Updated")
    }

    func testLoadWatchlistSortsNewestItemsFirst() async throws {
        let sut = try makeSUT()

        try await sut.repository.add(TestDataFactory.movie(id: 1))
        try await sut.repository.add(TestDataFactory.movie(id: 2))

        let ids = try await sut.repository.loadWatchlist().map(\.id)
        XCTAssertEqual(ids, [2, 1])
    }

    private func makeSUT() throws -> SUT {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: WatchlistMovieEntity.self,
            configurations: configuration
        )
        let repository = SwiftDataWatchlistRepository(modelContext: container.mainContext)

        return SUT(repository: repository, container: container)
    }

    private struct SUT {
        let repository: SwiftDataWatchlistRepository
        let container: ModelContainer
    }
}
