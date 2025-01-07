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
    
    private var animatedImages: [UIImage]?
    private var index: Int = 0
    private var frameInterval: TimeInterval?
    private var animatedPlayTimer: Timer?
    
    public init(_ registry: FlutterTextureRegistry) {
        textureRegistry = registry
    }
    
    public func onTextureUnregistered(_ texture: FlutterTexture) {
        // 实现 onTextureUnregistered 方法
        self.pixelBuffer = nil
    }
    
    public func loadImage(request: LoadRequest, result: @escaping FlutterResult) {
        if (self.task != nil) {
            ImageLoader.proxy?.cancelLoad(task: self.task!)
            self.task = nil
        }
        self.loadRequest = request
        self.loadResult = result
        // 使用 SDWebImageLoader 加载图片
        self.task = ImageLoader.proxy?.loadImage(from: request, callback: self)
    }
    
    // 设置可见性
    public func setVisible(_ visible: Bool) {
        // 在这里实现设置可见性的逻辑
        if (visible) {
            //如果可见，判定是否是动图，如果是动图，则启动动图展示
            if (self.animatedImages != nil) {
                showNextFrame()
            } else {
                //如果不是动图，则直接显示图片
            }
        } else {
            if (self.animatedPlayTimer != nil) {
                //停止Timer
                self.animatedPlayTimer?.invalidate()
                self.animatedPlayTimer = nil
            }
        }
    }
    
    // 销毁
    public func destroy() {
        if (self.animatedPlayTimer != nil) {
            self.animatedPlayTimer?.invalidate()
            self.animatedPlayTimer = nil
        }
        self.pixelBuffer = nil
        self.animatedImages?.removeAll()
        self.index = 0
    }
    
    public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        if (self.pixelBuffer == nil) {
            return nil;
        } else {
            return Unmanaged<CVPixelBuffer>.passRetained(self.pixelBuffer!)
        }
    }
    
    private func notifyTextureUpdate(pixelBuffer: CVPixelBuffer) {
        self.pixelBuffer = pixelBuffer
        //判断是否是主线程，如果不是，则切换到主线程调用
        if (Thread.isMainThread) {
            guard let textureId = self.textureId else {
                return
            }
            self.textureRegistry.textureFrameAvailable(textureId)
        } else {
            DispatchQueue.main.async {
                guard let textureId = self.textureId else {
                    return
                }
                self.textureRegistry.textureFrameAvailable(textureId)
            }
        }
    }
    
    private func showNextFrame() {
        if (self.animatedPlayTimer == nil) {
            self.animatedPlayTimer = Timer.scheduledTimer(withTimeInterval: self.frameInterval!, repeats: true) { timer in
                self.index += 1
                if (self.index >= self.animatedImages!.count) {
                    self.index = 0
                }
                let frame = self.animatedImages![self.index]
                let fitImage = self.fitTransform(frame)
                if let cgImage = fitImage.cgImage {
                    let p = self.imageToPixelBuffer(image: cgImage)
                    self.notifyTextureUpdate(pixelBuffer: p!)
                }
            }
        }
    }
    
    private func fitTransform(_ image: UIImage) -> UIImage {
        let viewSize = CGSize(width: self.loadRequest!.width!, height:  self.loadRequest!.height!)
        let imageSize = image.size
        switch self.loadRequest?.fit {
        case .none?:
            // 填充模式：裁剪图像以填充整个视图
            // 创建一个新的图像上下文
            UIGraphicsBeginImageContextWithOptions(CGSize(width: viewSize.width, height: viewSize.height), false, image.scale)
            
            // 绘制图像到新的上下文
            image.draw(in: CGRect(x: (viewSize.width - imageSize.width) / 2, y: (viewSize.height - imageSize.height) / 2, width: imageSize.width, height: imageSize.height))
            
            // 从上下文获取新的图像
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // 结束图像上下文
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        case .contain:
            // 包含模式：缩放图像以完全显示在视图中
            // 计算缩放比例
            let scaleWidth = viewSize.width / imageSize.width
            let scaleHeight = viewSize.height / imageSize.height
            let scale = min(scaleWidth, scaleHeight)
            
            // 计算缩放后的图像尺寸
            let newWidth = imageSize.width * scale
            let newHeight = imageSize.height * scale
            
            // 创建一个新的图像上下文
            UIGraphicsBeginImageContextWithOptions(CGSize(width: viewSize.width, height: viewSize.height), false, image.scale)
            
            // 绘制图像到新的上下文
            image.draw(in: CGRect(x: (viewSize.width - newWidth) / 2, y: (viewSize.height - newHeight) / 2, width: newWidth, height: newHeight))
            
            // 从上下文获取新的图像
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // 结束图像上下文
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        case .cover:
            // 覆盖模式：缩放图像以覆盖整个视图，可能会裁剪部分图像
            // 计算缩放比例
            let scaleWidth = viewSize.width / imageSize.width
            let scaleHeight = viewSize.height / imageSize.height
            let scale = max(scaleWidth, scaleHeight)
            
            // 计算裁剪后的图像尺寸
            let newWidth = imageSize.width * scale
            let newHeight = imageSize.height * scale
            
            // 创建一个新的图像上下文
            UIGraphicsBeginImageContextWithOptions(CGSize(width: viewSize.width, height: viewSize.height), false, image.scale)
            
            // 绘制图像到新的上下文
            image.draw(in: CGRect(x: (viewSize.width - newWidth) / 2, y: (viewSize.height - newHeight) / 2, width: newWidth, height: newHeight))
            
            // 从上下文获取新的图像
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // 结束图像上下文
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        case .fitWidth:
            // 适应宽度模式：缩放图像以适应视图的宽度，高度可能会超出视图
            // 计算缩放比例
            let scaleWidth = viewSize.width / imageSize.width
            let scale = scaleWidth
            
            // 计算缩放后的图像尺寸
            let newWidth = imageSize.width * scale
            let newHeight = imageSize.height * scale
            
            // 创建一个新的图像上下文
            UIGraphicsBeginImageContextWithOptions(CGSize(width: viewSize.width, height: viewSize.height), false, image.scale)
            
            // 绘制图像到新的上下文
            image.draw(in: CGRect(x: (viewSize.width - newWidth) / 2, y: (viewSize.height - newHeight) / 2, width: newWidth, height: newHeight))
            
            // 从上下文获取新的图像
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // 结束图像上下文
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        case .fitHeight:
            // 适应高度模式：缩放图像以适应视图的高度，宽度可能会超出视图
            // 计算缩放比例
            let scaleHeight = viewSize.height / imageSize.height
            let scale = scaleHeight
            
            // 计算缩放后的图像尺寸
            let newWidth = imageSize.width * scale
            let newHeight = imageSize.height * scale
            
            // 创建一个新的图像上下文
            UIGraphicsBeginImageContextWithOptions(CGSize(width: viewSize.width, height: viewSize.height), false, image.scale)
            
            // 绘制图像到新的上下文
            image.draw(in: CGRect(x: (viewSize.width - newWidth) / 2, y: (viewSize.height - newHeight) / 2, width: newWidth, height: newHeight))
            
            // 从上下文获取新的图像
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            // 结束图像上下文
            UIGraphicsEndImageContext()
            
            return newImage ?? image
        case .scaleDown:
            // 缩小模式：如果图像大于视图，则缩小图像以适应视图
            // 计算缩放比例
            let scaleWidth = viewSize.width / imageSize.width
            let scaleHeight = viewSize.height / imageSize.height
            let scale = min(scaleWidth, scaleHeight)
            
            // 如果缩放比例小于1，则进行缩放
            if scale < 1 {
                // 计算缩放后的图像尺寸
                let newWidth = imageSize.width * scale
                let newHeight = imageSize.height * scale
                
                // 创建一个新的图像上下文
                UIGraphicsBeginImageContextWithOptions(CGSize(width: viewSize.width, height: viewSize.height), false, image.scale)
                
                // 绘制图像到新的上下文
                image.draw(in: CGRect(x: (viewSize.width - newWidth) / 2, y: (viewSize.height - newHeight) / 2, width: newWidth, height: newHeight))
                
                // 从上下文获取新的图像
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                
                // 结束图像上下文
                UIGraphicsEndImageContext()
                
                return newImage ?? image
            } else {
                // 如果图像小于或等于视图
                // 创建一个新的图像上下文
                UIGraphicsBeginImageContextWithOptions(CGSize(width: viewSize.width, height: viewSize.height), false, image.scale)
                
                // 绘制图像到新的上下文
                image.draw(in: CGRect(x: (viewSize.width - imageSize.width) / 2, y: (viewSize.height - imageSize.height) / 2, width: imageSize.width, height: imageSize.height))
                
                // 从上下文获取新的图像
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                
                // 结束图像上下文
                UIGraphicsEndImageContext()
                
                return newImage ?? image
            }
        default:
            // 如果 fit 模式是 .fill则直接返回原始图像
            return image
        }
    }
    
    func onSuccess(imageInfo: NImageInfo) {
        loadResult?(imageInfo.toMap())
    }
    
    func onFailure(error: String) {
        loadResult?(FlutterError(code: "onFailure", message:error, details: nil))
    }
    
    func notifyUIImage(image: UIImage) {
        if let images = image.images {
            // 如果是动图，则处理动画图像
            self.animatedImages = images
            self.index = 0
            self.frameInterval = image.duration / Double((images.count - 1))
            //在这里先解析出第一帧
            let frame = images[self.index]
            let fitImage = self.fitTransform(frame)
            if let cgImage = fitImage.cgImage {
                let pixelBuffer = self.imageToPixelBuffer(image: cgImage)
                notifyTextureUpdate(pixelBuffer: pixelBuffer!)
            }
        } else {
            // 处理静态图像
            let fitImage = self.fitTransform(image)
            if let cgImage = fitImage.cgImage {
                let pixelBuffer = self.imageToPixelBuffer(image: cgImage)
                notifyTextureUpdate(pixelBuffer: pixelBuffer!)
            }
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
