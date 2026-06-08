import Foundation
import Observation

@MainActor
@Observable
final class MovieDetailsViewModel {
    private(set) var viewState: ViewState = .idle
    private(set) var alertError: AppError?

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(MovieDetailsContent)
        case failed(AppError)
    }

    struct MovieDetailsContent: Equatable {
        let details: MovieDetails
        let isInWatchlist: Bool
    }

    private let movieId: Int
    private let movieList: any MovieListRepo
    private let watchlistRepository: any WatchlistRepo

    init(movieId: Int,
         movieList: any MovieListRepo,
         watchlistRepository: any WatchlistRepo
    ) {
        self.movieId = movieId
        self.movieList = movieList
        self.watchlistRepository = watchlistRepository
    }

    /// Loads details once and refreshes the watchlist state when returning to this screen.
    func onAppear() async {
        switch viewState {
        case .idle:
            await loadMovieDetails()
        case let .loaded(content):
            await refreshWatchlistState(for: content)
        case .loading, .failed:
            break
        }
    }

    private func loadMovieDetails() async {
        viewState = .loading

        let movieDetails: MovieDetails

        do {
            movieDetails = try await movieList.loadMovieDetails(id: movieId)
        } catch {
            let appError = AppError.movieDetailsLoad(error)
            viewState = .failed(appError)
            return
        }

        let isInWatchlist: Bool
        do {
            isInWatchlist = try await watchlistRepository.contains(movieId: movieId)
        } catch {
            alertError = AppError.watchlistLoad(error)
            isInWatchlist = false
        }

        viewState = .loaded(
            MovieDetailsContent(
                details: movieDetails,
                isInWatchlist: isInWatchlist
            )
        )
    }

    private func refreshWatchlistState(for content: MovieDetailsContent) async {
        do {
            let isInWatchlist = try await watchlistRepository.contains(movieId: content.details.id)
            guard isInWatchlist != content.isInWatchlist else { return }

            viewState = .loaded(
                MovieDetailsContent(
                    details: content.details,
                    isInWatchlist: isInWatchlist
                )
            )
        } catch {
            alertError = AppError.watchlistLoad(error)
        }
    }


    /// Adds or removes the loaded movie from the watchlist.
    func toggleWatchlist() async {
        guard case let .loaded(content) = viewState else { return }

        do {
            if content.isInWatchlist {
                try await watchlistRepository.remove(movieId: content.details.id)
            } else {
                try await watchlistRepository.add(Movie(details: content.details))
            }

            viewState = .loaded(
                MovieDetailsContent(
                    details: content.details,
                    isInWatchlist: !content.isInWatchlist
                )
            )
        } catch {
            alertError = AppError.watchlistUpdate(error)
        }
    }

    func retry() async {
        await loadMovieDetails()
    }

    func clearAlertError() {
        alertError = nil
    }
}
