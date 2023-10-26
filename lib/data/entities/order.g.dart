// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      json['id'] as int,
      (json['distance'] as num).toDouble(),
      (json['price'] as num).toDouble(),
      json['fromLocation'] as String,
      json['toLocation'] as String,
      json['senderPhoneNumber'] as String,
      json['receiverPhoneNumber'] as String,
      json['receiverName'] as String,
      json['status'] as String,
      const TimestampConverter().fromJson(json['orderDate'] as Timestamp),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'distance': instance.distance,
      'price': instance.price,
      'fromLocation': instance.fromLocation,
      'toLocation': instance.toLocation,
      'senderPhoneNumber': instance.senderPhoneNumber,
      'receiverPhoneNumber': instance.receiverPhoneNumber,
      'receiverName': instance.receiverName,
      'status': instance.status,
      'orderDate': const TimestampConverter().toJson(instance.orderDate),
    };
