import Foundation
import Flutter

public class LoadRequest {
    var uri: String?
    var width: Int?
    var height: Int?
    var fit: FitMode?
    
    enum FitMode: String {
        case fill
        case none
        case contain
        case cover
        case fitWidth
        case fitHeight
        case scaleDown
    }
    
    init() {
    }

    static func fromCall(call: FlutterMethodCall) -> LoadRequest {
        let request = LoadRequest()
        if let dict = call.arguments as? Dictionary<String, Any> {
            request.uri = dict["uri"] as? String
            request.width = dict["width"] as? Int
            request.height = dict["height"] as? Int
            request.fit = FitMode(rawValue: dict["fit"] as? String ?? "fill")
        }
        return request
    }
}
