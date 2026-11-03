import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/platform/mobile/mobile_drive_picker_platform.dart';

void main() {
  const platform = MobileDrivePickerPlatform();

  test('has no cozy bridge', () {
    expect(platform.isBridgeSupported, isFalse);
    expect(platform.isBridgeAvailable, isFalse);
    expect(
      () => platform.fetchJson(method: 'GET', path: '/'),
      throwsUnsupportedError,
    );
  });

  test('listenToWindowMessages is a no-op that can be stopped', () {
    var calls = 0;
    final stop = platform.listenToWindowMessages((_, __) => calls++);
    stop();
    expect(calls, 0);
  });
}
