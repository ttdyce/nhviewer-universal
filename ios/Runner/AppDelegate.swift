import UIKit
import Flutter
import WebKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "samples.flutter.dev/cookies",
                                              binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // This method is invoked on the UI thread.
      guard call.method == "receiveCookies" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.receiveCookies(result: result)
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func receiveCookies(result: FlutterResult) {
    self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
        for cookie in cookies {
          result(cookie)
        }
    }
    
    // let device = UIDevice.current
    // device.isBatteryMonitoringEnabled = true
    // if device.batteryState == UIDevice.BatteryState.unknown {
    //   result(FlutterError(code: "UNAVAILABLE",
    //                       message: "Battery level not available.",
    //                       details: nil))
    // } else {
    //   result(Int(device.batteryLevel * 100))
    // }
  }
}
