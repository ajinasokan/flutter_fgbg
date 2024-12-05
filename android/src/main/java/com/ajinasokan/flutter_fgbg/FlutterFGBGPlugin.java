package com.ajinasokan.flutter_fgbg;


import androidx.annotation.NonNull;
import androidx.lifecycle.Lifecycle;
import androidx.lifecycle.LifecycleEventObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.lifecycle.ProcessLifecycleOwner;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;

/** FlutterFGBGPlugin */
public class FlutterFGBGPlugin implements FlutterPlugin, ActivityAware, LifecycleEventObserver, EventChannel.StreamHandler {
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

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {}

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    ProcessLifecycleOwner.get().getLifecycle().addObserver(this);
  }

  @Override
  public void onStateChanged(@NonNull LifecycleOwner lifecycleOwner, @NonNull Lifecycle.Event event) {
    if (lifecycleSink != null) {
      if(event == Lifecycle.Event.ON_START) {
        lifecycleSink.success("foreground");
      } else if (event == Lifecycle.Event.ON_STOP) {
        lifecycleSink.success("background");
      }
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
