import SwiftUI

struct MovieDetailsLoadedView: View {
    let content: MovieDetailsViewModel.MovieDetailsContent
    let onWatchlistTapped: () -> Void

    private var details: MovieDetails { content.details }

    private var backdropURL: URL? {
        PosterURLBuilder().url(for: details.backdropPath, size: .w500)
    }

    private var runtimeString: String? {
        guard let minutes = details.runtime else { return nil }
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                AsyncImage(url: backdropURL) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.15))
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 220)
                .clipped()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(
                            colors: [
                                Color.black.opacity(0.0),
                                Color.black.opacity(0.3)
                            ]
                        ),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .topTrailing) {
                    if content.isInWatchlist {
                        Label("In Watchlist", systemImage: "bookmark.fill")
                            .font(.subheadline.weight(.semibold))
                            .padding(8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .padding(8)
                            .accessibilityLabel("In Watchlist")
                    }
                }

                HStack(alignment: .top, spacing: 12) {
                    PosterView(path: details.posterPath, size: .w185)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(details.title)
                            .font(.title2.bold())
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        if let tagline = details.tagline, !tagline.isEmpty {
                            Text(tagline)
                                .font(.subheadline.italic())
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        HStack(spacing: 12) {
                            Label(String(format: "%.1f", details.voteAverage), systemImage: "star.fill")
                                .font(.subheadline)
                                .foregroundStyle(.yellow)

                            Text("(\(details.voteCount))")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                        if let releaseDate = details.releaseDate {
                            Label(releaseDate, systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let runtime = runtimeString {
                            Label(runtime, systemImage: "clock")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Button(action: onWatchlistTapped) {
                            Label(
                                content.isInWatchlist ? "Remove from Watchlist" : "Add to Watchlist",
                                systemImage: content.isInWatchlist ? "bookmark.fill" : "bookmark"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        if !details.genres.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(details.genres) { genre in
                                        Text(genre.name)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(Color.secondary.opacity(0.15))
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                    Text(details.overview)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(Color(.systemBackground))
    }
}
