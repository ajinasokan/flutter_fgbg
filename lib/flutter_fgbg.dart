import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum FGBGType {
  enteredForeground,
  enteredBackground,
  willEnterForeground,
  willTerminate,
  willSwitchContext,
  unknown,
}

Map<String, FGBGType> messageToFGBGMapping = {
  // iOS Mappings
  "didBecomeActive": FGBGType.enteredForeground,
  "didEnterBackground": FGBGType.enteredBackground,
  "willEnterForeground": FGBGType.willEnterForeground,
  "willResignActive": FGBGType.willSwitchContext,
  "willTerminate": FGBGType.willTerminate,

  // Android Mappings
  "ON_RESUME": FGBGType.enteredForeground,
  "ON_STOP": FGBGType.enteredBackground,
  "ON_CREATE": FGBGType.willEnterForeground,
  "ON_PAUSE": FGBGType.willSwitchContext,
  "ON_DESTROY": FGBGType.willTerminate,
};

class FGBGEvents {
  static const _channel = EventChannel("com.ajinasokan.flutter_fgbg/events");

  static Stream<FGBGType> get stream =>
      _channel.receiveBroadcastStream().map((event) => messageToFGBGMapping[event] ?? FGBGType.unknown);
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
