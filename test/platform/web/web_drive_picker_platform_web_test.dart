@TestOn('chrome')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/data/bridge/cozy_bridge.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/platform/web/web_drive_picker_platform.dart';

import '../../test_utils/cozy_bridge_test_helper.dart';

void main() {
  tearDown(removeCozyBridge);

  test('is the default platform on web', () {
    expect(DrivePickerPlatform.current, isA<WebDrivePickerPlatform>());
  });

  test(
    'bridge is supported, available only once the container installs it',
    () {
      removeCozyBridge();
      expect(CozyBridge.isSupported, isTrue);
      expect(CozyBridge.isAvailable, isFalse);
      installCozyBridge((_) => null);
      expect(CozyBridge.isAvailable, isTrue);
    },
  );
}
