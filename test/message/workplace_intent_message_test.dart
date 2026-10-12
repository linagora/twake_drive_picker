import 'dart:convert';

import 'package:test/test.dart';
import 'package:twake_workplace_protocol/twake_workplace_protocol.dart';

WorkplaceIntentDoneMessage _parseDone(
  String intentId,
  List<Object?> docs, {
  bool allowInsecureLinks = false,
  OnDocumentSkipped? onSkipped,
}) {
  final raw = jsonEncode({'type': 'intent-$intentId:done', 'document': docs});
  return WorkplaceIntentMessage.parse(
        intentId,
        raw,
        allowInsecureLinks: allowInsecureLinks,
        onSkipped: onSkipped,
      )
      as WorkplaceIntentDoneMessage;
}

/// A valid document; entries of [overrides] replace it, a `null` value drops
/// the key.
Map<String, dynamic> _doc([Map<String, Object?> overrides = const {}]) {
  final doc = <String, Object?>{
    'id': 'd1',
    'name': 'a.pdf',
    'size': 10,
    'mimeType': 'application/pdf',
    'sharingLink': 'https://drive.example/s/1',
    ...overrides,
  };
  return {
    for (final e in doc.entries)
      if (e.value != null) e.key: e.value,
  };
}

void main() {
  const intentId = 'abc123';

  String encode(Map<String, dynamic> map) => jsonEncode(map);

  group('parseWorkplaceIntentMessage', () {
    test('ready type returns WorkplaceIntentReadyMessage', () {
      final raw = encode({'type': 'intent-$intentId:ready'});
      expect(
        WorkplaceIntentMessage.parse(intentId, raw),
        isA<WorkplaceIntentReadyMessage>(),
      );
    });

    test('readyToUse type returns WorkplaceIntentReadyToUseMessage', () {
      final raw = encode({'type': 'intent-$intentId:readyToUse'});
      expect(
        WorkplaceIntentMessage.parse(intentId, raw),
        isA<WorkplaceIntentReadyToUseMessage>(),
      );
    });

    test('error type returns WorkplaceIntentErrorMessage', () {
      final raw = encode({'type': 'intent-$intentId:error'});
      expect(
        WorkplaceIntentMessage.parse(intentId, raw),
        isA<WorkplaceIntentErrorMessage>(),
      );
    });

    test('cancel type returns WorkplaceIntentCancelMessage', () {
      final raw = encode({'type': 'intent-$intentId:cancel'});
      expect(
        WorkplaceIntentMessage.parse(intentId, raw),
        isA<WorkplaceIntentCancelMessage>(),
      );
    });

    group('done type', () {
      test('returns WorkplaceIntentDoneMessage with parsed documents', () {
        final done = _parseDone(intentId, [
          {
            'id': 'doc1',
            'name': 'report.pdf',
            'size': 1024,
            'mimeType': 'application/pdf',
            'sharingLink': 'https://sharing.example.com/file',
            'downloadLink': 'https://download.example.com/file',
          },
        ]);
        expect(done.documents.length, 1);
        expect(done.documents.first.id, 'doc1');
        expect(done.documents.first.name, 'report.pdf');
        expect(done.documents.first.size, 1024);
        expect(done.documents.first.mimeType, 'application/pdf');
        expect(
          done.documents.first.sharingLink,
          Uri.parse('https://sharing.example.com/file'),
        );
        expect(
          done.documents.first.downloadLink,
          Uri.parse('https://download.example.com/file'),
        );
      });

      test('returns empty list when document key is absent', () {
        final msg =
            WorkplaceIntentMessage.parse(
                  intentId,
                  encode({'type': 'intent-$intentId:done'}),
                )
                as WorkplaceIntentDoneMessage;
        expect(msg.documents, isEmpty);
      });

      test('returns empty list when document is null', () {
        final msg =
            WorkplaceIntentMessage.parse(
                  intentId,
                  encode({'type': 'intent-$intentId:done', 'document': null}),
                )
                as WorkplaceIntentDoneMessage;
        expect(msg.documents, isEmpty);
      });

      test('parses multiple documents', () {
        final done = _parseDone(intentId, [
          _doc({'id': 'd1', 'name': 'a.pdf', 'size': 100}),
          _doc({'id': 'd2', 'name': 'b.png', 'size': 200}),
        ]);
        expect(done.documents.length, 2);
        expect(
          done.documents.map((d) => d.id),
          containsAllInOrder(['d1', 'd2']),
        );
      });
    });

    group('unknown type', () {
      test(
        'unrecognised type string returns WorkplaceIntentUnknownMessage',
        () {
          final raw = encode({'type': 'some-other-event'});
          final msg = WorkplaceIntentMessage.parse(intentId, raw);
          expect(msg, isA<WorkplaceIntentUnknownMessage>());
          expect(
            (msg as WorkplaceIntentUnknownMessage).type,
            'some-other-event',
          );
        },
      );

      test(
        'missing type field defaults to empty string → WorkplaceIntentUnknownMessage',
        () {
          final raw = encode(<String, dynamic>{});
          final msg = WorkplaceIntentMessage.parse(intentId, raw);
          expect(msg, isA<WorkplaceIntentUnknownMessage>());
          expect((msg as WorkplaceIntentUnknownMessage).type, '');
        },
      );

      test(
        'correct message type for different intentId is treated as unknown',
        () {
          final raw = encode({'type': 'intent-other-id:ready'});
          final msg = WorkplaceIntentMessage.parse(intentId, raw);
          expect(msg, isA<WorkplaceIntentUnknownMessage>());
        },
      );

      // Multiple colons in type — only exact suffix match counts
      test('type with multiple colons is unknown', () {
        final raw = encode({'type': 'intent-$intentId:ready:extra'});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      // Multiple "intent-" prefixes
      test('type prefixed twice is unknown', () {
        final raw = encode({'type': 'intent-intent-$intentId:ready'});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      // intentId repeated in type
      test('type with intentId repeated is unknown', () {
        final raw = encode({'type': 'intent-$intentId$intentId:ready'});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      // Suffix of intentId matches another intentId
      test('type matching suffix of intentId is unknown', () {
        // intentId = 'abc123'; 'bc123' is a suffix — must not match
        final raw = encode({'type': 'intent-bc123:ready'});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      // Upper-cased known action is unknown (case-sensitive)
      test('type with uppercase action is unknown', () {
        final raw = encode({'type': 'intent-$intentId:READY'});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      // Empty intentId passed to parse — only matches if message also has empty segment
      test('empty intentId only matches type with empty segment', () {
        final raw = encode({'type': 'intent-:ready'});
        expect(
          WorkplaceIntentMessage.parse('', raw),
          isA<WorkplaceIntentReadyMessage>(),
        );
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      // type value is not a string — impl uses `as String?` hard cast → throws TypeError
      test('non-string type field is an unknown message', () {
        final raw = encode({'type': 1});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      test('payload that is not a JSON object throws FormatException', () {
        expect(
          () => WorkplaceIntentMessage.parse(intentId, '[]'),
          throwsFormatException,
        );
      });

      // Whitespace around known type
      test('type with leading whitespace is unknown', () {
        final raw = encode({'type': ' intent-$intentId:ready'});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });

      test('type with trailing whitespace is unknown', () {
        final raw = encode({'type': 'intent-$intentId:ready '});
        expect(
          WorkplaceIntentMessage.parse(intentId, raw),
          isA<WorkplaceIntentUnknownMessage>(),
        );
      });
    });

    group('all known actions for arbitrary intentId', () {
      const otherId = 'xyz-999';

      for (final entry in {
        'ready': WorkplaceIntentReadyMessage,
        'readyToUse': WorkplaceIntentReadyToUseMessage,
        'error': WorkplaceIntentErrorMessage,
        'cancel': WorkplaceIntentCancelMessage,
      }.entries) {
        test(
          '${entry.key} action resolves correctly for intentId=$otherId',
          () {
            final raw = encode({'type': 'intent-$otherId:${entry.key}'});
            final msg = WorkplaceIntentMessage.parse(otherId, raw);
            expect(msg, isA<WorkplaceIntentMessage>());
            expect(msg.runtimeType, entry.value);
          },
        );
      }

      test('done action resolves correctly for intentId=$otherId', () {
        final raw = encode({'type': 'intent-$otherId:done', 'document': []});
        final msg = WorkplaceIntentMessage.parse(otherId, raw);
        expect(msg, isA<WorkplaceIntentDoneMessage>());
        expect((msg as WorkplaceIntentDoneMessage).documents, isEmpty);
      });
    });

    group('done — entries kept', () {
      test('with only a sharing link', () {
        final done = _parseDone(intentId, [_doc()]);
        expect(done.documents.single.sharingLink, isNotNull);
        expect(done.documents.single.downloadLink, isNull);
      });

      test('with only a download link', () {
        final done = _parseDone(intentId, [
          _doc({
            'sharingLink': null,
            'downloadLink': 'https://drive.example/d/1',
          }),
        ]);
        expect(done.documents.single.downloadLink, isNotNull);
      });

      test('with size zero and no mimeType', () {
        final done = _parseDone(intentId, [
          _doc({'size': 0, 'mimeType': null}),
        ]);
        expect(done.documents.single.size, 0);
        expect(done.documents.single.mimeType, isNull);
      });

      test('in order, many of them', () {
        final done = _parseDone(intentId, [
          for (var i = 0; i < 10; i++) _doc({'id': 'doc$i'}),
        ]);
        expect(done.documents.map((d) => d.id), [
          for (var i = 0; i < 10; i++) 'doc$i',
        ]);
      });

      test('around a malformed one', () {
        final raw = jsonEncode({
          'type': 'intent-$intentId:done',
          'document': [
            _doc({'id': 'good'}),
            'not-an-object',
            _doc({'id': 'ok'}),
          ],
        });
        final done =
            WorkplaceIntentMessage.parse(intentId, raw)
                as WorkplaceIntentDoneMessage;
        expect(done.documents.map((d) => d.id), ['good', 'ok']);
      });
    });

    group('done — entries dropped', () {
      final cases = <String, Map<String, dynamic>>{
        'blank id': _doc({'id': ' '}),
        'blank name': _doc({'name': ''}),
        'missing id': _doc({'id': null}),
        'missing name': _doc({'name': null}),
        'missing size': _doc({'size': null}),
        'negative size': _doc({'size': -1}),
        'no link': _doc({'sharingLink': null}),
        'http sharing link': _doc({'sharingLink': 'http://drive.example/s/1'}),
        'javascript sharing link': _doc({'sharingLink': 'javascript:alert(1)'}),
        'ftp download link': _doc({'downloadLink': 'ftp://drive.example/d/1'}),
      };

      cases.forEach((name, entry) {
        test(name, () {
          final reasons = <String>[];
          final done = _parseDone(intentId, [
            entry,
            _doc({'id': 'kept'}),
          ], onSkipped: reasons.add);
          expect(done.documents.map((d) => d.id), ['kept']);
          expect(reasons, hasLength(1));
        });
      });

      test('the reason never carries a link', () {
        final reasons = <String>[];
        _parseDone(intentId, [
          _doc({'sharingLink': 'javascript:alert(1)'}),
        ], onSkipped: reasons.add);
        expect(reasons.single, isNot(contains('javascript')));
      });
    });

    group('done — insecure links', () {
      test('http is accepted when allowed', () {
        final done = _parseDone(intentId, [
          _doc({'sharingLink': 'http://localhost/s/1'}),
        ], allowInsecureLinks: true);
        expect(done.documents, hasLength(1));
      });

      test('other schemes stay rejected when http is allowed', () {
        final done = _parseDone(intentId, [
          _doc({'sharingLink': 'javascript:alert(1)'}),
        ], allowInsecureLinks: true);
        expect(done.documents, isEmpty);
      });
    });

    group('done — thumbnail', () {
      test('https thumbnail is kept', () {
        final done = _parseDone(intentId, [
          _doc({
            'thumbnail': {'link': 'https://drive.example/t.png'},
          }),
        ]);
        expect(done.documents.single.thumbnail?.link, isNotNull);
      });

      test('insecure thumbnail removes only the thumbnail', () {
        final done = _parseDone(intentId, [
          _doc({
            'thumbnail': {'link': 'http://drive.example/t.png'},
          }),
        ]);
        expect(done.documents, hasLength(1));
        expect(done.documents.single.thumbnail, isNull);
      });
    });
  });
}
