import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/domain/exceptions/workplace_exceptions.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/logging/workplace_logger.dart';
import 'package:twake_drive_picker/src/picker/drive_origin_validator.dart';
import 'package:twake_drive_picker/src/picker/drive_pick_outcome.dart';
import 'package:twake_drive_picker/src/presentation/mixin/drive_intent_message_handler_mixin.dart';

class _RecordingLogger implements WorkplaceLogger {
  final lines = <String>[];

  @override
  void log(String message) => lines.add(message);

  @override
  void error(String message, {Object? exception, StackTrace? stackTrace}) =>
      lines.add('$message ${exception ?? ''}');
}

class _Harness extends StatefulWidget {
  const _Harness(this.logger);

  final WorkplaceLogger logger;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness>
    with DriveIntentMessageHandlerMixin {
  final outcomes = <DrivePickOutcome>[];
  var acks = 0;
  var loads = 0;

  @override
  WorkplaceLogger get workplaceLogger => widget.logger;

  @override
  DriveOriginValidator get originValidator => const WebDriveOriginValidator();

  @override
  Future<void> sendAck() async => acks++;

  @override
  Future<void> loadIntent(WorkplaceIntent intent) async => loads++;

  @override
  void onFinished(DrivePickOutcome outcome) => outcomes.add(outcome);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

const _intentId = 'intent-1';
const _origin = 'https://drive.example.com';

Future<_HarnessState> _open(
  WidgetTester tester, {
  required WorkplaceLogger logger,
  String url = '$_origin/pick',
}) async {
  await tester.pumpWidget(MaterialApp(home: _Harness(logger)));
  final state = tester.state<_HarnessState>(find.byType(_Harness));
  state.startLoading(
    () async => WorkplaceIntent(
      intentId: _intentId,
      intentUrl: Uri.parse(url),
      client: null,
    ),
  );
  await tester.pump();
  state.notifyPlatformViewReady();
  await tester.pump();
  return state;
}

String _done(List<Object?> documents) =>
    jsonEncode({'type': 'intent-$_intentId:done', 'document': documents});

void main() {
  late _RecordingLogger logger;
  late WorkplaceLogger previousActiveLogger;

  setUp(() {
    logger = _RecordingLogger();
    previousActiveLogger = activeWorkplaceLogger;
    activeWorkplaceLogger = logger;
  });

  tearDown(() => activeWorkplaceLogger = previousActiveLogger);

  group('intent url without an origin', () {
    for (final url in [
      'data:text/html,hi',
      'file:///etc/hosts',
      '/relative/path',
      'https:///no-host',
    ]) {
      testWidgets('$url fails fast instead of timing out', (tester) async {
        final state = await _open(tester, logger: logger, url: url);

        expect(state.outcomes, hasLength(1));
        final outcome = state.outcomes.single as DrivePickOutcomeFailed;
        expect(outcome.error, isA<DriveIntentPageLoadException>());
        expect(state.loads, 0);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('all documents dropped', () {
    testWidgets('a done whose documents are all rejected is a failure', (
      tester,
    ) async {
      final state = await _open(tester, logger: logger);

      state.onMessage(
        raw: _done([
          {'id': 'a', 'name': 'a.pdf', 'size': -1, 'mimeType': 'x/y'},
          {'id': 'b', 'name': 'b.pdf', 'size': 'not a number'},
        ]),
        origin: _origin,
      );
      await tester.pump();

      expect(state.outcomes.single, isA<DrivePickOutcomeFailed>());
      expect(
        (state.outcomes.single as DrivePickOutcomeFailed).error,
        isA<DriveIntentNoValidDocumentException>(),
      );
    });

    testWidgets('a done with no document at all is a cancel', (tester) async {
      final state = await _open(tester, logger: logger);

      state.onMessage(raw: _done([]), origin: _origin);
      await tester.pump();

      expect(state.outcomes.single, isA<DrivePickOutcomeCancelled>());
    });

    testWidgets('one valid document among rejected ones is still picked', (
      tester,
    ) async {
      final state = await _open(tester, logger: logger);

      state.onMessage(
        raw: _done([
          {'id': 'bad', 'name': 'bad.pdf', 'size': -1, 'mimeType': 'x/y'},
          {'id': 'ok', 'name': 'ok.pdf', 'size': 5, 'mimeType': 'x/y'},
        ]),
        origin: _origin,
      );
      await tester.pump();

      final picked = state.outcomes.single as DrivePickOutcomePicked;
      expect(picked.documents.map((d) => d.id), ['ok']);
    });
  });

  group('logs', () {
    testWidgets('never contain the content of an unparseable message', (
      tester,
    ) async {
      final state = await _open(tester, logger: logger);

      state.onMessage(raw: 'SECRET-PAYLOAD-123 {not json', origin: _origin);

      expect(logger.lines, isNotEmpty);
      expect(logger.lines.join('\n'), isNot(contains('SECRET-PAYLOAD-123')));
      state.cancelReadyTimeoutForTesting();
    });

    testWidgets('never contain document ids, names or sizes', (tester) async {
      final state = await _open(tester, logger: logger);

      state.onMessage(
        raw: _done([
          {
            'id': 'DOC-ID-777',
            'name': 'payroll-SECRET.xlsx',
            'size': 424242,
            'mimeType': 'application/vnd.ms-excel',
          },
          {
            'id': 'BAD-ID-888',
            'name': 'leaked-name.pdf',
            'size': -9,
            'mimeType': 'x/y',
          },
          {
            'id': 'LINK-ID-999',
            'name': 'link-name.pdf',
            'size': 1,
            'mimeType': 'x/y',
            'sharingLink': 'javascript:alert(1)',
          },
        ]),
        origin: _origin,
      );
      await tester.pump();

      final logged = logger.lines.join('\n');
      for (final secret in [
        'DOC-ID-777',
        'payroll-SECRET',
        '424242',
        'BAD-ID-888',
        'leaked-name',
        'LINK-ID-999',
        'link-name',
      ]) {
        expect(logged, isNot(contains(secret)), reason: secret);
      }
      expect(state.outcomes.single, isA<DrivePickOutcomePicked>());
    });

    testWidgets('never contain the type of an unknown message', (tester) async {
      final state = await _open(tester, logger: logger);

      state.onMessage(
        raw: jsonEncode({'type': 'intent-$_intentId:SECRET-TYPE'}),
        origin: _origin,
      );

      expect(logger.lines.join('\n'), isNot(contains('SECRET-TYPE')));
      state.cancelReadyTimeoutForTesting();
    });
  });
}
