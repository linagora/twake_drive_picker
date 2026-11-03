import 'package:flutter/material.dart';
import 'package:twake_drive_picker_example/src/example_app.dart';

/// Android / iOS entry point. Imports only the mobile-safe API: nothing of
/// the web platform is compiled in.
void main() => runApp(const ExampleApp(platformLabel: 'mobile'));
