@testable import SimpleMovie

final class MockMovieListRepository: MovieListRepo {
    var pages: [Int: MoviePage] = [:]
    var details: [Int: MovieDetails] = [:]
    var loadMoviesError: Error?
    var loadMovieDetailsError: Error?

    private(set) var requestedPages: [Int] = []
    private(set) var requestedDetailIds: [Int] = []

    func loadMovies(page: Int) async throws -> MoviePage {
        requestedPages.append(page)

        if let loadMoviesError {
            throw loadMoviesError
        }

        guard let page = pages[page] else {
            throw TestError.failure
        }

        return page
    }

    func loadMovieDetails(id: Int) async throws -> MovieDetails {
        requestedDetailIds.append(id)

        if let loadMovieDetailsError {
            throw loadMovieDetailsError
        }

        guard let details = details[id] else {
            throw TestError.failure
        }

        return details
    }
}
