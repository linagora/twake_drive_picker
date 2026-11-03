import 'package:flutter_test/flutter_test.dart';
// Only the UI-free entry point: a regression that makes it need a widget
// library fails to compile here.
import 'package:twake_drive_picker/core.dart';

void main() {
  test('core.dart exposes the headless building blocks', () {
    final config = WorkplaceConfig(requireHttps: true);
    expect(config.requireHttps, isTrue);
    expect(const DrivePickOutcomeCancelled(), isA<DrivePickOutcome>());
    expect(const NoopWorkplaceLogger(), isA<WorkplaceLogger>());
  });

  test('the bridge is optional and reports no bridge off the browser', () {
    const bridge = UnsupportedCozyBridgeTransport();
    expect(bridge.isBridgeSupported, isFalse);
    expect(bridge.isBridgeAvailable, isFalse);
    expect(
      () => bridge.fetchJson(method: 'GET', path: '/'),
      throwsUnsupportedError,
    );
  });
}
