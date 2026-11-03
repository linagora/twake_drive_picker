import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/entity/workplace_theme.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/picker/drive_origin_validator.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';
import 'package:twake_drive_picker/src/platform/drive_picker_platform.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_icon_button.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';
import 'package:twake_drive_picker/src/presentation/view/deliver_drive_intent_outcome.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_plain_loader.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_view_frame.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view_modal.dart';

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

/// Records what the view / modal asked the platform to build.
class _RecordingPlatform extends DrivePickerPlatform {
  Map<String, Object?>? view;
  Map<String, Object?>? modal;

  @override
  bool get isBridgeSupported => false;
  @override
  bool get isBridgeAvailable => false;
  @override
  Future<dynamic> fetchJson({
    required String method,
    required String path,
    Object? body,
    Map<String, String>? headers,
  }) => throw UnsupportedError('unused');
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
  }) {
    modal = {'assets': imageAssets, 'config': filePickerConfig};
    return const Text('modal');
  }

  @override
  Widget buildView({
    required DriveIntentLoader intentLoader,
    required WorkplaceFilePickerConfigRequest filePickerConfig,
    required DriveIntentImageAssets? imageAssets,
    required DriveIconButtonBuilder iconButtonBuilder,
    required WorkplaceLogger logger,
    ValueChanged<DrivePickOutcome>? onResult,
    VoidCallback? onClose,
  }) {
    view = {
      'assets': imageAssets,
      'config': filePickerConfig,
      'onResult': onResult,
      'onClose': onClose,
      'logger': logger,
    };
    return const Text('view');
  }
}

class _FinishHost extends StatefulWidget {
  const _FinishHost({required this.pops});
  final bool pops;

  @override
  State<_FinishHost> createState() => _FinishHostState();
}

class _FinishHostState extends State<_FinishHost>
    with DriveIntentMessageHandlerMixin {
  final outcomes = <DrivePickOutcome>[];

  @override
  bool get popsRouteOnFinish => widget.pops;
  @override
  DriveOriginValidator get originValidator =>
      const MobileDriveOriginValidator();
  @override
  Future<void> sendAck() async {}
  @override
  Future<void> loadIntent(WorkplaceIntent intent) async {}
  @override
  void onFinished(DrivePickOutcome outcome) => outcomes.add(outcome);
  @override
  Widget build(BuildContext context) => const Text('host');
}

Future<_FinishHostState> _pumpHostOnTopRoute(
  WidgetTester tester, {
  required bool pops,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => _FinishHost(pops: pops)),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return tester.state<_FinishHostState>(find.byType(_FinishHost));
}

void main() {
  group('DriveIntentWebView', () {
    testWidgets('hands its inputs to the platform view', (tester) async {
      final platform = _RecordingPlatform();
      void onClose() {}
      void onResult(DrivePickOutcome _) {}

      await tester.pumpWidget(
        MaterialApp(
          home: DriveIntentWebView(
            platform: platform,
            intentLoader: _loader,
            filePickerConfig: _config,
            imageAssets: _assets,
            onResult: onResult,
            onClose: onClose,
          ),
        ),
      );

      expect(find.text('view'), findsOneWidget);
      expect(platform.view!['assets'], same(_assets));
      expect(platform.view!['config'], same(_config));
      expect(platform.view!['onResult'], same(onResult));
      expect(platform.view!['onClose'], same(onClose));
      expect(platform.modal, isNull);
    });

    testWidgets('needs no image assets', (tester) async {
      final platform = _RecordingPlatform();

      await tester.pumpWidget(
        MaterialApp(
          home: DriveIntentWebView(
            platform: platform,
            intentLoader: _loader,
            filePickerConfig: _config,
          ),
        ),
      );

      expect(platform.view!['assets'], isNull);
      expect(platform.view!['logger'], isA<NoopWorkplaceLogger>());
    });
  });

  group('DriveIntentWebViewModal', () {
    testWidgets('still builds the dialog modal, not the embedded view', (
      tester,
    ) async {
      final platform = _RecordingPlatform();

      await tester.pumpWidget(
        MaterialApp(
          home: DriveIntentWebViewModal(
            platform: platform,
            intentLoader: _loader,
            filePickerConfig: _config,
            imageAssets: _assets,
          ),
        ),
      );

      expect(find.text('modal'), findsOneWidget);
      expect(platform.modal!['assets'], same(_assets));
      expect(platform.view, isNull);
    });
  });

  group('DriveIntentMessageHandlerMixin::popsRouteOnFinish', () {
    testWidgets('true (default for the dialog) pops the route', (tester) async {
      final host = await _pumpHostOnTopRoute(tester, pops: true);

      host.cancel();
      await tester.pumpAndSettle();

      expect(find.text('host'), findsNothing);
      expect(host.outcomes, [const DrivePickOutcomeCancelled()]);
    });

    testWidgets('false leaves the route to the host', (tester) async {
      final host = await _pumpHostOnTopRoute(tester, pops: false);

      host.cancel();
      await tester.pumpAndSettle();

      expect(find.text('host'), findsOneWidget);
      expect(host.outcomes, [const DrivePickOutcomeCancelled()]);
    });
  });

  group('deliverDriveIntentOutcome', () {
    test('reports the outcome, then closes', () {
      final calls = <String>[];

      deliverDriveIntentOutcome(
        const DrivePickOutcomeCancelled(),
        onResult: (o) => calls.add('result:${o.runtimeType}'),
        onClose: () => calls.add('close'),
      );

      expect(calls, ['result:DrivePickOutcomeCancelled', 'close']);
    });

    test('closes even when the result handler throws', () {
      var closed = false;

      expect(
        () => deliverDriveIntentOutcome(
          const DrivePickOutcomeCancelled(),
          onResult: (_) => throw StateError('handler bug'),
          onClose: () => closed = true,
        ),
        throwsStateError,
      );
      expect(closed, isTrue);
    });

    test('works with no callbacks', () {
      deliverDriveIntentOutcome(const DrivePickOutcomeCancelled());
    });
  });

  group('DriveIntentViewFrame', () {
    Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

    testWidgets('has no dialog and fills its parent', (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 300,
            height: 400,
            child: DriveIntentViewFrame(
              onClose: () {},
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.byType(Dialog), findsNothing);
      expect(
        tester.getSize(find.byKey(const ValueKey('drive-shell-content'))),
        const Size(300, 400),
      );
    });

    testWidgets('built-in close button needs no asset and reports the tap', (
      tester,
    ) async {
      var closed = 0;
      await tester.pumpWidget(
        host(
          DriveIntentViewFrame(
            onClose: () => closed++,
            loadingWidget: (closeButton) =>
                DriveIntentPlainLoader(closeButton: closeButton),
            child: const SizedBox.expand(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));

      expect(closed, 1);
    });

    testWidgets('uses the host icon button when an icon path is given', (
      tester,
    ) async {
      DriveIconButtonSpec? seen;
      await tester.pumpWidget(
        host(
          DriveIntentViewFrame(
            onClose: () {},
            closeIconPath: 'close.svg',
            iconButtonBuilder: (spec) {
              seen = spec;
              return const Text('custom-close');
            },
            loadingWidget: (closeButton) => closeButton,
            child: const SizedBox.expand(),
          ),
        ),
      );

      expect(find.text('custom-close'), findsOneWidget);
      expect(seen!.icon, 'close.svg');
    });

    testWidgets('shows no overlay once loading is over', (tester) async {
      await tester.pumpWidget(
        host(
          DriveIntentViewFrame(onClose: () {}, child: const SizedBox.expand()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
