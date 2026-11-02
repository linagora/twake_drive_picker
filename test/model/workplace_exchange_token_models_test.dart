import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/model/workplace_enums.dart';
import 'package:twake_drive_picker/src/model/workplace_exchange_token_request.dart';
import 'package:twake_drive_picker/src/model/workplace_exchange_token_response.dart';

void main() {
  group('WorkplaceExchangeTokenRequest', () {
    test('serializes with snake_case keys', () {
      const request = WorkplaceExchangeTokenRequest(
        idToken: 'oidc-token',
        exchangeType: WorkplaceExchangeType.app,
      );

      expect(request.toJson(), {
        'id_token': 'oidc-token',
        'exchange_type': 'app',
      });
    });

    test('serializes the admin exchange type', () {
      const request = WorkplaceExchangeTokenRequest(
        idToken: 't',
        exchangeType: WorkplaceExchangeType.admin,
      );

      expect(request.toJson()['exchange_type'], 'admin');
    });
  });

  group('WorkplaceExchangeTokenResponse', () {
    test('parses every field from snake_case keys', () {
      final response = WorkplaceExchangeTokenResponse.fromJson({
        'access_token': 'access',
        'client_id': 'cid',
        'client_secret': 'secret',
        'refresh_token': 'refresh',
        'registration_access_token': 'reg',
        'scope': 'io.cozy.files',
        'token_type': 'bearer',
      });

      expect(response.accessToken, 'access');
      expect(response.clientId, 'cid');
      expect(response.clientSecret, 'secret');
      expect(response.refreshToken, 'refresh');
      expect(response.registrationAccessToken, 'reg');
      expect(response.scope, 'io.cozy.files');
      expect(response.tokenType, 'bearer');
    });

    test('only the access token is required', () {
      final response = WorkplaceExchangeTokenResponse.fromJson({
        'access_token': 'access',
      });

      expect(response.accessToken, 'access');
      expect(response.clientId, isNull);
      expect(response.refreshToken, isNull);
      expect(response.tokenType, isNull);
    });

    test('a response without access token is rejected', () {
      expect(
        () => WorkplaceExchangeTokenResponse.fromJson({'token_type': 'bearer'}),
        throwsA(anything),
      );
    });

    test('compares by value', () {
      final json = {'access_token': 'a', 'scope': 's'};

      expect(
        WorkplaceExchangeTokenResponse.fromJson(json),
        WorkplaceExchangeTokenResponse.fromJson(json),
      );
    });
  });
}
