import UIKit
import SwiftUI

final class ScreenFactory {
    private let environment: AppEnvironment

    init(environment: AppEnvironment) {
        self.environment = environment
    }

    func makeMovieListScreen(
        onMovieSelected: @escaping (Int) -> Void
    ) -> UIViewController {
        let viewModel = DiscoverViewModel(
            movieList: environment.movieList,
            watchlistRepository: environment.watchlistRepository
        )

        let screen = DiscoverScreen(
            viewModel: viewModel,
            onMovieSelected: onMovieSelected
        )

        let controller = UIHostingController(rootView: screen)
        controller.title = "Movies"
        return controller
    }

    func makeWatchlistScreen(
        onMovieSelected: @escaping (Int) -> Void
    ) -> UIViewController {
        let viewModel = WatchlistViewModel(
            watchlistRepository: environment.watchlistRepository
        )

        let screen = WatchlistScreen(
            viewModel: viewModel,
            onMovieSelected: onMovieSelected
        )

        let controller = UIHostingController(rootView: screen)
        controller.title = "Watchlist"
        return controller
    }

    func makeMovieDetailScreen(movieId: Int) -> UIViewController {
        let viewModel = MovieDetailsViewModel(
            movieId: movieId,
            movieList: environment.movieList,
            watchlistRepository: environment.watchlistRepository
        )

        let screen = MovieDetailsScreen(viewModel: viewModel)

        let controller = UIHostingController(rootView: screen)
        controller.title = "Movie"
        return controller
    }
}
