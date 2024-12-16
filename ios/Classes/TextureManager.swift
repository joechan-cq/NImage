import Flutter

public class TextureManager {
    private let textureRegistry: FlutterTextureRegistry
    private var cache = [Int64: ImageTextureView]()

    public init(textureRegistry: FlutterTextureRegistry) {
        self.textureRegistry = textureRegistry
    }

    public func createTexture() -> Int64 {
        let imageTextureView = ImageTextureView()
        let textureId = textureRegistry.register(imageTextureView)
        cache[textureId] = imageTextureView
        return textureId
    }

    public func destroyTexture(_ textureId: Int64) {
        if let imageView = cache[textureId] {
            cache.removeValue(forKey: textureId)
            self.textureRegistry.unregisterTexture(textureId)
        }
    }

    public func getImageTextureView(_ textureId: Int64) -> ImageTextureView? {
        return cache[textureId]
    }
}
