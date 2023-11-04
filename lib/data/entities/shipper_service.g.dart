// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipper_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShipperService _$ShipperServiceFromJson(Map<String, dynamic> json) =>
    ShipperService(
      id: json['id'] as int,
      shipperName: json['shipperName'] as String,
      content: json['content'] as String,
      shipperPhoneNumber: json['shipperPhoneNumber'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      beginDate:
          const TimestampConverter().fromJson(json['beginDate'] as Timestamp),
      endDate:
          const TimestampConverter().fromJson(json['endDate'] as Timestamp),
      billImageUrl: json['billImageUrl'] as String?,
    );

Map<String, dynamic> _$ShipperServiceToJson(ShipperService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'billImageUrl': instance.billImageUrl,
      'content': instance.content,
      'shipperPhoneNumber': instance.shipperPhoneNumber,
      'status': instance.status,
      'type': instance.type,
      'shipperName': instance.shipperName,
      'beginDate': const TimestampConverter().toJson(instance.beginDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
    };
