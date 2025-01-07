import UIKit

protocol ILoadCallback {
    func onSuccess(imageInfo: NImageInfo)
    func onFailure(error: String)
    func notifyUIImage(image: UIImage)
}

protocol ILoaderProxy {
    associatedtype T
    func loadImage(from request: LoadRequest, callback: ILoadCallback) -> T
    func cancelLoad(task: Any)
}

class ImageLoader: NSObject {
    private static var _proxy: (any ILoaderProxy)?
    
    static var proxy: (any ILoaderProxy)? {
        get {
            return _proxy
        }
        set {
            _proxy = newValue
        }
    }
}
