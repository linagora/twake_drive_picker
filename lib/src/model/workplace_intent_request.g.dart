// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_intent_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$WorkplaceActionConfigRequestToJson(
  WorkplaceActionConfigRequest instance,
) => <String, dynamic>{
  'label': ?instance.label,
  'maxFileSize': ?instance.maxFileSize,
  'availableSize': ?instance.availableSize,
};

Map<String, dynamic> _$WorkplaceThemeConfigRequestToJson(
  WorkplaceThemeConfigRequest instance,
) => <String, dynamic>{'type': _$WorkplaceThemeTypeEnumMap[instance.type]!};

const _$WorkplaceThemeTypeEnumMap = {
  WorkplaceThemeType.light: 'light',
  WorkplaceThemeType.dark: 'dark',
};

Map<String, dynamic> _$WorkplaceFilePickerConfigRequestToJson(
  WorkplaceFilePickerConfigRequest instance,
) => <String, dynamic>{
  'sharingLink': instance.sharingLink.toJson(),
  'downloadLink': instance.downloadLink?.toJson(),
  'theme': instance.theme.toJson(),
};

Map<String, dynamic> _$WorkplaceIntentAttributesRequestToJson(
  WorkplaceIntentAttributesRequest instance,
) => <String, dynamic>{
  'action': _$WorkplaceActionEnumMap[instance.action]!,
  'type': _$WorkplaceDocTypeEnumMap[instance.type]!,
  'permissions': instance.permissions
      .map((e) => _$WorkplacePermissionEnumMap[e]!)
      .toList(),
  'data': instance.data.toJson(),
};

const _$WorkplaceActionEnumMap = {WorkplaceAction.pick: 'PICK'};

const _$WorkplaceDocTypeEnumMap = {WorkplaceDocType.files: 'io.cozy.files'};

const _$WorkplacePermissionEnumMap = {WorkplacePermission.get: 'GET'};

Map<String, dynamic> _$WorkplaceIntentDataRequestToJson(
  WorkplaceIntentDataRequest instance,
) => <String, dynamic>{
  'type': _$WorkplaceDataRequestTypeEnumMap[instance.type]!,
  'attributes': instance.attributes.toJson(),
};

const _$WorkplaceDataRequestTypeEnumMap = {
  WorkplaceDataRequestType.intents: 'io.cozy.intents',
  WorkplaceDataRequestType.permissions: 'io.cozy.permissions',
};

Map<String, dynamic> _$WorkplaceIntentRequestToJson(
  WorkplaceIntentRequest instance,
) => <String, dynamic>{'data': instance.data.toJson()};
