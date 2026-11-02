// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_permission_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkplaceShortcodesResponse _$WorkplaceShortcodesResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceShortcodesResponse(code: json['code'] as String?);

WorkplacePermissionAttributesResponse
_$WorkplacePermissionAttributesResponseFromJson(Map<String, dynamic> json) =>
    WorkplacePermissionAttributesResponse(
      shortcodes: json['shortcodes'] == null
          ? null
          : WorkplaceShortcodesResponse.fromJson(
              json['shortcodes'] as Map<String, dynamic>,
            ),
    );

WorkplacePermissionDataResponse _$WorkplacePermissionDataResponseFromJson(
  Map<String, dynamic> json,
) => WorkplacePermissionDataResponse(
  id: json['id'] as String?,
  attributes: WorkplacePermissionAttributesResponse.fromJson(
    json['attributes'] as Map<String, dynamic>,
  ),
);

WorkplacePermissionResponse _$WorkplacePermissionResponseFromJson(
  Map<String, dynamic> json,
) => WorkplacePermissionResponse(
  data: WorkplacePermissionDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);
