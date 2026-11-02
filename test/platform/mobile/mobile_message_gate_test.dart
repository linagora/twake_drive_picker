import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/picker/drive_origin_validator.dart';
import 'package:twake_drive_picker/src/platform/mobile/drive_intent_shims.dart';
import 'package:twake_drive_picker/src/platform/mobile/mobile_message_gate.dart';

const _intentOrigin = 'https://drive.example.com';
final _ready = jsonEncode({'type': 'intent-i1:ready'});

class _Received {
  _Received(this.raw, this.origin);

  final String raw;
  final String? origin;
}

void main() {
  late List<_Received> received;

  MobileMessageGate gateAt(Uri? url) => MobileMessageGate(
    currentUrl: () async => url,
    onMessage: ({required raw, required origin}) =>
        received.add(_Received(raw, origin)),
  );

  setUp(() => received = []);

  group('MobileMessageGate', () {
    test('hands on the origin of the native main-frame URL', () async {
      await gateAt(Uri.parse('$_intentOrigin/pick?x=1')).handle([_ready]);

      expect(received.single.raw, _ready);
      expect(received.single.origin, _intentOrigin);
    });

    test(
      'ignores the origin the page claims in the handler arguments',
      () async {
        // A page on evil.example claims to be the Drive origin.
        await gateAt(
          Uri.parse('https://evil.example.com/'),
        ).handle([_ready, _intentOrigin]);

        expect(received.single.origin, 'https://evil.example.com');
        expect(
          const MobileDriveOriginValidator().isValid(
            received.single.origin,
            intentOrigin: _intentOrigin,
            intentClient: null,
          ),
          isFalse,
        );
      },
    );

    test('a claimed "*" or client id is never taken as the origin', () async {
      await gateAt(Uri.parse('$_intentOrigin/')).handle([_ready, '*']);
      await gateAt(Uri.parse('$_intentOrigin/')).handle([_ready, 'client-1']);

      expect(received.map((r) => r.origin), [_intentOrigin, _intentOrigin]);
    });

    test('passes a null origin when the WebView has no URL', () async {
      await gateAt(null).handle([_ready]);

      expect(received.single.origin, isNull);
    });

    test('passes a null origin for a URL that has none', () async {
      await gateAt(Uri.parse('data:text/html,hi')).handle([_ready]);

      expect(received.single.origin, isNull);
    });

    test('drops calls without a String payload', () async {
      final gate = gateAt(Uri.parse('$_intentOrigin/'));

      await gate.handle([]);
      await gate.handle([42]);
      await gate.handle([null, _intentOrigin]);
      await gate.handle([
        {'type': 'x'},
      ]);

      expect(received, isEmpty);
    });
  });

  group('isNavigationToIntentOriginAllowed', () {
    bool allowed(String? url) => isNavigationToIntentOriginAllowed(
      url == null ? null : Uri.parse(url),
      intentOrigin: _intentOrigin,
    );

    test('allows pages of the intent origin', () {
      expect(allowed('$_intentOrigin/pick'), isTrue);
      expect(allowed('$_intentOrigin/other/path?q=1#frag'), isTrue);
    });

    test('allows about:blank', () {
      expect(allowed('about:blank'), isTrue);
    });

    test('blocks other hosts, ports and schemes', () {
      expect(allowed('https://evil.example.com/'), isFalse);
      expect(allowed('https://drive.example.com.evil.com/'), isFalse);
      expect(allowed('https://drive.example.com:8443/'), isFalse);
      expect(allowed('http://drive.example.com/'), isFalse);
    });

    test('blocks non-web schemes', () {
      expect(allowed('data:text/html,<script>1</script>'), isFalse);
      expect(allowed('file:///etc/hosts'), isFalse);
      expect(allowed('javascript:alert(1)'), isFalse);
      expect(allowed('intent://scan/#Intent;scheme=zxing;end'), isFalse);
    });

    test('blocks a missing url and an unknown intent origin', () {
      expect(allowed(null), isFalse);
      expect(
        isNavigationToIntentOriginAllowed(
          Uri.parse(_intentOrigin),
          intentOrigin: '',
        ),
        isFalse,
      );
    });
  });

  group('DriveIntentShims', () {
    final shim = DriveIntentShims.parentPostMessageShim;

    test('only runs in the top frame', () {
      expect(shim, contains('window.self !== window.top'));
    });

    test('forwards the payload and never the page-chosen targetOrigin', () {
      expect(shim, contains(DriveIntentShims.handlerName));
      expect(shim, isNot(contains('targetOrigin')));
    });
  });
}
