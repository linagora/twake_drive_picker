import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/domain/state/workplace_intent_state.dart';
import 'package:twake_drive_picker/src/domain/state/workplace_state.dart';
import 'package:twake_drive_picker/src/domain/usecase/exchange_drive_token_interactor.dart';

import '../../test_utils/fake_workplace_repository.dart';

void main() {
  final platformUrl = Uri.parse('https://platform.example.com');
  late FakeWorkplaceRepository repository;
  late ExchangeDriveTokenInteractor interactor;

  setUp(() {
    repository = FakeWorkplaceRepository();
    interactor = ExchangeDriveTokenInteractor(repository);
  });

  Future<List<Either<Failure, Success>>> run() =>
      interactor.execute(platformUrl, 'oidc-token').toList();

  test('emits Exchanging then Success with the access token', () async {
    repository.onExchangeToken = () async => 'access-token';

    final states = await run();

    expect(states, [
      Right(ExchangingWorkplaceToken()),
      const Right(ExchangeWorkplaceTokenSuccess('access-token')),
    ]);
  });

  test('forwards the platform url and the OIDC token', () async {
    repository.onExchangeToken = () async => 'access-token';

    await run();

    expect(repository.lastPlatformUrl, platformUrl);
    expect(repository.lastOidcIdToken, 'oidc-token');
  });

  test('emits Exchanging then a Failure carrying the thrown error', () async {
    final error = StateError('401');
    repository.onExchangeToken = () async => throw error;

    final states = await run();

    expect(states, hasLength(2));
    expect(states.first, Right(ExchangingWorkplaceToken()));
    final failure = states.last.fold((f) => f, (_) => null);
    expect(failure, isA<ExchangeWorkplaceTokenFailure>());
    expect((failure! as ExchangeWorkplaceTokenFailure).exception, same(error));
  });
}
