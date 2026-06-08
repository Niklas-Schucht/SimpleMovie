import SwiftUI

struct MovieDetailsScreen: View {
    @State private var viewModel: MovieDetailsViewModel

    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .onAppear {
                Task {
                    await viewModel.onAppear()
                }
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
        case let .loaded(content):
            MovieDetailsLoadedView(content: content) {
                Task {
                    await viewModel.toggleWatchlist()
                }
            }
        case let .failed(error):
            AppErrorView(error: error) {
                Task {
                    await viewModel.retry()
                }
            }
        }
    }
}
