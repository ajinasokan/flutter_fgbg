import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum FGBGType {
  foreground,
  background,
}

class FGBGEvents {
  FGBGEvents._() {}

  final _channel = EventChannel("com.ajinasokan.flutter_fgbg/events");
  Stream<FGBGType>? _stream;

  Stream<FGBGType> get stream {
    return _stream ??= _channel
        .receiveBroadcastStream()
        .where((_) => !_ignoreEvent)
        .map((e) =>
            e == "foreground" ? FGBGType.foreground : FGBGType.background);
  }

  static FGBGEvents? _instance;
  static FGBGEvents get instance => _instance ??= FGBGEvents._();

  static bool _ignoreEvent = false;
  static void ignoreWhile(dynamic Function() closure) async {
    _ignoreEvent = true;
    try {
      final result = closure();
      if (result is Future) await result;
    } finally {
      _ignoreEvent = false;
    }
  }
}

class FGBGNotifier extends StatefulWidget {
  final Widget child;
  final ValueChanged<FGBGType> onEvent;

  FGBGNotifier({
    required this.child,
    required this.onEvent,
  });

  @override
  _FGBGNotifierState createState() => _FGBGNotifierState();
}

class _FGBGNotifierState extends State<FGBGNotifier> {
  StreamSubscription? subscription;
  AppLifecycleListener? listener;

  @override
  void initState() {
    super.initState();

    // NOTE: short-circuit the platform check on web to avoid a crash
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      // use mobile-specific implementations
      subscription = FGBGEvents.instance.stream.listen((event) {
        widget.onEvent.call(event);
      });
    } else {
      // use Flutter's default implementation
      listener = AppLifecycleListener(
        onStateChange: (state) {
          // check if we're ignoring events right now
          if (FGBGEvents._ignoreEvent) {
            return;
          }

          // map AppLifecycleState.state to FGBGType events
          switch (state) {
            case AppLifecycleState.resumed:
              widget.onEvent.call(FGBGType.foreground);
              break;
            default:
              widget.onEvent.call(FGBGType.background);
              break;
          }
        },
      );
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    listener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
