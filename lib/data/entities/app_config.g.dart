// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
      json['email'] as String,
      json['hotline'] as String,
      json['bankName'] as String,
      json['bankAccount'] as String,
      json['bankReceiverName'] as String,
      (json['pricePerKm'] as num).toDouble(),
      (json['oneDayShipperServicePrice'] as num).toDouble(),
      (json['oneMonthShipperServicePrice'] as num).toDouble(),
      json['slogan'] as String,
      json['websiteUrl'] as String,
    );

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'email': instance.email,
      'hotline': instance.hotline,
      'bankName': instance.bankName,
      'bankAccount': instance.bankAccount,
      'bankReceiverName': instance.bankReceiverName,
      'pricePerKm': instance.pricePerKm,
      'oneDayShipperServicePrice': instance.oneDayShipperServicePrice,
      'oneMonthShipperServicePrice': instance.oneMonthShipperServicePrice,
      'slogan': instance.slogan,
      'websiteUrl': instance.websiteUrl,
    };
