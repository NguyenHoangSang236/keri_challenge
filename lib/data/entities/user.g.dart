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
      distance: (json['distance'] as num?)?.toDouble(),
      status: json['status'] as String?,
      role: json['role'] as String,
      address: json['address'] as String?,
      idCertificateNumber: json['idCertificateNumber'] as String,
      password: json['password'] as String,
      registerDate: const TimestampConverter()
          .fromJson(json['registerDate'] as Timestamp),
      phoneFcmToken: json['phoneFcmToken'] as String?,
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
      'registerDate': const TimestampConverter().toJson(instance.registerDate),
      'role': instance.role,
      'phoneFcmToken': instance.phoneFcmToken,
    };
