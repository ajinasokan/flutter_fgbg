package com.ajinasokan.flutter_fgbg;


import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleObserver;
import androidx.lifecycle.OnLifecycleEvent;
import androidx.lifecycle.ProcessLifecycleOwner;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterFGBGPlugin */
public class FlutterFGBGPlugin implements FlutterPlugin, ActivityAware, LifecycleObserver, EventChannel.StreamHandler {
  EventChannel.EventSink lifecycleSink;

  @Override
  public void onListen(Object o, EventChannel.EventSink eventSink) {
    lifecycleSink = eventSink;
  }

  @Override
  public void onCancel(Object o) {
    lifecycleSink = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    new EventChannel(flutterPluginBinding.getBinaryMessenger(), "com.ajinasokan.flutter_fgbg/events")
            .setStreamHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    new EventChannel(registrar.messenger(), "com.ajinasokan.appfocus/events")
            .setStreamHandler(new FlutterFGBGPlugin());
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
  void onAppBackgrounded() {
    if (lifecycleSink != null) {
      lifecycleSink.success("background");
    }
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_START)
  void onAppForegrounded() {
    if (lifecycleSink != null) {
      lifecycleSink.success("foreground");
    }
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {}

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {}

  @Override
  public void onDetachedFromActivity() {
    ProcessLifecycleOwner.get().getLifecycle().removeObserver(this);
  }
}
