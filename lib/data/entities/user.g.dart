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
      address: json['address'] as String,
      idCertificateNumber: json['idCertificateNumber'] as String,
      password: json['password'] as String,
      registerDate: DateTime.parse(json['registerDate'] as String),
      phoneFcmToken: json['phoneFcmToken'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'fullName': instance.fullName,
      'birthYear': instance.birthYear,
      'phoneNumber': instance.phoneNumber,
      'sex': instance.sex,
      'address': instance.address,
      'idCertificateNumber': instance.idCertificateNumber,
      'password': instance.password,
      'registerDate': instance.registerDate.toIso8601String(),
      'phoneFcmToken': instance.phoneFcmToken,
    };
