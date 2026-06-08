import SwiftUI

struct DiscoverScreen: View {
    @State private var viewModel: DiscoverViewModel
    private let onMovieSelected: (Int) -> Void

    init(viewModel: DiscoverViewModel, onMovieSelected: @escaping (Int) -> Void) {
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
        case let .loaded(rows):
            List {
                ForEach(rows) { row in
                    Button {
                        onMovieSelected(row.id)
                    } label: {
                        MovieListRowView(
                            movie: row.movie,
                            isInWatchlist: row.isInWatchlist
                        )
                    }
                    .buttonStyle(.plain)
                    .task(id: row.id) {
                        await viewModel.loadNextPageIfNeeded(currentRow: row)
                    }
                }

                if viewModel.isLoadingNextPage {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
        case let .failed(error):
            AppErrorView(error: error) {
                Task {
                    await viewModel.retry()
                }
            }
        }
    }
}
