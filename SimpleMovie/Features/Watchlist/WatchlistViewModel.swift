import Foundation
import Observation

@MainActor
@Observable
final class WatchlistViewModel {
    private(set) var viewState: ViewState = .idle
    private(set) var alertError: AppError?

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded([WatchlistItem])
        case empty
        case failed(AppError)
    }

    private let watchlistRepository: any WatchlistRepo

    init(watchlistRepository: any WatchlistRepo) {
        self.watchlistRepository = watchlistRepository
    }

    /// Reloads the watchlist every time the screen appears so changes from Details are reflected.
    func onAppear() async {
        await loadWatchlist()
    }

    private func loadWatchlist(showsLoading: Bool = true) async {
        if showsLoading {
            viewState = .loading
        }

        do {
            let items = try await watchlistRepository.loadWatchlist()
            viewState = items.isEmpty ? .empty : .loaded(items)
        } catch {
            let appError = AppError.watchlistLoad(error)
            viewState = .failed(appError)
        }
    }

    /// Removes a movie and reloads the list so the UI stays in sync.
    /// - Parameter movieId: The TMDB movie identifier.
    func remove(movieId: Int) async {
        do {
            try await watchlistRepository.remove(movieId: movieId)
            await loadWatchlist(showsLoading: false)
        } catch {
            alertError = AppError.watchlistUpdate(error)
        }
    }

    func retry() async {
        await loadWatchlist()
    }

    func clearAlertError() {
        alertError = nil
    }
}
