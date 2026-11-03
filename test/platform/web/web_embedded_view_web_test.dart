@TestOn('chrome')
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/entity/workplace_theme.dart';
import 'package:twake_drive_picker/src/model/workplace_intent_request.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';
import 'package:twake_drive_picker/src/presentation/model/drive_intent_image_assets.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view.dart';
import 'package:twake_drive_picker/src/presentation/view/drive_intent_web_view_modal.dart';

final _config = WorkplaceFilePickerConfigRequest(
  sharingLink: const WorkplaceActionConfigRequest(label: 'Link'),
  downloadLink: null,
  theme: WorkplaceThemeConfigRequest.fromEntity(WorkplaceTheme.light),
);

/// Never completes: the view stays on its loading overlay.
Future<WorkplaceIntent> _pendingIntent() => Completer<WorkplaceIntent>().future;

void main() {
  testWidgets('embedded view reports a cancel and leaves the route alone', (
    tester,
  ) async {
    final results = <DrivePickOutcome>[];
    var closed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: DriveIntentWebView(
              intentLoader: _pendingIntent,
              filePickerConfig: _config,
              onResult: results.add,
              onClose: () => closed++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(results, [const DrivePickOutcomeCancelled()]);
    expect(closed, 1);
    // Still mounted: the host, not the view, decides what to dismiss.
    expect(find.byType(DriveIntentWebView), findsOneWidget);
  });

  testWidgets('embedded view reports a failed intent once, then closes', (
    tester,
  ) async {
    final results = <DrivePickOutcome>[];
    var closed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DriveIntentWebView(
            intentLoader: () => Future.error(StateError('no intent')),
            filePickerConfig: _config,
            onResult: results.add,
            onClose: () => closed++,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(results, hasLength(1));
    expect(results.single, isA<DrivePickOutcomeFailed>());
    expect(closed, 1);
  });

  testWidgets('the modal is still a dialog that pops the outcome', (
    tester,
  ) async {
    DrivePickOutcome? popped;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              popped = await showDialog<DrivePickOutcome>(
                context: context,
                builder: (_) => DriveIntentWebViewModal(
                  intentLoader: _pendingIntent,
                  filePickerConfig: _config,
                  imageAssets: const DriveIntentImageAssets(
                    driveLogo: 'logo.svg',
                    closeIcon: 'close.svg',
                    searchIcon: 'search.svg',
                  ),
                  iconButtonBuilder: (spec) => GestureDetector(
                    onTap: spec.onTap,
                    child: const Text('close-it'),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump();

    expect(find.byType(Dialog), findsOneWidget);
    await tester.tap(find.text('close-it').first);
    await tester.pumpAndSettle();

    expect(popped, const DrivePickOutcomeCancelled());
  });
}
