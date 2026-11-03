// The deprecated `platform:` shims are exercised on purpose.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/twake_drive_picker.dart';

import '../test_utils/fake_workplace_repository.dart';

/// A custom platform written against the 0.2.0 API before `buildView` was
/// added (commit 634ec9b): it implements only the members that existed then.
/// It must keep compiling and working through the public barrel alone.
class _LegacyPlatform extends DrivePickerPlatform {
  final List<String> fetched = [];

  @override
  bool get isBridgeSupported => true;

  @override
  bool get isBridgeAvailable => true;

  @override
  Future<dynamic> fetchJson({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? headers,
  }) async {
    fetched.add('$method $path');
    return {'ok': true};
  }

  @override
  StopWindowMessageListener listenToWindowMessages(
    WindowMessageCallback onMessage, {
    Object? Function()? expectedFrame,
  }) => () {};

  @override
  Widget buildModal({
    required DriveIntentLoader intentLoader,
    required WorkplaceFilePickerConfigRequest filePickerConfig,
    required DriveIntentImageAssets imageAssets,
    required DriveIconButtonBuilder iconButtonBuilder,
    required WorkplaceLogger logger,
  }) => const Text('legacy modal', textDirection: TextDirection.ltr);
}

class _EchoCall extends WorkplaceCall<String> {
  const _EchoCall();

  @override
  BridgePolicy get bridgePolicy => BridgePolicy.noBearerReplay;

  @override
  Future<String> call(WorkplaceAccessMode accessMode) async =>
      accessMode is BridgeAccessMode ? 'bridge' : 'bearer';
}

const _assets = DriveIntentImageAssets(
  driveLogo: 'logo.svg',
  closeIcon: 'close.svg',
  searchIcon: 'search.svg',
);

final _config = WorkplaceFilePickerConfigRequest(
  sharingLink: const WorkplaceActionConfigRequest(label: 'Link'),
  downloadLink: null,
  theme: WorkplaceThemeConfigRequest.fromEntity(WorkplaceTheme.light),
);

Future<WorkplaceIntent> _loader() => Future.error(StateError('unused'));

void main() {
  group('a DrivePickerPlatform without buildView', () {
    testWidgets('still builds the modal', (tester) async {
      await tester.pumpWidget(
        DriveIntentWebViewModal(
          intentLoader: _loader,
          filePickerConfig: _config,
          imageAssets: _assets,
          platform: _LegacyPlatform(),
        ),
      );

      expect(find.text('legacy modal'), findsOneWidget);
    });

    test('buildView throws an UnsupportedError naming the platform', () {
      expect(
        () => _LegacyPlatform().buildView(
          intentLoader: _loader,
          filePickerConfig: _config,
          imageAssets: null,
          iconButtonBuilder: defaultDriveIconButtonBuilder,
          logger: const NoopWorkplaceLogger(),
        ),
        throwsA(
          isA<UnsupportedError>().having(
            (e) => e.message,
            'message',
            allOf(contains('_LegacyPlatform'), contains('buildView')),
          ),
        ),
      );
    });

    testWidgets('DriveIntentWebView reports the UnsupportedError', (
      tester,
    ) async {
      await tester.pumpWidget(
        DriveIntentWebView(
          intentLoader: _loader,
          filePickerConfig: _config,
          platform: _LegacyPlatform(),
        ),
      );

      expect(tester.takeException(), isA<UnsupportedError>());
    });

    test('the built-in platform overrides buildView', () {
      expect(
        () => DrivePickerPlatform.current.buildView(
          intentLoader: _loader,
          filePickerConfig: _config,
          imageAssets: null,
          iconButtonBuilder: defaultDriveIconButtonBuilder,
          logger: const NoopWorkplaceLogger(),
        ),
        returnsNormally,
      );
    });
  });

  group('deprecated platform: parameters', () {
    test('WorkplaceRequestExecutor sends bridge requests to it', () async {
      final platform = _LegacyPlatform();
      final executor = WorkplaceRequestExecutor(platform: platform);

      final result = await executor.send(
        context: WorkplaceRequestContext(
          platformUrl: Uri.parse('https://drive.example.com'),
          accessMode: const BridgeAccessMode(),
        ),
        route: const WorkplaceRequestRoute(
          method: 'GET',
          pathSegments: ['files', 'io.cozy.files.root-dir'],
        ),
      );

      expect(result, {'ok': true});
      expect(platform.fetched, ['GET /files/io.cozy.files.root-dir']);
    });

    test('bridge: wins over platform: on the executor', () async {
      final bridge = _LegacyPlatform();
      final platform = _LegacyPlatform();
      final executor = WorkplaceRequestExecutor(
        bridge: bridge,
        platform: platform,
      );

      await executor.send(
        context: WorkplaceRequestContext(
          platformUrl: Uri.parse('https://drive.example.com'),
          accessMode: const BridgeAccessMode(),
        ),
        route: const WorkplaceRequestRoute(method: 'GET', pathSegments: ['x']),
      );

      expect(bridge.fetched, hasLength(1));
      expect(platform.fetched, isEmpty);
    });

    test(
      'WorkplaceAccessModeRunner reads bridge availability from it',
      () async {
        final runner = WorkplaceAccessModeRunner(
          exchangeTokenInteractor: ExchangeDriveTokenInteractor(
            FakeWorkplaceRepository(),
          ),
          oidcTokenGetter: () => null,
          oidcRefreshTrigger: () async => null,
          platform: _LegacyPlatform(),
        );

        final result = await runner.run(
          Uri.parse('https://drive.example.com'),
          const _EchoCall(),
        );

        expect(result, 'bridge');
      },
    );
  });
}
