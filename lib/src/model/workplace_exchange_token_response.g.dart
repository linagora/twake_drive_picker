// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workplace_exchange_token_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkplaceExchangeTokenResponse _$WorkplaceExchangeTokenResponseFromJson(
  Map<String, dynamic> json,
) => WorkplaceExchangeTokenResponse(
  accessToken: json['access_token'] as String,
  clientId: json['client_id'] as String?,
  clientSecret: json['client_secret'] as String?,
  refreshToken: json['refresh_token'] as String?,
  registrationAccessToken: json['registration_access_token'] as String?,
  scope: json['scope'] as String?,
  tokenType: json['token_type'] as String?,
);
