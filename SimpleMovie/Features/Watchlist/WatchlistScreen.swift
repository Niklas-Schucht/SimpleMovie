import SwiftUI

struct WatchlistScreen: View {
    @State private var viewModel: WatchlistViewModel
    private let onMovieSelected: (Int) -> Void

    init(viewModel: WatchlistViewModel, onMovieSelected: @escaping (Int) -> Void) {
        self.viewModel = viewModel
        self.onMovieSelected = onMovieSelected
    }

    var body: some View {
        content
            .task {
                await viewModel.onAppear()
            }
            .appErrorAlert(error: viewModel.alertError) {
                viewModel.clearAlertError()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        case let .loaded(items):
            List {
                ForEach(items) { item in
                    Button {
                        onMovieSelected(item.id)
                    } label: {
                        MovieListRowView(
                            movie: item.movie,
                            isInWatchlist: true
                        )
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.remove(movieId: item.id)
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        case .empty:
            ContentUnavailableView(
                "No movies saved",
                systemImage: "bookmark",
                description: Text("Movies you add to your watchlist will appear here.")
            )
        case let .failed(error):
            AppErrorView(error: error) {
                Task {
                    await viewModel.retry()
                }
            }
        }
    }
}
