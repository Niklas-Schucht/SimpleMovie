import XCTest
@testable import SimpleMovie

final class TMDBMapperTests: XCTestCase {
    func testMapMovieMapsRelevantFields() {
        let dto = TMDBMovieDTO(
            backdropPath: "/backdrop.jpg",
            id: 1,
            title: "Title",
            overview: "Overview",
            posterPath: "/poster.jpg",
            releaseDate: "2026-01-01",
            voteAverage: 8.2,
            voteCount: 100,
            popularity: 12.4
        )

        let movie = TMDBMapper.mapMovie(dto)

        XCTAssertEqual(movie.id, 1)
        XCTAssertEqual(movie.title, "Title")
        XCTAssertEqual(movie.overview, "Overview")
        XCTAssertEqual(movie.posterPath, "/poster.jpg")
        XCTAssertEqual(movie.voteAverage, 8.2)
    }

    func testMapMovieDetailsMapsGenresAndDetailsFields() {
        let dto = TMDBMovieDetailsDTO(
            backdropPath: "/backdrop.jpg",
            genres: [
                TMDBGenreDTO(id: 1, name: "Drama")
            ],
            id: 1,
            title: "Title",
            overview: "Overview",
            tagline: "Tagline",
            posterPath: "/poster.jpg",
            releaseDate: "2026-01-01",
            runtime: 120,
            voteAverage: 8.2,
            voteCount: 100,
            popularity: 12.4
        )

        let details = TMDBMapper.mapMovieDetails(dto)

        XCTAssertEqual(details.id, 1)
        XCTAssertEqual(details.title, "Title")
        XCTAssertEqual(details.genres, [Genre(id: 1, name: "Drama")])
        XCTAssertEqual(details.runtime, 120)
        XCTAssertEqual(details.tagline, "Tagline")
    }
}
