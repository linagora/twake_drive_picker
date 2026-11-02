import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:twake_drive_picker/src/model/workplace_exchange_token_response.dart';
import '../../model/workplace_exchange_token_request.dart';
import '../datasource/workplace_datasource.dart';
import '../../model/workplace_enums.dart';
import '../../model/workplace_intent_request.dart';
import '../../model/workplace_intent_response.dart';
import '../workplace_config.dart';
import 'workplace_request_executor.dart';
import '../../entity/workplace_intent.dart';
import '../../entity/workplace_access_mode.dart';
import '../../entity/workplace_intent_config.dart';

class WorkplaceDataSourceImpl implements WorkplaceDataSource {
  /// [config] (Dio, https policy) is shared with the default executor; pass
  /// the same config to a custom [executor] to share it too.
  WorkplaceDataSourceImpl({
    WorkplaceRequestExecutor? executor,
    WorkplaceConfig? config,
  }) : this._(executor, config ?? WorkplaceConfig());

  WorkplaceDataSourceImpl._(WorkplaceRequestExecutor? executor, this._config)
    : _executor = executor ?? WorkplaceRequestExecutor(config: _config);

  final WorkplaceRequestExecutor _executor;
  final WorkplaceConfig _config;

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data) as Map<String, dynamic>;
    throw FormatException(
      'Expected JSON object or string, got: ${data.runtimeType}',
    );
  }

  @override
  Future<WorkplaceIntent> createIntent({
    required Uri platformUrl,
    required WorkplaceAccessMode accessMode,
    required WorkplaceIntentConfig config,
  }) async {
    final data = await _executor.send(
      context: WorkplaceRequestContext(
        platformUrl: platformUrl,
        accessMode: accessMode,
      ),
      route: const WorkplaceRequestRoute(
        method: 'POST',
        pathSegments: ['intents'],
      ),
      body: WorkplaceRequestBody(data: _buildIntentRequest(config)),
    );
    return parseIntentResponse(data);
  }

  WorkplaceIntent parseIntentResponse(dynamic data, {bool? requireHttps}) {
    final parsed = WorkplaceIntentResponse.fromJson(_asJsonMap(data));
    final services = parsed.data.attributes.services;
    if (services.isEmpty) {
      throw StateError('Drive response contains no services');
    }

    final href = services.first.href;
    final intentUrl = Uri.parse(href);
    if ((requireHttps ?? _config.requireHttps) && intentUrl.scheme != 'https') {
      throw ArgumentError('Intent URL must use HTTPS, got: $href');
    }

    return WorkplaceIntent(
      intentId: parsed.data.id,
      intentUrl: intentUrl,
      client: parsed.data.attributes.client,
    );
  }

  Map<String, dynamic> _buildIntentRequest(WorkplaceIntentConfig config) =>
      WorkplaceIntentRequest(
        data: WorkplaceIntentDataRequest(
          type: WorkplaceDataRequestType.intents,
          attributes: WorkplaceIntentAttributesRequest(
            action: WorkplaceAction.pick,
            type: WorkplaceDocType.files,
            permissions: [WorkplacePermission.get],
            data: WorkplaceFilePickerConfigRequest(
              sharingLink: WorkplaceActionConfigRequest.fromEntity(
                config.addAsLink,
              ),
              downloadLink: config.addAsAttachment == null
                  ? null
                  : WorkplaceActionConfigRequest.fromEntity(
                      config.addAsAttachment!,
                    ),
              theme: WorkplaceThemeConfigRequest.fromEntity(config.theme),
            ),
          ),
        ),
      ).toJson();

  @override
  Future<String> exchangeToken(Uri platformUrl, String oidcIdToken) async {
    final response = await _config.dio.post(
      platformUrl
          .replace(
            pathSegments: [
              ...platformUrl.pathSegments.where(
                (segment) => segment.isNotEmpty,
              ),
              'auth',
              'token_exchange',
            ],
          )
          .toString(),
      options: Options(headers: {'Accept': 'application/json'}),
      data: WorkplaceExchangeTokenRequest(
        idToken: oidcIdToken,
        exchangeType: WorkplaceExchangeType.app,
      ).toJson(),
    );
    final data = WorkplaceExchangeTokenResponse.fromJson(
      _asJsonMap(response.data),
    );
    final accessToken = data.accessToken;
    return accessToken;
  }
}
