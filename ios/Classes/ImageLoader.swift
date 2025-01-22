import UIKit

public protocol ILoadCallback {
    func onSuccess(imageInfo: NImageInfo)
    func onFailure(error: String)
    func notifyUIImage(image: UIImage)
}

public protocol ILoaderProxy {
    associatedtype T
    func loadImage(from request: LoadRequest, callback: ILoadCallback) -> T
    func cancelLoad(task: Any)
}

public class ImageLoader: NSObject {
    private static var _proxy: (any ILoaderProxy)?
    
    public static var proxy: (any ILoaderProxy)? {
        get {
            return _proxy
        }
        set {
            _proxy = newValue
        }
    }
}
