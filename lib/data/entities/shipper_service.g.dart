// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipper_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipperService _$ShipperServiceFromJson(Map<String, dynamic> json) =>
    ShipperService(
      id: json['id'] as int,
      content: json['content'] as String,
      shipperPhoneNumber: json['shipperPhoneNumber'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      beginDate:
          const TimestampConverter().fromJson(json['beginDate'] as Timestamp),
      endDate:
          const TimestampConverter().fromJson(json['endDate'] as Timestamp),
      billImageBase64: json['billImageBase64'] as String?,
    );

Map<String, dynamic> _$ShipperServiceToJson(ShipperService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'billImageBase64': instance.billImageBase64,
      'content': instance.content,
      'shipperPhoneNumber': instance.shipperPhoneNumber,
      'status': instance.status,
      'type': instance.type,
      'beginDate': const TimestampConverter().toJson(instance.beginDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
    };
