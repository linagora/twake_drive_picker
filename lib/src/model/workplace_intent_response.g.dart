// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_intent_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkplaceIntentAttributesResponse _$WorkplaceIntentAttributesResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceIntentAttributesResponse(
  action: $enumDecode(_$WorkplaceActionEnumMap, json['action']),
  type: json['type'] as String,
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => $enumDecode(_$WorkplacePermissionEnumMap, e))
      .toList(),
  services: (json['services'] as List<dynamic>)
      .map(
        (e) =>
            WorkplaceIntentServiceResponse.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  client: json['client'] as String?,
  availableApps: (json['availableApps'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

const _$WorkplaceActionEnumMap = {WorkplaceAction.pick: 'PICK'};

const _$WorkplacePermissionEnumMap = {WorkplacePermission.get: 'GET'};

WorkplaceIntentServiceResponse _$WorkplaceIntentServiceResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceIntentServiceResponse(href: json['href'] as String);

WorkplaceIntentMetaResponse _$WorkplaceIntentMetaResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceIntentMetaResponse(rev: json['rev'] as String?);

WorkplaceIntentLinksResponse _$WorkplaceIntentLinksResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceIntentLinksResponse(
  self: json['self'] as String?,
  permissions: json['permissions'] as String?,
);

WorkplaceIntentDataResponse _$WorkplaceIntentDataResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceIntentDataResponse(
  id: json['id'] as String,
  type: json['type'] as String?,
  attributes: WorkplaceIntentAttributesResponse.fromJson(
    json['attributes'] as Map<String, dynamic>,
  ),
  meta: json['meta'] == null
      ? null
      : WorkplaceIntentMetaResponse.fromJson(
          json['meta'] as Map<String, dynamic>,
        ),
  links: json['links'] == null
      ? null
      : WorkplaceIntentLinksResponse.fromJson(
          json['links'] as Map<String, dynamic>,
        ),
);

WorkplaceIntentResponse _$WorkplaceIntentResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceIntentResponse(
  data: WorkplaceIntentDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);
