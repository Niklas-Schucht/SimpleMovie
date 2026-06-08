import XCTest
@testable import SimpleMovie

final class AppErrorTests: XCTestCase {
    func testRemoteErrorsMapToDisplayedInternalCodes() {
        let testCases: [(name: String, error: Error, code: Int, message: String, hiddenText: String?)] = [
            (
                "invalid url",
                TMDBClientError.invalidURL,
                101,
                "The app could not create a valid request. Please try again.",
                nil
            ),
            (
                "invalid response",
                TMDBClientError.invalidResponse,
                102,
                "The movie service returned an invalid response. Please try again later.",
                nil
            ),
            (
                "unauthorized",
                TMDBClientError.httpStatus(401),
                103,
                "The movie service could not be reached with the current app configuration.",
                "401"
            ),
            (
                "missing resource",
                TMDBClientError.httpStatus(404),
                104,
                "The requested movie information is no longer available.",
                "404"
            ),
            (
                "rate limited",
                TMDBClientError.httpStatus(429),
                105,
                "Too many requests were sent in a short time. Please try again later.",
                "429"
            ),
            (
                "server error",
                TMDBClientError.httpStatus(500),
                106,
                "The movie service is currently unavailable. Please try again later.",
                "500"
            ),
            (
                "decoding",
                TMDBClientError.decoding,
                107,
                "The movie service returned data the app could not read.",
                nil
            ),
            (
                "no connection",
                URLError(.notConnectedToInternet),
                108,
                "Please check your internet connection and try again.",
                nil
            ),
            (
                "timeout",
                URLError(.timedOut),
                109,
                "The request took too long. Please try again.",
                nil
            ),
            (
                "unknown",
                TestError.failure,
                199,
                "Something unexpected happened. Please try again.",
                nil
            )
        ]

        for testCase in testCases {
            let error = AppError.movieListLoad(testCase.error)

            XCTAssertEqual(error.title, "Movies could not be loaded", testCase.name)
            XCTAssertEqual(error.code, testCase.code, testCase.name)
            XCTAssertEqual(error.codeText, "Error code: \(testCase.code)", testCase.name)
            XCTAssertEqual(error.message, testCase.message, testCase.name)

            if let hiddenText = testCase.hiddenText {
                XCTAssertFalse(error.alertMessage.contains(hiddenText), testCase.name)
            }
        }
    }

    func testWatchlistErrorsUseLocalStorageCodes() {
        let loadError = AppError.watchlistLoad(TestError.failure)
        let updateError = AppError.watchlistUpdate(TestError.failure)

        XCTAssertEqual(loadError.code, 201)
        XCTAssertEqual(loadError.title, "Watchlist could not be loaded")
        XCTAssertEqual(updateError.code, 202)
        XCTAssertEqual(updateError.title, "Watchlist could not be updated")
    }
}
