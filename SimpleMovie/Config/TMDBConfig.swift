import Foundation

/// Reads the reviewer-provided TMDB token from an ignored plist file.
enum TMDBConfig {
    static var accessToken: String {
        guard
            let url = Bundle.main.url(forResource: "TMDBSecrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ) as? [String: String],
            let token = plist["TMDB_ACCESS_TOKEN"],
            !token.isEmpty,
            token != "PASTE_YOUR_TMDB_ACCESS_TOKEN_HERE"
        else {
            assertionFailure(
                "Missing TMDB access token. Copy TMDBSecrets.example.plist to TMDBSecrets.plist and add your TMDB read access token."
            )
            return ""
        }

        return token
    }
}
