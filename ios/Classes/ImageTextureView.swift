import Flutter
import Foundation
import UIKit
import SDWebImage

public class ImageTextureView: NSObject, FlutterTexture, ILoadCallback {
    private let textureRegistry: FlutterTextureRegistry
    private var loadResult: FlutterResult?
    private var loadRequest: LoadRequest?
    private var pixelBuffer: CVPixelBuffer?
    private var task: Any?
    var textureId: Int64?
    
    public init(_ registry: FlutterTextureRegistry) {
        textureRegistry = registry
    }
    
    public func onTextureUnregistered(_ texture: FlutterTexture) {
        // 实现 onTextureUnregistered 方法
        self.pixelBuffer = nil
    }
    
    public func loadImage(request: LoadRequest, result: @escaping FlutterResult) {
        self.loadRequest = request
        loadResult = result
        // 使用 SDWebImageLoader 加载图片
        task = ImageLoader.proxy?.loadImage(from: request, callback: self)
    }
    
    // 新增方法：设置可见性
    public func setVisible(_ visible: Bool) {
        // 在这里实现设置可见性的逻辑
    }

    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if (self.pixelBuffer == nil) {
            return nil;
        } else {
            return Unmanaged<CVPixelBuffer>.passRetained(self.pixelBuffer!)
        }
    }
    
    func onSuccess(imageInfo: NImageInfo) {
        loadResult?(imageInfo.toMap())
    }
    
    func onFailure(error: String) {
        loadResult?(FlutterError(code: "onFailure", message:error, details: nil))
    }
    
    func notifyTextureUpdate(pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
        self.textureRegistry.textureFrameAvailable(self.textureId!)
    }
    
}
