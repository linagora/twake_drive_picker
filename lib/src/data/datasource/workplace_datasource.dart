import 'package:twake_workplace_protocol/src/entity/workplace_intent.dart';
import 'package:twake_workplace_protocol/src/entity/workplace_intent_access_mode.dart';
import 'package:twake_workplace_protocol/src/entity/workplace_intent_config.dart';

abstract class WorkplaceDataSource {
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceIntentAccessMode accessMode,
    required WorkplaceIntentConfig config,
  });
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken);
}
