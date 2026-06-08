import XCTest
@testable import SimpleMovie

final class TMDBEndpointTests: XCTestCase {
    func testMovieListURLContainsExpectedPathAndQueryItems() throws {
        let url = try XCTUnwrap(TMDBEndpoint.movieList(page: 3).url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = dictionary(from: components.queryItems)

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "api.themoviedb.org")
        XCTAssertEqual(components.path, "/3/movie/popular")
        XCTAssertEqual(queryItems["page"], "3")
        XCTAssertEqual(queryItems["language"], "en-US")
    }

    func testMovieDetailsURLContainsExpectedPathAndQueryItems() throws {
        let url = try XCTUnwrap(TMDBEndpoint.movieDetails(id: 42).url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = dictionary(from: components.queryItems)

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "api.themoviedb.org")
        XCTAssertEqual(components.path, "/3/movie/42")
        XCTAssertEqual(queryItems["language"], "en-US")
    }

    private func dictionary(from queryItems: [URLQueryItem]?) -> [String: String] {
        Dictionary(uniqueKeysWithValues: (queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })
    }
}
