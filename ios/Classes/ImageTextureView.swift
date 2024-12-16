import Flutter
import Foundation
import UIKit
import SDWebImage

public class ImageTextureView: NSObject, FlutterTexture {

    private var loadResult: FlutterResult?
    private var loadRequest: LoadRequest?
    
    public override init() {
        super.init()
    }
    
    public func onTextureUnregistered(_ texture: FlutterTexture) {
        // 实现 onTextureUnregistered 方法
    }
    
    public func loadImage(_ request: LoadRequest, result: @escaping FlutterResult) {
        loadRequest = request
        loadResult = result
        
        guard let uri = request.uri else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing image URI", details: nil))
            return
        }
        
        // 使用 SDWebImage 加载图片
        SDWebImageManager.shared.loadImage(with: URL(string: uri), options: [], progress: nil) { (image, data, error, cacheType, finished, url) in
            if let error = error {
                result(FlutterError(code: "IMAGE_LOAD_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            
            guard let image = image else {
                result(FlutterError(code: "IMAGE_LOAD_ERROR", message: "Failed to load image", details: nil))
                return
            }
            
            // 将图片转换为 CVPixelBuffer
            if let pixelBuffer = image.cvPixelBuffer {
                result(pixelBuffer)
            } else {
                // 如果不是 CVPixelBuffer，则尝试转换
                if let convertedBuffer = image.converted(to: kCVPixelFormatType_32BGRA) {
                    result(convertedBuffer)
                } else {
                    result(FlutterError(code: "IMAGE_CONVERSION_ERROR", message: "Failed to convert image to CVPixelBuffer", details: nil))
                }
            }
        }
    }
    
    // 新增方法：设置可见性
    public func setVisible(_ visible: Bool) {
        // 在这里实现设置可见性的逻辑
    }
    
    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        
        return nil
    }
}
