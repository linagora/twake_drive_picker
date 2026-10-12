// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_exchange_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$WorkplaceExchangeTokenRequestToJson(
  WorkplaceExchangeTokenRequest instance,
) => <String, dynamic>{
  'id_token': instance.idToken,
  'exchange_type': _$WorkplaceExchangeTypeEnumMap[instance.exchangeType]!,
};

const _$WorkplaceExchangeTypeEnumMap = {
  WorkplaceExchangeType.admin: 'admin',
  WorkplaceExchangeType.app: 'app',
};
