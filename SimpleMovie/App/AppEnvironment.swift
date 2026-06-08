import Foundation

struct AppEnvironment {
    let movieList: any MovieListRepo
    let watchlistRepository: any WatchlistRepo
}
