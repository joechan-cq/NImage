import Foundation

public class NImageInfo {
    public var uri: String?
    public var imageWidth: Int?
    public var imageHeight: Int?

    public init() {
    }

    public func toMap() -> [String: Any] {
        var map: Dictionary<String, Any> = [:]
        if let uri = uri {
            map["uri"] = uri
        }
        map["imageWidth"] = imageWidth
        map["imageHeight"] = imageHeight
        return map
    }
}
