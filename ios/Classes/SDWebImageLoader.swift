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
                callback.notifyUIImage(image: image)
                let imageInfo = NImageInfo()
                imageInfo.uri = uri
                imageInfo.imageWidth = Int(image.size.width)
                imageInfo.imageHeight = Int(image.size.height)
                callback.onSuccess(imageInfo: imageInfo)
            }
        }
    }
    
    func cancelLoad(task: Any) {
        (task as! SDWebImageCombinedOperation).cancel()
    }
}
