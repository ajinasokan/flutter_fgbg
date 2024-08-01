import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final picker = ImagePicker();
  List<String> events = [];
  bool get _webOrMobile => kIsWeb || Platform.isAndroid || Platform.isIOS;
  bool get _mobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    events.add(state.toString());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return FGBGNotifier(
      onEvent: (event) {
        events.add(event.toString());
        setState(() {});
      },
      child: MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('All platforms:'),
                  ElevatedButton(
                    onPressed: () {
                      events.clear();
                      setState(() {});
                    },
                    child: const Text("Clear logs"),
                  ),
                  const SizedBox(height: 16),
                  const Text('Web + Mobile only:'),
                  ElevatedButton(
                    onPressed: !_webOrMobile
                        ? null
                        : () async {
                            events.add("// Opening camera");
                            setState(() {});
                            await picker.pickImage(source: ImageSource.camera);
                          },
                    child: const Text("Take Image"),
                  ),
                  ElevatedButton(
                    onPressed: !_webOrMobile
                        ? null
                        : () async {
                            events.add("// Opening gallery");
                            setState(() {});
                            await picker.pickImage(source: ImageSource.gallery);
                          },
                    child: const Text("Pick Image"),
                  ),
                  ElevatedButton(
                    onPressed: !_webOrMobile
                        ? null
                        : () async {
                            events.add(
                                "// Opening camera but ignoring events during this");
                            setState(() {});
                            FGBGEvents.ignoreWhile(() async {
                              await picker.pickImage(
                                  source: ImageSource.camera);
                            });
                          },
                    child: const Text("Take Image ignoreWhile"),
                  ),
                  ElevatedButton(
                    onPressed: !_webOrMobile
                        ? null
                        : () async {
                            events.add(
                                "// Opening gallery but ignoring events during this");
                            setState(() {});

                            FGBGEvents.ignoreWhile(() async {
                              await picker.pickImage(
                                  source: ImageSource.gallery);
                            });
                          },
                    child: const Text("Pick Image ignoreWhile"),
                  ),
                  const SizedBox(height: 16),
                  const Text('Mobile only:'),
                  ElevatedButton(
                    onPressed: !_mobile
                        ? null
                        : () async {
                            events.add("// Prompting biometric");
                            setState(() {});
                            var auth = LocalAuthentication();

                            await auth.authenticate(
                              // biometricOnly: true,
                              options: const AuthenticationOptions(
                                biometricOnly: true,
                              ),
                              localizedReason: 'Test',
                            );
                          },
                    child: const Text("FaceID"),
                  ),
                  const SizedBox(height: 16),
                  const Text('Events:'),
                  Expanded(
                    child: ListView(
                      children: [for (var e in events) Text(e)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
