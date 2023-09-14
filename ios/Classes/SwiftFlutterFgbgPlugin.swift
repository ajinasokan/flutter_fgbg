import UIKit
import Flutter
import UserNotifications

public class SwiftFlutterFGBGPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterFGBGPlugin()
        
        let lifeCycleChannel = "com.ajinasokan.flutter_fgbg/events"
        let methodChannelName = "com.ajinasokan.flutter_fgbg/method"
        
        let lifecycleEventChannel = FlutterEventChannel(name: lifeCycleChannel, binaryMessenger: registrar.messenger())
        
        lifecycleEventChannel.setStreamHandler(instance as FlutterStreamHandler & NSObjectProtocol)
        
        
        let methodChannel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: registrar.messenger()
        )
        methodChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            
            if(call.method == "current") {
                let state = UIApplication.shared.applicationState;
                
                let resultString = (state == .active) ? "foreground" : "background"
                result(resultString)
            } else {
                result(FlutterMethodNotImplemented)
                
            }
        })
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(instance,
                                       selector: #selector(didEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
        
        notificationCenter.addObserver(instance,
                                       selector: #selector(willEnterForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)
    }
    
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    @objc func didEnterBackground() {
        self.eventSink?("background")
    }
    
    @objc func willEnterForeground() {
        self.eventSink?("foreground")
    }
}
