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

  final _nativeEvents = EventChannel("com.ajinasokan.flutter_fgbg/events");
  final _lifeCycleEvents = StreamController<FGBGType>.broadcast();
  // ignore: unused_field
  late final AppLifecycleListener _listener;

  Stream<FGBGType>? _stream;
  Stream<FGBGType> get stream {
    if (_stream == null) {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // don't send events if `ignoreWhile` is active
        _stream = _nativeEvents
            .receiveBroadcastStream()
            .map((e) =>
                e == "foreground" ? FGBGType.foreground : FGBGType.background)
            .where((e) {
          final broadcast = !_ignoreEvent && _last != e;
          _last = e;
          return broadcast;
        });
      } else {
        // not disposing this. class is singleton, so only one instance
        // throughout the life of the app, and no handle to dispose.
        // stream is broadcast so events that are not consumed will be discarded.
        // overhead is minimal.
        _listener = AppLifecycleListener(
          onHide: () => _lifeCycleEvents.add(FGBGType.background),
          onShow: () => _lifeCycleEvents.add(FGBGType.foreground),
        );
        // don't send events if `ignoreWhile` is active
        _stream = _lifeCycleEvents.stream.where((e) {
          final broadcast = !_ignoreEvent && _last != e;
          _last = e;
          return broadcast;
        });
      }
    }
    return _stream!;
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
