import 'package:twake_workplace_protocol/src/data/datasource/workplace_datasource.dart';
import 'package:twake_workplace_protocol/src/entity/workplace_intent.dart';
import 'package:twake_workplace_protocol/src/entity/workplace_intent_access_mode.dart';
import 'package:twake_workplace_protocol/src/entity/workplace_intent_config.dart';
import 'package:twake_workplace_protocol/src/domain/repository/workplace_repository.dart';

class WorkplaceRepositoryImpl implements WorkplaceRepository {
  final WorkplaceDataSource _dataSource;

  WorkplaceRepositoryImpl(this._dataSource);

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceIntentAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) => _dataSource.createIntent(
    platformUrl: platformUrl,
    accessMode: accessMode,
    config: config,
  );

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) =>
      _dataSource.exchangeToken(platformUrl, oidcIdToken);
}
