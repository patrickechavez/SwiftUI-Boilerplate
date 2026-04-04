import UIKit
import ImageIO

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false

    private let url: URL?
    private let targetSize: CGSize
    private let cache: ImageCache

    init(url: URL?, targetSize: CGSize, cache: ImageCache = .shared) {
        self.url = url
        self.targetSize = targetSize
        self.cache = cache
    }

    func load() async {
        guard let url else { return }

        let key = cacheKey(for: url)
        if let cached = cache.image(for: key) {
            image = cached
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard !Task.isCancelled else { return }
            let downsampled = Self.downsample(data: data, to: targetSize)
            image = downsampled
            if let downsampled {
                cache.store(downsampled, for: key)
            }
        } catch {
            // Silently fail — placeholder stays visible
        }
    }

    private func cacheKey(for url: URL) -> String {
        "\(url.absoluteString)_\(Int(targetSize.width))x\(Int(targetSize.height))"
    }

    private static func downsample(data: Data, to pointSize: CGSize) -> UIImage? {
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, options) else { return nil }

        let scale = UIScreen.main.scale
        let maxPixels = max(pointSize.width, pointSize.height) * scale

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixels
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
