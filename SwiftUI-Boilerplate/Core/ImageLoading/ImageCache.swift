import UIKit
import CryptoKit

final class ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCacheURL: URL

    init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        diskCacheURL = cacheDir.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50 MB
    }

    func image(for key: String) -> UIImage? {
        if let cached = memoryCache.object(forKey: key as NSString) {
            return cached
        }
        let fileURL = diskCacheURL.appendingPathComponent(filename(for: key))
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else { return nil }
        memoryCache.setObject(image, forKey: key as NSString, cost: data.count)
        return image
    }

    func store(_ image: UIImage, for key: String) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        memoryCache.setObject(image, forKey: key as NSString, cost: data.count)
        let fileURL = diskCacheURL.appendingPathComponent(filename(for: key))
        try? data.write(to: fileURL, options: .atomic)
    }

    private func filename(for key: String) -> String {
        let digest = SHA256.hash(data: Data(key.utf8))
        return digest.compactMap { String(format: "%02x", $0) }.joined() + ".jpg"
    }
}
