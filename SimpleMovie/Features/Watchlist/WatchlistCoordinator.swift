import UIKit

final class WatchlistCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let screenFactory: ScreenFactory

    init(navigationController: UINavigationController, screenFactory: ScreenFactory) {
        self.navigationController = navigationController
        self.screenFactory = screenFactory
    }

    func start() {
        let controller = screenFactory.makeWatchlistScreen { [weak self] movieId in
            self?.showMovieDetails(movieId: movieId)
        }

        navigationController.setViewControllers([controller], animated: true)
    }

    private func showMovieDetails(movieId: Int) {
        let controller = screenFactory.makeMovieDetailScreen(movieId: movieId)
        navigationController.pushViewController(controller, animated: true)
    }
}
