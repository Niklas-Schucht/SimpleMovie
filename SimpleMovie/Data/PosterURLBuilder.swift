import Foundation

struct PosterURLBuilder {
    enum Size: String {
        case w185
        case w342
        case w500
        case original
    }

    func url(for path: String?, size: Size = .w342) -> URL? {
        guard let path, !path.isEmpty else { return nil }

        let cleanedPath = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)/\(cleanedPath)")
    }
}
