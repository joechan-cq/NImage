import Flutter

public class TextureManager {
    private let textureRegistry: FlutterTextureRegistry
    private var cache = [Int64: ImageTextureView]()

    public init(textureRegistry: FlutterTextureRegistry) {
        self.textureRegistry = textureRegistry
    }

    public func createTexture() -> Int64 {
        let imageTextureView = ImageTextureView(textureRegistry)
        let textureId = textureRegistry.register(imageTextureView)
        imageTextureView.textureId = textureId
        cache[textureId] = imageTextureView
        return textureId
    }

    public func destroyTexture(_ textureId: Int64) {
        if cache[textureId] != nil {
            cache.removeValue(forKey: textureId)
            self.textureRegistry.unregisterTexture(textureId)
        }
    }

    public func getImageTextureView(_ textureId: Int64) -> ImageTextureView? {
        return cache[textureId]
    }
}
