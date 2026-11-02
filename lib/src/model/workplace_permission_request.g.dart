// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_permission_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$WorkplacePermissionRuleRequestToJson(
  WorkplacePermissionRuleRequest instance,
) => <String, dynamic>{
  'type': _$WorkplaceDocTypeEnumMap[instance.type]!,
  'verbs': instance.verbs.map((e) => _$WorkplacePermissionEnumMap[e]!).toList(),
  'values': instance.values,
};

const _$WorkplaceDocTypeEnumMap = {WorkplaceDocType.files: 'io.cozy.files'};

const _$WorkplacePermissionEnumMap = {WorkplacePermission.get: 'GET'};

Map<String, dynamic> _$WorkplacePermissionSetRequestToJson(
  WorkplacePermissionSetRequest instance,
) => <String, dynamic>{'file': instance.file.toJson()};

Map<String, dynamic> _$WorkplacePermissionAttributesRequestToJson(
  WorkplacePermissionAttributesRequest instance,
) => <String, dynamic>{'permissions': instance.permissions.toJson()};

Map<String, dynamic> _$WorkplacePermissionDataRequestToJson(
  WorkplacePermissionDataRequest instance,
) => <String, dynamic>{
  'type': _$WorkplaceDataRequestTypeEnumMap[instance.type]!,
  'attributes': instance.attributes.toJson(),
};

const _$WorkplaceDataRequestTypeEnumMap = {
  WorkplaceDataRequestType.intents: 'io.cozy.intents',
  WorkplaceDataRequestType.permissions: 'io.cozy.permissions',
};

Map<String, dynamic> _$WorkplacePermissionRequestToJson(
  WorkplacePermissionRequest instance,
) => <String, dynamic>{'data': instance.data.toJson()};
