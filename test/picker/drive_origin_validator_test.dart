import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/twake_drive_picker.dart';

const _origin = 'https://drive.example.com';
const _otherOrigin = 'https://evil.example.com';
const _client = 'client-xyz';

void main() {
  group('WebDriveOriginValidator', () {
    const validator = WebDriveOriginValidator();

    test('null origin → false', () {
      expect(
        validator.isValid(null, intentOrigin: _origin, intentClient: null),
        isFalse,
      );
    });

    test('origin matches intentOrigin → true', () {
      expect(
        validator.isValid(_origin, intentOrigin: _origin, intentClient: null),
        isTrue,
      );
    });

    test('mismatched origin → false', () {
      expect(
        validator.isValid(
          _otherOrigin,
          intentOrigin: _origin,
          intentClient: null,
        ),
        isFalse,
      );
    });

    test(
      'origin matches intentClient but not intentOrigin → false (web ignores client)',
      () {
        expect(
          validator.isValid(
            _client,
            intentOrigin: _origin,
            intentClient: _client,
          ),
          isFalse,
        );
      },
    );

    test('data: URI intent (intentOrigin "null") rejects "*"', () {
      expect(
        validator.isValid('*', intentOrigin: 'null', intentClient: null),
        isFalse,
      );
    });

    test('opaque "null" origin never matches, even against "null"', () {
      expect(
        validator.isValid('null', intentOrigin: 'null', intentClient: null),
        isFalse,
      );
    });

    test('"*" rejected for an https intent', () {
      expect(
        validator.isValid('*', intentOrigin: _origin, intentClient: null),
        isFalse,
      );
    });
  });

  group('MobileDriveOriginValidator', () {
    const validator = MobileDriveOriginValidator();

    test('null origin → false', () {
      expect(
        validator.isValid(null, intentOrigin: _origin, intentClient: _client),
        isFalse,
      );
    });

    test('origin matches intentOrigin → true', () {
      expect(
        validator.isValid(
          _origin,
          intentOrigin: _origin,
          intentClient: _client,
        ),
        isTrue,
      );
    });

    test('origin matches intentClient (not intentOrigin) → false', () {
      expect(
        validator.isValid(
          _client,
          intentOrigin: _origin,
          intentClient: _client,
        ),
        isFalse,
      );
    });

    test('origin matches neither intentOrigin nor intentClient → false', () {
      expect(
        validator.isValid(
          _otherOrigin,
          intentOrigin: _origin,
          intentClient: _client,
        ),
        isFalse,
      );
    });

    test('intentClient null → client branch never matches', () {
      expect(
        validator.isValid(
          _otherOrigin,
          intentOrigin: _origin,
          intentClient: null,
        ),
        isFalse,
      );
    });

    test('data: URI intent (intentOrigin "null") rejects "*"', () {
      expect(
        validator.isValid('*', intentOrigin: 'null', intentClient: null),
        isFalse,
      );
    });

    test(
      'wildcard intentClient does not match wildcard origin on HTTPS intent → false',
      () {
        expect(
          validator.isValid('*', intentOrigin: _origin, intentClient: '*'),
          isFalse,
        );
      },
    );

    test('blank/whitespace intentClient never matches → false', () {
      expect(
        validator.isValid('   ', intentOrigin: _origin, intentClient: '   '),
        isFalse,
      );
    });
  });

  group('tryGetUriOrigin', () {
    test('returns scheme, host and port of an http(s) url', () {
      expect(
        tryGetUriOrigin(Uri.parse('https://drive.example.com:8443/pick?a=1')),
        'https://drive.example.com:8443',
      );
    });

    test('returns null instead of throwing for urls without an origin', () {
      expect(tryGetUriOrigin(Uri.parse('data:text/html,hi')), isNull);
      expect(tryGetUriOrigin(Uri.parse('file:///etc/hosts')), isNull);
      expect(tryGetUriOrigin(Uri.parse('/relative/path')), isNull);
      expect(tryGetUriOrigin(Uri.parse('https:///no-host')), isNull);
    });
  });

  group('isValidDriveClient', () {
    test('null → false', () {
      expect(isValidDriveClient(null), isFalse);
    });

    test('empty string → false', () {
      expect(isValidDriveClient(''), isFalse);
    });

    test('whitespace-only → false', () {
      expect(isValidDriveClient('   '), isFalse);
    });

    test('wildcard "*" → false', () {
      expect(isValidDriveClient('*'), isFalse);
    });

    test('valid client id → true', () {
      expect(isValidDriveClient(_client), isTrue);
    });
  });
}
