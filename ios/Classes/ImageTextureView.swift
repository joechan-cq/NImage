import Flutter
import Foundation
import UIKit
import SDWebImage

public class ImageTextureView: NSObject, FlutterTexture {
 
    private let textureRegistry: FlutterTextureRegistry
    private var loadResult: FlutterResult?
    private var loadRequest: LoadRequest?
    private var pixelBuffer: CVPixelBuffer?
    var textureId: Int64?
    
    public init(_ registry: FlutterTextureRegistry) {
        textureRegistry = registry
    }
    
    public func onTextureUnregistered(_ texture: FlutterTexture) {
        // 实现 onTextureUnregistered 方法
        self.pixelBuffer = nil
    }
    
    public func loadImage(request: LoadRequest, result: @escaping FlutterResult) {
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
            if let cgImage = image.cgImage {
                let pixelBuffer = self.imageToPixelBuffer(image: cgImage)
                self.pixelBuffer = pixelBuffer
                self.textureRegistry.textureFrameAvailable(self.textureId!)
                let imageInfo = NImageInfo()
                imageInfo.uri = uri
                imageInfo.imageWidth = Int(image.size.width)
                imageInfo.imageHeight = Int(image.size.height)
                result(imageInfo.toMap())
            } else {
                result(FlutterError(code: "IMAGE_ERROR", message: "Failed to get pixelBuffer", details: nil))
                return
            }
           
        }
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
    
    func imageToPixelBuffer(image: CGImage) -> CVPixelBuffer? {
        let imageWidth = image.width
        let imageHeight = image.height

        var pixelBuffer: CVPixelBuffer?
        let options: [String: Any] = [
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
            kCVPixelBufferCGImageCompatibilityKey as String: false,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: false
        ]

        let status = CVPixelBufferCreate(kCFAllocatorDefault, imageWidth, imageHeight, kCVPixelFormatType_32BGRA, options as CFDictionary, &pixelBuffer)

        if status != kCVReturnSuccess {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorSpace, bitmapInfo: kCGBitmapByteOrder32Host.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)

        context?.draw(image, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))

        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }
}
