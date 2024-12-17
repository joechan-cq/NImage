import Foundation

public class NImageInfo {
    var uri: String?
    var imageWidth: Int?
    var imageHeight: Int?

    init() {
    }

    func toMap() -> [String: Any] {
        var map: Dictionary<String, Any> = [:]
        if let uri = uri {
            map["uri"] = uri
        }
        map["imageWidth"] = imageWidth
        map["imageHeight"] = imageHeight
        return map
    }
}
