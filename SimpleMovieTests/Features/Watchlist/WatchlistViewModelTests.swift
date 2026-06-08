import XCTest
@testable import SimpleMovie

@MainActor
final class WatchlistViewModelTests: XCTestCase {
    func testOnAppearShowsEmptyStateWhenWatchlistIsEmpty() async {
        // Given
        let watchlist = MockWatchlistRepository()
        let sut = WatchlistViewModel(watchlistRepository: watchlist)

        // When
        await sut.onAppear()

        // Then
        XCTAssertEqual(sut.viewState, .empty)
    }

    func testOnAppearLoadsWatchlistItems() async {
        // Given
        let watchlist = MockWatchlistRepository(items: [
            TestDataFactory.watchlistItem(id: 1),
            TestDataFactory.watchlistItem(id: 2)
        ])
        let sut = WatchlistViewModel(watchlistRepository: watchlist)

        // When
        await sut.onAppear()

        // Then
        let items = loadedItems(from: sut)
        XCTAssertEqual(items.map(\.id), [1, 2])
    }

    func testOnAppearShowsFailedStateWhenLoadingFails() async {
        // Given
        let watchlist = MockWatchlistRepository()
        watchlist.loadError = TestError.failure
        let sut = WatchlistViewModel(watchlistRepository: watchlist)

        // When
        await sut.onAppear()

        // Then
        XCTAssertEqual(sut.viewState, .failed(AppError.watchlistLoad(TestError.failure)))
        XCTAssertNil(sut.alertError)
    }

    func testRemoveDeletesMovieAndReloadsWatchlist() async {
        // Given
        let watchlist = MockWatchlistRepository(items: [
            TestDataFactory.watchlistItem(id: 1),
            TestDataFactory.watchlistItem(id: 2)
        ])
        let sut = WatchlistViewModel(watchlistRepository: watchlist)

        // When
        await sut.onAppear()
        await sut.remove(movieId: 1)

        // Then
        XCTAssertEqual(watchlist.removedMovieIds, [1])
        XCTAssertEqual(loadedItems(from: sut).map(\.id), [2])
    }

    func testRemoveShowsAlertAndKeepsLoadedItemsWhenRepositoryFails() async {
        // Given
        let watchlist = MockWatchlistRepository(items: [
            TestDataFactory.watchlistItem(id: 1)
        ])
        watchlist.removeError = TestError.failure
        let sut = WatchlistViewModel(watchlistRepository: watchlist)

        // When
        await sut.onAppear()
        await sut.remove(movieId: 1)

        // Then
        XCTAssertEqual(loadedItems(from: sut).map(\.id), [1])
        XCTAssertEqual(sut.alertError, AppError.watchlistUpdate(TestError.failure))
    }

    private func loadedItems(
        from sut: WatchlistViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [WatchlistItem] {
        guard case let .loaded(items) = sut.viewState else {
            XCTFail("Expected loaded state", file: file, line: line)
            return []
        }

        return items
    }
}
