import SwiftUI

struct PosterView: View {
    let path: String?
    var size: PosterURLBuilder.Size = .w342

    private var posterURL: URL? {
        PosterURLBuilder().url(for: path, size: size)
    }

    var body: some View {
        AsyncImage(url: posterURL) { phase in
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
        .frame(width: 80, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
