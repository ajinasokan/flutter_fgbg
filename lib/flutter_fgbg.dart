import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum FGBGType { foreground, background }

class FGBGEvents {
  FGBGEvents._() {}

  final _eventChannel = EventChannel("com.ajinasokan.flutter_fgbg/events");

  // ignore: unused_field
  late final AppLifecycleListener _listener;

  StreamController<FGBGType>? _controller;
  Stream<FGBGType> get stream {
    if (_controller == null) {
      _controller = StreamController<FGBGType>.broadcast();

      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        _eventChannel
            .receiveBroadcastStream()
            .map((e) => e == "foreground" ? FGBGType.foreground : FGBGType.background)
            .listen(_sendEvent);
      } else {
        // not disposing this. class is singleton, so only one instance
        // throughout the life of the app, and no handle to dispose.
        // stream is broadcast so events that are not consumed will be discarded.
        // overhead is minimal.
        _listener = AppLifecycleListener(
          onHide: () {
            _sendEvent(FGBGType.background);
          },
          onShow: () {
            _sendEvent(FGBGType.foreground);
          },
        );
      }
    }
    return _controller!.stream;
  }

  void _sendEvent(FGBGType event) {
    // don't send events if `ignoreWhile` is active
    // don't send events if last event is same as current one
    if (!_ignoreEvent && _last != event) _controller!.add(event);

    _last = event;
  }

  static FGBGEvents? _instance;
  static FGBGEvents get instance => _instance ??= FGBGEvents._();

  static FGBGType _last = FGBGType.foreground;
  static FGBGType get last => _last;

  static bool _ignoreEvent = false;
  static Future<void> ignoreWhile(dynamic Function() closure) async {
    _ignoreEvent = true;
    try {
      final result = closure();
      if (result is Future) await result;
    } finally {
      _ignoreEvent = false;
    }
  }

  // Method to reset the singleton instance, useful for testing purposes.
  static void reset() {
    _instance = null;
  }
}

class FGBGNotifier extends StatefulWidget {
  final Widget child;
  final ValueChanged<FGBGType> onEvent;

  FGBGNotifier({required this.child, required this.onEvent});

  @override
  _FGBGNotifierState createState() => _FGBGNotifierState();
}

class _FGBGNotifierState extends State<FGBGNotifier> {
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();

    subscription = FGBGEvents.instance.stream.listen((event) {
      widget.onEvent.call(event);
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
