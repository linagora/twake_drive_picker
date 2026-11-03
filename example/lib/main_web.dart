import 'package:flutter/material.dart';
import 'package:twake_drive_picker/web.dart';
import 'package:twake_drive_picker_example/src/example_app.dart';

/// Web entry point. `package:twake_drive_picker/web.dart` exposes the web
/// platform (iframe + postMessage + cozy bridge).
void main() {
  final bridge = const WebDrivePickerPlatform().isBridgeAvailable
      ? 'cozy bridge'
      : 'standalone';
  runApp(ExampleApp(platformLabel: 'web ($bridge)'));
}
