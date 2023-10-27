// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
      json['email'] as String,
      json['hotline'] as String,
      (json['pricePerKm'] as num).toDouble(),
      json['slogan'] as String,
    );

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'email': instance.email,
      'hotline': instance.hotline,
      'pricePerKm': instance.pricePerKm,
      'slogan': instance.slogan,
    };
