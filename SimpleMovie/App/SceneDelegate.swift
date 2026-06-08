import SwiftData
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var modelContainer: ModelContainer?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        let client = TMDBClient(accessToken: TMDBConfig.accessToken)
        let modelContainer: ModelContainer

        do {
            modelContainer = try ModelContainer(for: WatchlistMovieEntity.self)
        } catch {
            assertionFailure("Could not create SwiftData model container: \(error)")
            return
        }

        self.modelContainer = modelContainer

        let environment = AppEnvironment(
            movieList: TMDBMovieList(client: client),
            watchlistRepository: SwiftDataWatchlistRepository(
                modelContext: modelContainer.mainContext
            )
        )

        let coordinator = AppCoordinator(
            window: window,
            environment: environment
        )

        self.window = window
        self.appCoordinator = coordinator

        coordinator.start()
    }
}
