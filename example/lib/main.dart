import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final picker = ImagePicker();

  List<String> events = [];

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
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        events.clear();
                        setState(() {});
                      },
                      child: Text("Clear"),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        events.add("// Opening camera");
                        setState(() {});
                        await picker.getImage(source: ImageSource.camera);
                      },
                      child: Text("Take Image"),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        events.add("// Opening gallery");
                        setState(() {});
                        await picker.getImage(source: ImageSource.gallery);
                      },
                      child: Text("Pick Image"),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        events.add("// Prompting biometric");
                        setState(() {});
                        var auth = LocalAuthentication();

                        List<BiometricType> availableBiometrics =
                            await auth.getAvailableBiometrics();

                        if (Platform.isIOS) {
                          if (availableBiometrics
                              .contains(BiometricType.face)) {
                            await auth.authenticateWithBiometrics(
                                localizedReason: 'Test');
                          } else if (availableBiometrics
                              .contains(BiometricType.fingerprint)) {
                            await auth.authenticateWithBiometrics(
                                localizedReason: 'Test');
                          }
                        }
                      },
                      child: Text("FaceID"),
                    ),
                  ],
                ),
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
    );
  }
}
