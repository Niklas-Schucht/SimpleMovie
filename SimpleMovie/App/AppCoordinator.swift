import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let environment: AppEnvironment

    private let tabBarController = UITabBarController()
    private var childCoordinators: [Coordinator] = []

    init(window: UIWindow, environment: AppEnvironment) {
        self.window = window
        self.environment = environment
    }

    func start() {
        let discoverNavigationController = UINavigationController()
        let watchlistNavigationController = UINavigationController()

        let screenFactory = ScreenFactory(environment: environment)

        let discoverCoordinator = DiscoverCoordinator(
            navigationController: discoverNavigationController,
            screenFactory: screenFactory
        )

        let watchlistCoordinator = WatchlistCoordinator(
            navigationController: watchlistNavigationController,
            screenFactory: screenFactory
        )

        childCoordinators = [discoverCoordinator, watchlistCoordinator]

        discoverCoordinator.start()
        watchlistCoordinator.start()

        discoverNavigationController.tabBarItem = UITabBarItem(
            title: "Movies",
            image: UIImage(systemName: "film"),
            selectedImage: UIImage(systemName: "film.fill")
        )

        watchlistNavigationController.tabBarItem = UITabBarItem(
            title: "Watchlist",
            image: UIImage(systemName: "bookmark"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )

        tabBarController.viewControllers = [
            discoverNavigationController,
            watchlistNavigationController
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
