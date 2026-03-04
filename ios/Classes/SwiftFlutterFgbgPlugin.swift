import UIKit
import Flutter
import UserNotifications

public class SwiftFlutterFGBGPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var isFirstActivation = true

    public static func register(with registrar: FlutterPluginRegistrar) {
        print("[BackgroundDetector] FGBG plugin register() called")
        let instance = SwiftFlutterFGBGPlugin()

        let lifeCycleChannel = "com.ajinasokan.flutter_fgbg/events"
        let lifecycleEventChannel = FlutterEventChannel(name: lifeCycleChannel, binaryMessenger: registrar.messenger())
        lifecycleEventChannel.setStreamHandler(instance as FlutterStreamHandler & NSObjectProtocol)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(instance,
                                       selector: #selector(didEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)

        notificationCenter.addObserver(instance,
                                       selector: #selector(willEnterForeground),
                                       name: UIApplication.willEnterForegroundNotification,
                                       object: nil)

        notificationCenter.addObserver(instance,
                                       selector: #selector(didBecomeActive),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)

        print("[BackgroundDetector] FGBG plugin observers registered, isFirstActivation=\(instance.isFirstActivation)")
    }

    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        print("[BackgroundDetector] FGBG onListen called, eventSink is now set, isFirstActivation=\(isFirstActivation)")
        self.eventSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("[BackgroundDetector] FGBG onCancel called")
        eventSink = nil
        return nil
    }

    @objc func didEnterBackground() {
        print("[BackgroundDetector] FGBG didEnterBackground called, eventSink=\(eventSink != nil ? "set" : "nil")")
        self.eventSink?("background")
    }

    @objc func willEnterForeground() {
        print("[BackgroundDetector] FGBG willEnterForeground called, eventSink=\(eventSink != nil ? "set" : "nil"), isFirstActivation=\(isFirstActivation)")
        isFirstActivation = false
        self.eventSink?("foreground")
    }

    @objc func didBecomeActive() {
        print("[BackgroundDetector] FGBG didBecomeActive called, eventSink=\(eventSink != nil ? "set" : "nil"), isFirstActivation=\(isFirstActivation)")
        if isFirstActivation {
            isFirstActivation = false
            print("[BackgroundDetector] FGBG didBecomeActive: emitting foreground (first activation)")
            self.eventSink?("foreground")
        } else {
            print("[BackgroundDetector] FGBG didBecomeActive: skipping (not first activation)")
        }
    }
}
