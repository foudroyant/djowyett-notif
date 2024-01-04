// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:onesignal_flutter/onesignal_flutter.dart';

Future oneSignal() async {
  // Add your function code here!
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // NOTE: Replace with your own app ID from https://www.onesignal.com
  OneSignal.initialize("f65ca766-4b02-4d67-b70a-9839e5e6faca");
  OneSignal.Notifications.requestPermission(true);
}
