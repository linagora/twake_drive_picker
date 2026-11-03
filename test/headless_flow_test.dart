import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
// Core only: this flow must work without any widget library.
import 'package:twake_drive_picker/core.dart';

import 'test_utils/fake_workplace_repository.dart';

const _origin = 'https://drive.example.com';
final _intent = WorkplaceIntent(
  intentId: 'i-1',
  intentUrl: Uri.parse('$_origin/pick'),
  client: _origin,
);

String _msg(String type, [Map<String, dynamic> extra = const {}]) =>
    jsonEncode({'type': 'intent-i-1:$type', ...extra});

DrivePickOutcome? _outcome(String raw) =>
    drivePickOutcomeOfMessage(WorkplaceIntentMessage.parse('i-1', raw));

void main() {
  group('headless flow', () {
    test('exchanges the OIDC token, then creates the intent with it', () async {
      final repository = FakeWorkplaceRepository()
        ..onExchangeToken = (() async => 'drive-access-token')
        ..onCreateIntent = (() async => _intent);
      final runner = WorkplaceAccessModeRunner(
        exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
        oidcTokenGetter: () => 'oidc-id-token',
        oidcRefreshTrigger: () async => null,
        isBridgeAvailable: () => false,
      );
      final platformUrl = Uri.https('workplace.example.com');
      const config = WorkplaceIntentConfig(
        addAsLink: WorkplaceActionConfig(label: 'Link'),
        theme: WorkplaceTheme.light,
        multiple: false,
      );

      final intent = await runner.run(
        platformUrl,
        CreateDriveIntentCall(
          CreateDriveIntentInteractor(repository),
          platformUrl,
          config,
        ),
      );

      expect(intent, _intent);
      expect(repository.lastOidcIdToken, 'oidc-id-token');
      expect(
        repository.lastAccessMode,
        isA<BearerTokenAccessMode>().having(
          (m) => m.accessToken,
          'accessToken',
          'drive-access-token',
        ),
      );
      expect(repository.lastConfig, config);
    });

    test('a signed-out app fails instead of calling Drive', () async {
      final repository = FakeWorkplaceRepository();
      final runner = WorkplaceAccessModeRunner(
        exchangeTokenInteractor: ExchangeDriveTokenInteractor(repository),
        oidcTokenGetter: () => null,
        oidcRefreshTrigger: () async => null,
        isBridgeAvailable: () => false,
      );
      final platformUrl = Uri.https('workplace.example.com');

      expect(
        runner.run(
          platformUrl,
          CreateDriveIntentCall(
            CreateDriveIntentInteractor(repository),
            platformUrl,
            const WorkplaceIntentConfig(
              addAsLink: WorkplaceActionConfig(label: 'Link'),
              theme: WorkplaceTheme.light,
            ),
          ),
        ),
        throwsStateError,
      );
    });

    test('done with a document is a pick', () {
      final outcome = _outcome(
        _msg('done', {
          'document': [
            {
              'id': 'd1',
              'name': 'a.pdf',
              'size': 3,
              'mimeType': 'application/pdf',
              'sharingLink': 'https://drive.example.com/public?sharecode=x',
            },
          ],
        }),
      );

      expect(outcome, isA<DrivePickOutcomePicked>());
      expect((outcome as DrivePickOutcomePicked).documents.single.id, 'd1');
    });

    test('done with nothing is a cancel; all rejected is a failure', () {
      expect(
        _outcome(_msg('done', {'document': []})),
        const DrivePickOutcomeCancelled(),
      );
      expect(
        _outcome(
          _msg('done', {
            'document': [
              {'id': 'bad'},
            ],
          }),
        ),
        isA<DrivePickOutcomeFailed>(),
      );
    });

    test('cancel and error end the pick; the handshake does not', () {
      expect(_outcome(_msg('cancel')), const DrivePickOutcomeCancelled());
      expect(_outcome(_msg('error')), isA<DrivePickOutcomeFailed>());
      expect(_outcome(_msg('ready')), isNull);
      expect(_outcome(_msg('readyToUse')), isNull);
    });
  });
}
