import XCTest
@testable import SimpleMovie

@MainActor
final class DiscoverViewModelTests: XCTestCase {
    func testOnAppearLoadsFirstPageAndMarksWatchlistMovies() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.pages[1] = TestDataFactory.moviePage(
            ids: [1, 2],
            page: 1,
            totalPages: 2
        )
        let watchlist = MockWatchlistRepository(items: [
            TestDataFactory.watchlistItem(id: 2)
        ])
        let sut = makeSUT(movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()

        // Then
        let rows = loadedRows(from: sut)
        XCTAssertEqual(movieList.requestedPages, [1])
        XCTAssertEqual(rows.map(\.id), [1, 2])
        XCTAssertFalse(rows[0].isInWatchlist)
        XCTAssertTrue(rows[1].isInWatchlist)
    }

    func testLoadNextPageIfNeededDoesNotLoadWhenRowIsNotNearEnd() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.pages[1] = TestDataFactory.moviePage(
            ids: [1, 2, 3, 4, 5, 6],
            page: 1,
            totalPages: 2
        )
        movieList.pages[2] = TestDataFactory.moviePage(
            ids: [7],
            page: 2,
            totalPages: 2
        )
        let sut = makeSUT(movieList: movieList)

        // When
        await sut.onAppear()
        let rows = loadedRows(from: sut)
        await sut.loadNextPageIfNeeded(currentRow: rows[0])

        // Then
        XCTAssertEqual(movieList.requestedPages, [1])
        XCTAssertEqual(loadedRows(from: sut).map(\.id), [1, 2, 3, 4, 5, 6])
    }

    func testLoadNextPageIfNeededLoadsWhenRowIsNearEnd() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.pages[1] = TestDataFactory.moviePage(
            ids: [1, 2, 3, 4, 5, 6],
            page: 1,
            totalPages: 2
        )
        movieList.pages[2] = TestDataFactory.moviePage(
            ids: [7, 8],
            page: 2,
            totalPages: 2
        )
        let sut = makeSUT(movieList: movieList)

        // When
        await sut.onAppear()
        let rows = loadedRows(from: sut)
        await sut.loadNextPageIfNeeded(currentRow: rows[1])

        // Then
        XCTAssertEqual(movieList.requestedPages, [1, 2])
        XCTAssertEqual(loadedRows(from: sut).map(\.id), [1, 2, 3, 4, 5, 6, 7, 8])
    }

    func testLoadNextPageIfNeededDoesNotLoadPastLastPage() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.pages[1] = TestDataFactory.moviePage(
            ids: [1, 2],
            page: 1,
            totalPages: 1
        )
        let sut = makeSUT(movieList: movieList)

        // When
        await sut.onAppear()
        let rows = loadedRows(from: sut)
        await sut.loadNextPageIfNeeded(currentRow: rows[1])

        // Then
        XCTAssertEqual(movieList.requestedPages, [1])
    }

    func testOnAppearLoadsEmptyMovieListWithoutShowingEmptyState() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.pages[1] = TestDataFactory.moviePage(ids: [])
        let sut = makeSUT(movieList: movieList)

        // When
        await sut.onAppear()

        // Then
        XCTAssertEqual(loadedRows(from: sut), [])
    }

    func testOnAppearShowsFailedStateWhenFirstPageFails() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.loadMoviesError = TestError.failure
        let sut = makeSUT(movieList: movieList)

        // When
        await sut.onAppear()

        // Then
        let expectedError = AppError.movieListLoad(TestError.failure)
        XCTAssertEqual(sut.viewState, .failed(expectedError))
        XCTAssertNil(sut.alertError)
    }

    func testLoadNextPageFailureKeepsLoadedRowsAndShowsAlert() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.pages[1] = TestDataFactory.moviePage(
            ids: [1, 2, 3, 4, 5, 6],
            page: 1,
            totalPages: 2
        )
        let sut = makeSUT(movieList: movieList)

        // When
        await sut.onAppear()
        movieList.loadMoviesError = TestError.failure
        await sut.loadNextPageIfNeeded(currentRow: loadedRows(from: sut)[1])

        // Then
        XCTAssertEqual(loadedRows(from: sut).map(\.id), [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(sut.alertError, AppError.movieListLoad(TestError.failure))
    }

    func testRefreshWatchlistStateUpdatesAlreadyLoadedRows() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.pages[1] = TestDataFactory.moviePage(ids: [1, 2])
        let watchlist = MockWatchlistRepository()
        let sut = makeSUT(movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()
        XCTAssertFalse(loadedRows(from: sut)[0].isInWatchlist)

        watchlist.items = [TestDataFactory.watchlistItem(id: 1)]
        await sut.refreshWatchlistState()

        // Then
        let rows = loadedRows(from: sut)
        XCTAssertTrue(rows[0].isInWatchlist)
        XCTAssertFalse(rows[1].isInWatchlist)
    }

    private func makeSUT(
        movieList: MockMovieListRepository = MockMovieListRepository(),
        watchlist: MockWatchlistRepository = MockWatchlistRepository()
    ) -> DiscoverViewModel {
        DiscoverViewModel(
            movieList: movieList,
            watchlistRepository: watchlist
        )
    }

    private func loadedRows(
        from sut: DiscoverViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> [DiscoverViewModel.MovieRow] {
        guard case let .loaded(rows) = sut.viewState else {
            XCTFail("Expected loaded state", file: file, line: line)
            return []
        }

        return rows
    }
}
