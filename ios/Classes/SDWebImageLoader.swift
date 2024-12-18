import UIKit
import SDWebImage

class SDWebImageLoader: NSObject, ILoaderProxy {
    
    typealias T = SDWebImageCombinedOperation?
    
    func loadImage(from request: LoadRequest, callback: ILoadCallback) -> SDWebImageCombinedOperation? {
        guard let uri = request.uri else {
            callback.onFailure(error: "Missing image URI")
            return nil
        }
        
        // 使用 SDWebImage 加载图片
        return SDWebImageManager.shared.loadImage(with: URL(string: uri), options: [], progress: nil) { (image, data, error, cacheType, finished, url) in
            if let error = error {
                callback.onFailure(error: error.localizedDescription)
            } else {
                guard let image = image else {
                    callback.onFailure(error: "Failed to load image")
                    return
                }
                if let cgImage = image.cgImage {
                    let pixelBuffer = self.imageToPixelBuffer(image: cgImage)
                    callback.notifyTextureUpdate(pixelBuffer: pixelBuffer!)
                    let imageInfo = NImageInfo()
                    imageInfo.uri = uri
                    imageInfo.imageWidth = Int(image.size.width)
                    imageInfo.imageHeight = Int(image.size.height)
                    callback.onSuccess(imageInfo: imageInfo)
                } else {
                    callback.onFailure(error: "Failed to get pixelBuffer")
                }
            }
        }
    }
    
    func cancelLoad(task: SDWebImageCombinedOperation?) {
        task?.cancel()
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
