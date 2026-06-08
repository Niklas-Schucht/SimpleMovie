import XCTest
@testable import SimpleMovie

@MainActor
final class MovieDetailsViewModelTests: XCTestCase {
    func testOnAppearLoadsDetailsAndWatchlistState() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.details[1] = TestDataFactory.movieDetails(id: 1)
        let watchlist = MockWatchlistRepository(items: [
            TestDataFactory.watchlistItem(id: 1)
        ])
        let sut = makeSUT(movieId: 1, movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()

        // Then
        let content = loadedContent(from: sut)
        XCTAssertEqual(content.details.id, 1)
        XCTAssertTrue(content.isInWatchlist)
        XCTAssertEqual(movieList.requestedDetailIds, [1])
        XCTAssertEqual(watchlist.containsMovieIds, [1])
    }

    func testOnAppearShowsDetailsAndAlertWhenWatchlistStateFails() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.details[1] = TestDataFactory.movieDetails(id: 1)
        let watchlist = MockWatchlistRepository()
        watchlist.containsError = TestError.failure
        let sut = makeSUT(movieId: 1, movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()

        // Then
        let content = loadedContent(from: sut)
        XCTAssertEqual(content.details.id, 1)
        XCTAssertFalse(content.isInWatchlist)
        XCTAssertEqual(sut.alertError, AppError.watchlistLoad(TestError.failure))
    }

    func testOnAppearShowsFailedStateWhenDetailsLoadingFails() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.loadMovieDetailsError = TestError.failure
        let sut = makeSUT(movieId: 1, movieList: movieList)

        // When
        await sut.onAppear()

        // Then
        XCTAssertEqual(sut.viewState, .failed(AppError.movieDetailsLoad(TestError.failure)))
        XCTAssertNil(sut.alertError)
    }

    func testToggleWatchlistAddsMovieWhenItIsNotSaved() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.details[1] = TestDataFactory.movieDetails(id: 1)
        let watchlist = MockWatchlistRepository()
        let sut = makeSUT(movieId: 1, movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()
        await sut.toggleWatchlist()

        // Then
        let content = loadedContent(from: sut)
        XCTAssertTrue(content.isInWatchlist)
        XCTAssertEqual(watchlist.addedMovies.map(\.id), [1])
        XCTAssertEqual(watchlist.items.map(\.id), [1])
    }

    func testToggleWatchlistRemovesMovieWhenItIsSaved() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.details[1] = TestDataFactory.movieDetails(id: 1)
        let watchlist = MockWatchlistRepository(items: [
            TestDataFactory.watchlistItem(id: 1)
        ])
        let sut = makeSUT(movieId: 1, movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()
        await sut.toggleWatchlist()

        // Then
        let content = loadedContent(from: sut)
        XCTAssertFalse(content.isInWatchlist)
        XCTAssertEqual(watchlist.removedMovieIds, [1])
        XCTAssertTrue(watchlist.items.isEmpty)
    }

    func testOnAppearRefreshesWatchlistStateForAlreadyLoadedDetails() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.details[1] = TestDataFactory.movieDetails(id: 1)
        let watchlist = MockWatchlistRepository(items: [
            TestDataFactory.watchlistItem(id: 1)
        ])
        let sut = makeSUT(movieId: 1, movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()
        XCTAssertTrue(loadedContent(from: sut).isInWatchlist)

        watchlist.items = []
        await sut.onAppear()

        // Then
        XCTAssertFalse(loadedContent(from: sut).isInWatchlist)
        XCTAssertEqual(movieList.requestedDetailIds, [1])
        XCTAssertEqual(watchlist.containsMovieIds, [1, 1])
    }

    func testToggleWatchlistFailureShowsErrorAndKeepsLoadedState() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.details[1] = TestDataFactory.movieDetails(id: 1)
        let watchlist = MockWatchlistRepository()
        watchlist.addError = TestError.failure
        let sut = makeSUT(movieId: 1, movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()
        await sut.toggleWatchlist()

        // Then
        XCTAssertEqual(sut.alertError, AppError.watchlistUpdate(TestError.failure))
        XCTAssertFalse(loadedContent(from: sut).isInWatchlist)
    }

    func testClearAlertErrorRemovesErrorMessage() async {
        // Given
        let movieList = MockMovieListRepository()
        movieList.details[1] = TestDataFactory.movieDetails(id: 1)
        let watchlist = MockWatchlistRepository()
        watchlist.addError = TestError.failure
        let sut = makeSUT(movieId: 1, movieList: movieList, watchlist: watchlist)

        // When
        await sut.onAppear()
        await sut.toggleWatchlist()
        sut.clearAlertError()

        // Then
        XCTAssertNil(sut.alertError)
    }

    private func makeSUT(
        movieId: Int,
        movieList: MockMovieListRepository = MockMovieListRepository(),
        watchlist: MockWatchlistRepository = MockWatchlistRepository()
    ) -> MovieDetailsViewModel {
        MovieDetailsViewModel(
            movieId: movieId,
            movieList: movieList,
            watchlistRepository: watchlist
        )
    }

    private func loadedContent(
        from sut: MovieDetailsViewModel,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> MovieDetailsViewModel.MovieDetailsContent {
        guard case let .loaded(content) = sut.viewState else {
            XCTFail("Expected loaded state", file: file, line: line)
            return MovieDetailsViewModel.MovieDetailsContent(
                details: TestDataFactory.movieDetails(),
                isInWatchlist: false
            )
        }

        return content
    }
}
