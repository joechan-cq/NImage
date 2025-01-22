import Flutter
import UIKit
import nimage

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    ImageLoader.proxy = SDWebImageLoader()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
