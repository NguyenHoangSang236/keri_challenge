// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as int,
      distance: (json['distance'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      fromLocation: json['fromLocation'] as String,
      toLocation: json['toLocation'] as String,
      senderPhoneNumber: json['senderPhoneNumber'] as String,
      receiverPhoneNumber: json['receiverPhoneNumber'] as String,
      receiverName: json['receiverName'] as String,
      status: json['status'] as String,
      packageName: json['packageName'] as String,
      cod: json['cod'] as String,
      fromLocationGeoPoint: const GeoPointConverter()
          .fromJson(json['fromLocationGeoPoint'] as GeoPoint),
      toLocationGeoPoint: const GeoPointConverter()
          .fromJson(json['toLocationGeoPoint'] as GeoPoint),
      noteForShipper: json['noteForShipper'] as String?,
      shipperOrderId: json['shipperOrderId'] as int?,
      shipperPhoneNumber: json['shipperPhoneNumber'] as String?,
      shipDate: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['shipDate'], const TimestampConverter().fromJson),
      orderDate:
          const TimestampConverter().fromJson(json['orderDate'] as Timestamp),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'shipperOrderId': instance.shipperOrderId,
      'distance': instance.distance,
      'price': instance.price,
      'fromLocation': instance.fromLocation,
      'toLocation': instance.toLocation,
      'senderPhoneNumber': instance.senderPhoneNumber,
      'receiverPhoneNumber': instance.receiverPhoneNumber,
      'receiverName': instance.receiverName,
      'status': instance.status,
      'packageName': instance.packageName,
      'cod': instance.cod,
      'noteForShipper': instance.noteForShipper,
      'shipperPhoneNumber': instance.shipperPhoneNumber,
      'fromLocationGeoPoint':
          const GeoPointConverter().toJson(instance.fromLocationGeoPoint),
      'toLocationGeoPoint':
          const GeoPointConverter().toJson(instance.toLocationGeoPoint),
      'shipDate': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.shipDate, const TimestampConverter().toJson),
      'orderDate': const TimestampConverter().toJson(instance.orderDate),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
