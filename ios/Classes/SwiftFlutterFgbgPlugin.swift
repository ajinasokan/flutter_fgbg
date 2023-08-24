import UIKit
import Flutter
import UserNotifications


public class NotificationCenterHandler: NSObject, FlutterStreamHandler {
    public var eventSink: FlutterEventSink?

    public var eventChannel: FlutterEventChannel?
    public var notificationCenter: NotificationCenter?

    public static func create(with registrar: FlutterPluginRegistrar) -> NotificationCenterHandler? {
        do {
            let instance = NotificationCenterHandler()
            let lifeCycleChannel = "com.ajinasokan.flutter_fgbg/events"
            instance.eventChannel = FlutterEventChannel(name: lifeCycleChannel, binaryMessenger: registrar.messenger())
            instance.eventChannel?.setStreamHandler(instance as FlutterStreamHandler & NSObjectProtocol)

            instance.notificationCenter = NotificationCenter.default
            instance.notificationCenter?.addObserver(instance,
                                        selector: #selector(didBecomeActive),
                                        name: UIApplication.didBecomeActiveNotification,
                                        object: nil)
            
            instance.notificationCenter?.addObserver(instance,
                                        selector: #selector(didEnterBackground),
                                        name: UIApplication.didEnterBackgroundNotification,
                                        object: nil)

            instance.notificationCenter?.addObserver(instance,
                                            selector: #selector(willEnterForeground),
                                            name: UIApplication.willEnterForegroundNotification,
                                            object: nil)
            
            instance.notificationCenter?.addObserver(instance,
                                        selector: #selector(willResignActive),
                                        name: UIApplication.willResignActiveNotification,
                                        object: nil)
            

            instance.notificationCenter?.addObserver(instance,
                                            selector: #selector(willTerminate),
                                            name: UIApplication.willTerminateNotification,
                                            object: nil)

            return instance
        } catch {
            print("Yikes we couldn't create the FGBG at all")
        }
        
    }

    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        eventChannel = nil

        do {
            notificationCenter?.removeObserver(self,
                                   name: UIApplication.didBecomeActiveNotification,
                                   object: nil)
    
            notificationCenter?.removeObserver(self,
                                        name: UIApplication.didEnterBackgroundNotification,
                                        object: nil)

            notificationCenter?.removeObserver(self,
                                            name: UIApplication.willEnterForegroundNotification,
                                            object: nil)
            
            notificationCenter?.removeObserver(self,
                                        name: UIApplication.willResignActiveNotification,
                                        object: nil)
            

            notificationCenter?.removeObserver(self,
                                            name: UIApplication.willTerminateNotification,
                                            object: nil)

        } catch {
            print("Yikes we couldn't remove observers")
        }
        
        notificationCenter = nil
        return nil
    }

     public func addToEventSink(event: String) {
        do {
            try eventSink?(event)
        } catch {
            print("Flutter Engine was probably not ready yet. Message will not be sent.")
        }
    }
    
    @objc func didBecomeActive() {
        addToEventSink(event: "didBecomeActive")
    }

    @objc func didEnterBackground() {
        addToEventSink(event: "didEnterBackground")
    }

    @objc func willEnterForeground() {
        addToEventSink(event: "willEnterForeground")
    }

    @objc func willResignActive() {
        addToEventSink(event: "willResignActive")
    }

    @objc func willTerminate() {
        addToEventSink(event: "willTerminate")
    }

}

public class SwiftFlutterFGBGPlugin: NSObject, FlutterPlugin {
 
 public static var notificationCenterHandler: NotificationCenterHandler?

  public static func register(with registrar: FlutterPluginRegistrar) {

    SwiftFlutterFGBGPlugin.notificationCenterHandler = NotificationCenterHandler.create(with: registrar)
    
  }

  public static func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    SwiftFlutterFGBGPlugin.notificationCenterHandler?.onCancel(withArguments: nil)
    SwiftFlutterFGBGPlugin.notificationCenterHandler = nil
  }
    

}
