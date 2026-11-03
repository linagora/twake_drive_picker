import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twake_drive_picker/src/domain/state/workplace_intent_state.dart';
import 'package:twake_drive_picker/src/domain/state/workplace_state.dart';
import 'package:twake_drive_picker/src/domain/usecase/create_drive_intent_interactor.dart';
import 'package:twake_drive_picker/src/entity/workplace_access_mode.dart';
import 'package:twake_drive_picker/src/entity/workplace_action_config.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent.dart';
import 'package:twake_drive_picker/src/entity/workplace_intent_config.dart';
import 'package:twake_drive_picker/src/entity/workplace_theme.dart';

import '../../test_utils/fake_workplace_repository.dart';

void main() {
  final platformUrl = Uri.parse('https://platform.example.com');
  const config = WorkplaceIntentConfig(
    addAsLink: WorkplaceActionConfig(label: 'Link'),
    theme: WorkplaceTheme.light,
  );
  final intent = WorkplaceIntent(
    intentId: 'intent-1',
    intentUrl: _url,
    client: 'client-1',
  );
  late FakeWorkplaceRepository repository;
  late CreateDriveIntentInteractor interactor;

  setUp(() {
    repository = FakeWorkplaceRepository();
    interactor = CreateDriveIntentInteractor(repository);
  });

  Future<List<Either<Failure, Success>>> run() => interactor
      .execute(platformUrl, const BridgeAccessMode(), config: config)
      .toList();

  test('emits Creating then Success with the intent', () async {
    repository.onCreateIntent = () async => intent;

    final states = await run();

    expect(states, [
      Right(CreatingWorkplaceIntent()),
      Right(CreateWorkplaceIntentSuccess(intent)),
    ]);
  });

  test('forwards the platform url, access mode and config', () async {
    repository.onCreateIntent = () async => intent;
    const accessMode = BearerTokenAccessMode('token');

    await interactor.execute(platformUrl, accessMode, config: config).toList();

    expect(repository.lastPlatformUrl, platformUrl);
    expect(repository.lastAccessMode, same(accessMode));
    expect(repository.lastConfig, config);
  });

  test('emits Creating then a Failure carrying the thrown error', () async {
    final error = StateError('boom');
    repository.onCreateIntent = () async => throw error;

    final states = await run();

    expect(states, hasLength(2));
    expect(states.first, Right(CreatingWorkplaceIntent()));
    final failure = states.last.fold((f) => f, (_) => null);
    expect(failure, isA<CreateWorkplaceIntentFailure>());
    expect((failure! as CreateWorkplaceIntentFailure).exception, same(error));
  });

  test('a synchronous throw from the repository is a Failure too', () async {
    repository.onCreateIntent = () => throw ArgumentError('sync');

    final states = await run();

    expect(states.last.isLeft(), isTrue);
  });
}

final _url = Uri.parse('https://drive.example.com/pick');
