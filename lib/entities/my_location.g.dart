// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyLocation _$MyLocationFromJson(Map<String, dynamic> json) => MyLocation(
      json['placeId'] as String,
      (json['latitude'] as num).toDouble(),
      (json['longitude'] as num).toDouble(),
      json['description'] as String,
      json['distance'] as String,
    );

Map<String, dynamic> _$MyLocationToJson(MyLocation instance) =>
    <String, dynamic>{
      'placeId': instance.placeId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'distance': instance.distance,
    };
