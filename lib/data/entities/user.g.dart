// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      fullName: json['fullName'] as String,
      birthYear: json['birthYear'] as String,
      phoneNumber: json['phoneNumber'] as String,
      sex: json['sex'] as String,
      isOnline: json['isOnline'] as bool,
      distance: (json['distance'] as num?)?.toDouble(),
      currentLocation: _$JsonConverterFromJson<GeoPoint, GeoPoint>(
          json['currentLocation'], const GeoPointConverter().fromJson),
      status: json['status'] as String?,
      role: json['role'] as String,
      address: json['address'] as String?,
      idCertificateNumber: json['idCertificateNumber'] as String,
      password: json['password'] as String,
      registerDate: const TimestampConverter()
          .fromJson(json['registerDate'] as Timestamp),
      shipperServiceStartDate: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['shipperServiceStartDate'], const TimestampConverter().fromJson),
      shipperServiceEndDate: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['shipperServiceEndDate'], const TimestampConverter().fromJson),
      phoneFcmToken: json['phoneFcmToken'] as String?,
      shipperWorkingStatus: json['shipperWorkingStatus'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'phoneNumber': instance.phoneNumber,
      'fullName': instance.fullName,
      'birthYear': instance.birthYear,
      'sex': instance.sex,
      'address': instance.address,
      'idCertificateNumber': instance.idCertificateNumber,
      'password': instance.password,
      'distance': instance.distance,
      'status': instance.status,
      'currentLocation': _$JsonConverterToJson<GeoPoint, GeoPoint>(
          instance.currentLocation, const GeoPointConverter().toJson),
      'isOnline': instance.isOnline,
      'shipperServiceStartDate': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.shipperServiceStartDate, const TimestampConverter().toJson),
      'shipperServiceEndDate': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.shipperServiceEndDate, const TimestampConverter().toJson),
      'registerDate': const TimestampConverter().toJson(instance.registerDate),
      'role': instance.role,
      'phoneFcmToken': instance.phoneFcmToken,
      'shipperWorkingStatus': instance.shipperWorkingStatus,
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
