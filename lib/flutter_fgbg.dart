import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum FGBGType {
  foreground,
  background,
}

class FGBGEvents {
  static const _channel = EventChannel("com.ajinasokan.flutter_fgbg/events");

  static Stream<FGBGType> get stream =>
      _channel.receiveBroadcastStream().map((event) =>
          event == "foreground" ? FGBGType.foreground : FGBGType.background);
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
    subscription = FGBGEvents.stream.listen((event) {
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
