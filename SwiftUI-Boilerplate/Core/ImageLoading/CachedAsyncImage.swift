import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let content: (UIImage) -> Content
    private let placeholder: () -> Placeholder

    init(
        url: URL?,
        targetSize: CGSize,
        @ViewBuilder content: @escaping (UIImage) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url, targetSize: targetSize))
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loader.image {
                content(image)
            } else if loader.isLoading {
                placeholder()
            } else {
                placeholder()
            }
        }
        .task {
            await loader.load()
        }
    }
}
