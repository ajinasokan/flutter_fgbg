package com.ajinasokan.flutter_fgbg


import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** FlutterFgbgPlugin */
class FlutterFGBGPlugin : FlutterPlugin, ActivityAware, LifecycleObserver,
    EventChannel.StreamHandler, MethodChannel.MethodCallHandler {

    private var lifecycleSink: EventSink? = null
    private var _inForeground = true

    override fun onListen(arguments: Any?, events: EventSink?) {
        lifecycleSink = events
    }

    override fun onCancel(arguments: Any?) {
        lifecycleSink = null
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        EventChannel(flutterPluginBinding.binaryMessenger, "com.ajinasokan.flutter_fgbg/events")
            .setStreamHandler(this)

        MethodChannel(flutterPluginBinding.binaryMessenger, "com.ajinasokan.flutter_fgbg/method")
            .setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {}

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun onAppBackgrounded() {
        _inForeground = false
        lifecycleSink?.success("background")
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    fun onAppForegrounded() {
        _inForeground = true
        lifecycleSink?.success("foreground")
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {
        ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if ((call.method == "current")) {
            result.success(if (_inForeground) "foreground" else "background")
        } else {
            result.notImplemented()
        }
    }
}
