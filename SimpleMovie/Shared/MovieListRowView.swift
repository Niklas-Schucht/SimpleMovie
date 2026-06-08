import SwiftUI

struct MovieListRowView: View {
    let movie: Movie
    let isInWatchlist: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            PosterView(path: movie.posterPath, size: .w185)

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    if isInWatchlist {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(.primary)
                            .accessibilityLabel("In Watchlist")
                    }
                }

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(movie.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(.vertical, 6)
    }
}
