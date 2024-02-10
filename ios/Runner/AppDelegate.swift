import UIKit
import Flutter
import WebKit
import webview_flutter_wkwebview;

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
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            // This method is invoked on the UI thread.
            guard call.method == "receiveCFCookies" else {
                result(FlutterMethodNotImplemented)
                return
            }
            self?.receiveCFCookies(result: result)
            //            self?.getCookies(result: result, application: application, arguments: call.arguments as! Int)
        })
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func receiveCFCookies(result: @escaping FlutterResult) {
        var httpCookieStore: WKHTTPCookieStore = WKWebsiteDataStore.default().httpCookieStore
        let url = "https://nhentai.net"
        var cookiesString = ""
        
        // ensure passed in url is parseable, and extract the host
        let host = URL(string: url)?.host
        
        // fetch and filter cookies from WKHTTPCookieStore
        httpCookieStore.getAllCookies { (wkCookies) in

            func matches(cookie: HTTPCookie) -> Bool {
                // nil host means unparseable url or empty string
                let containsHost = host.map{cookie.domain.contains($0)} ?? false
                let containsDomain = host?.contains(cookie.domain) ?? false
                return url == "" || containsHost || containsDomain
            }
            
            var cookies = wkCookies.filter{ matches(cookie: $0) }

            var token = cookies.first(where: { $0.name == "cf_clearance" })?.value
            // cookies.forEach { cookie in
            //     cookiesString += "\(cookie.name)=\(cookie.value); "
            // }
            result(token ?? "")
        }
        
        
    }
    
    private func getCookies(result: FlutterResult, application: UIApplication, arguments: Int) {
        //        if (self.webview == nil){
        //            return
        //        }
        //
        var httpCookieStore: WKHTTPCookieStore? = WKWebsiteDataStore.default().httpCookieStore
        
        let delegate = application.delegate
        httpCookieStore =
        FWFWebViewFlutterWKWebViewExternalAPI.webView(forIdentifier: arguments as Int, with: delegate as! FlutterPluginRegistry)?.configuration.websiteDataStore.httpCookieStore
        
        if (httpCookieStore == nil){
            return
        }
        let url = "https://nhentai.net"
        var cookiesString = ""
        
        // ensure passed in url is parseable, and extract the host
        let host = URL(string: url)?.host
        
        // fetch and filter cookies from WKHTTPCookieStore
        httpCookieStore!.getAllCookies { (wkCookies) in
            wkCookies.forEach { cookie in
                cookiesString += "\(cookie.name)=\(cookie.value); "
            }
            
            func matches(cookie: HTTPCookie) -> Bool {
                // nil host means unparseable url or empty string
                let containsHost = host.map{cookie.domain.contains($0)} ?? false
                let containsDomain = host?.contains(cookie.domain) ?? false
                return url == "" || containsHost || containsDomain
            }
            
            var cookies = wkCookies.filter{ matches(cookie: $0) }
            
            // If the cookie value is empty in WKHTTPCookieStore,
            // get the cookie value from HTTPCookieStorage
            if cookies.count == 0 {
                if let httpCookies = HTTPCookieStorage.shared.cookies {
                    cookies = httpCookies.filter{ matches(cookie: $0) }
                }
            }
            
            // let cookieList: NSMutableArray = NSMutableArray()
            // cookies.forEach{ cookie in
            //     cookieList.add(self._cookieToDictionary(cookie: cookie))
            // }
            // result(cookieList)
        }
        
        
        httpCookieStore = WKWebsiteDataStore.nonPersistent().httpCookieStore
        
        if (httpCookieStore == nil){
            return
        }
        
        // fetch and filter cookies from WKHTTPCookieStore
        httpCookieStore!.getAllCookies { (wkCookies) in
            wkCookies.forEach { cookie in
                cookiesString += "\(cookie.name)=\(cookie.value); "
            }
            
            func matches(cookie: HTTPCookie) -> Bool {
                // nil host means unparseable url or empty string
                let containsHost = host.map{cookie.domain.contains($0)} ?? false
                let containsDomain = host?.contains(cookie.domain) ?? false
                return url == "" || containsHost || containsDomain
            }
            
            var cookies = wkCookies.filter{ matches(cookie: $0) }
            
            // If the cookie value is empty in WKHTTPCookieStore,
            // get the cookie value from HTTPCookieStorage
            if cookies.count == 0 {
                if let httpCookies = HTTPCookieStorage.shared.cookies {
                    cookies = httpCookies.filter{ matches(cookie: $0) }
                }
            }
            // let cookieList: NSMutableArray = NSMutableArray()
            // cookies.forEach{ cookie in
            //     cookieList.add(self._cookieToDictionary(cookie: cookie))
            // }
            // result(cookieList)
        }
        
        //        result(cookiesString)
    }
    
    private func _cookieToDictionary(cookie: HTTPCookie) -> NSDictionary {
        let result : NSMutableDictionary =  NSMutableDictionary()
        
        result.setValue(cookie.name, forKey: "name")
        result.setValue(cookie.value, forKey: "value")
        result.setValue(cookie.domain, forKey: "domain")
        result.setValue(cookie.path, forKey: "path")
        result.setValue(cookie.isSecure, forKey: "secure")
        result.setValue(cookie.isHTTPOnly, forKey: "httpOnly")
        
        if cookie.expiresDate != nil {
            let expiredDate = cookie.expiresDate?.timeIntervalSince1970
            result.setValue(Int(expiredDate!), forKey: "expires")
        }
        
        return result;
    }
    
}
