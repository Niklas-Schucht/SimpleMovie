import Foundation
import Observation

@MainActor
@Observable
final class DiscoverViewModel {
    private(set) var viewState: ViewState = .idle
    private(set) var alertError: AppError?
    private(set) var isLoadingNextPage = false
    private let paginationThreshold = 5

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([MovieRow])
        case failed(AppError)
    }

    struct MovieRow: Identifiable, Equatable {
        var id: Int { movie.id }
        let movie: Movie
        let isInWatchlist: Bool
    }

    private let movieList: any MovieListRepo
    private let watchlistRepository: any WatchlistRepo
    private var nextPage = 1
    private var rows: [MovieRow] = []
    private var canLoadMorePages = true

    private var isPageLoadInProgress: Bool {
        viewState == .loading || isLoadingNextPage
    }

    init(movieList: any MovieListRepo, watchlistRepository: any WatchlistRepo) {
        self.movieList = movieList
        self.watchlistRepository = watchlistRepository
    }

    /// Loads the first page once and refreshes watchlist markers when returning to the screen.
    func onAppear() async {
        switch viewState {
        case .idle:
            await loadPage(reset: true)
        case .loaded:
            await refreshWatchlistState()
        case .loading, .failed:
            break
        }
    }

    private func loadPage(reset: Bool) async {
        guard !isPageLoadInProgress else { return }
        guard reset || canLoadMorePages else { return }

        if reset {
            resetPaging()
            viewState = .loading
        }

        isLoadingNextPage = !reset

        defer {
            isLoadingNextPage = false
        }

        do {
            let moviePage = try await movieList.loadMovies(page: nextPage)
            let newRows = await makeRows(for: moviePage.movies)

            nextPage = moviePage.page + 1
            canLoadMorePages = moviePage.hasMorePages
            rows.append(contentsOf: newRows)
            viewState = .loaded(rows)
        } catch {
            let appError = AppError.movieListLoad(error)

            if reset || rows.isEmpty {
                viewState = .failed(appError)
            } else {
                alertError = appError
            }
        }
    }

    private func isNearEnd(_ row: MovieRow) -> Bool {
        rows.suffix(paginationThreshold).contains { $0.id == row.id }
    }

    private func resetPaging() {
        nextPage = 1
        rows = []
        canLoadMorePages = true
    }

    private func makeRows(for movies: [Movie]) async -> [MovieRow] {
        let watchlistMovieIds = await loadWatchlistMovieIds()

        return movies.map { movie in
            MovieRow(
                movie: movie,
                isInWatchlist: watchlistMovieIds.contains(movie.id)
            )
        }
    }

    /// Loads the next page when the currently displayed row is close to the end of the list.
    /// - Parameter currentRow: The row that just appeared in the SwiftUI list.
    func loadNextPageIfNeeded(currentRow: MovieRow) async {
        guard canLoadMorePages else { return }
        guard isNearEnd(currentRow) else { return }
        await loadPage(reset: false)
    }

    /// Refreshes the bookmark state without reloading movies from TMDB.
    func refreshWatchlistState() async {
        guard !rows.isEmpty else { return }

        let watchlistMovieIds = await loadWatchlistMovieIds()
        rows = rows.map { row in
            MovieRow(
                movie: row.movie,
                isInWatchlist: watchlistMovieIds.contains(row.id)
            )
        }
        viewState = .loaded(rows)
    }

    private func loadWatchlistMovieIds() async -> Set<Int> {
        do {
            let watchlist = try await watchlistRepository.loadWatchlist()
            return Set(watchlist.map(\.id))
        } catch {
            return []
        }
    }

    func retry() async {
        await loadPage(reset: true)
    }

    func clearAlertError() {
        alertError = nil
    }
}
