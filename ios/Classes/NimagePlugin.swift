import Flutter
import UIKit

public struct MethodName {
    static let createTexture = "mth_createTexture"
    static let loadImage = "mth_loadImage"
    static let destroyTexture = "mth_destroyTexture"
    static let setVisible = "mth_setVisible"
    static let setInvisible = "mth_setInvisible"
}

public class NimagePlugin: NSObject, FlutterPlugin {
    
    private let textureManager: TextureManager
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nimage", binaryMessenger: registrar.messenger())
        let instance = NimagePlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    init(registrar: FlutterPluginRegistrar) {
        textureManager = TextureManager(textureRegistry: registrar.textures())
        super.init()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        switch method {
        case MethodName.createTexture:
            createTexture(call, result: result)
        case MethodName.loadImage:
            loadImage(call, result: result)
        case MethodName.destroyTexture:
            destroyTexture(call, result: result)
        case MethodName.setVisible:
            setVisible(call, result: result)
        case MethodName.setInvisible:
            setInvisible(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func createTexture(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let textureId = textureManager.createTexture()
        result(textureId)
    }
    
    private func loadImage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let dict = call.arguments as? Dictionary<String, Any> {
            let textureId = dict["textureId"] as? Int64
            if let imageView = textureManager.getImageTextureView(textureId!) {
                let request = LoadRequest.fromCall(call: call)
                imageView.loadImage(request:request, result: result)
            } else {
                result(FlutterError(code: "NO_TEXTURE", message: "Texture not found", details: nil))
            }
        } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
    }
    
    private func destroyTexture(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          if let textureId = call.arguments as? Int64 {
              textureManager.destroyTexture(textureId)
              result(nil)
          } else {
              result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid textureId", details: nil))
          }
      }
      
      private func setVisible(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          if let textureId = call.arguments as? Int64 {
              if let imageView = textureManager.getImageTextureView(textureId) {
                  imageView.setVisible(true)
                  result(nil)
              } else {
                  result(FlutterError(code: "NO_TEXTURE", message: "Texture not found", details: nil))
              }
          } else {
              result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid textureId", details: nil))
          }
      }
      
      private func setInvisible(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
          if let textureId = call.arguments as? Int64 {
              if let imageView = textureManager.getImageTextureView(textureId) {
                  imageView.setVisible(false)
                  result(nil)
              } else {
                  result(FlutterError(code: "NO_TEXTURE", message: "Texture not found", details: nil))
              }
          } else {
              result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid textureId", details: nil))
          }
      }
}
