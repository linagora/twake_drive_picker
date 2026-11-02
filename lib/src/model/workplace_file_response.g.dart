// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_file_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkplaceFileAttributesResponse _$WorkplaceFileAttributesResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceFileAttributesResponse(name: json['name'] as String?);

WorkplaceFileDataResponse _$WorkplaceFileDataResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceFileDataResponse(
  id: json['id'] as String,
  attributes: json['attributes'] == null
      ? null
      : WorkplaceFileAttributesResponse.fromJson(
          json['attributes'] as Map<String, dynamic>,
        ),
);

WorkplaceFileResponse _$WorkplaceFileResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceFileResponse(
  data: WorkplaceFileDataResponse.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);
