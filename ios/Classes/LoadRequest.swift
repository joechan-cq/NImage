import Foundation
import Flutter

public class LoadRequest {
    public var uri: String?
    public var width: Int?
    public var height: Int?
    public var fit: FitMode?
    
    public enum FitMode: String {
        case fill
        case none
        case contain
        case cover
        case fitWidth
        case fitHeight
        case scaleDown
    }
    
    public init() {
    }

    public static func fromCall(call: FlutterMethodCall) -> LoadRequest {
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
