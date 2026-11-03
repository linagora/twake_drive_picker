@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/data/bridge/cozy_bridge.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/platform/mobile/mobile_drive_picker_platform.dart';

void main() {
  test('is the mobile platform off the browser', () {
    expect(DrivePickerPlatform.current, isA<MobileDrivePickerPlatform>());
  });

  test('CozyBridge facade reports no bridge on mobile', () {
    expect(CozyBridge.isSupported, isFalse);
    expect(CozyBridge.isAvailable, isFalse);
  });
}
