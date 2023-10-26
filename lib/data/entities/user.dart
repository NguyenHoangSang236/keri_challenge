import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:keri_challenge/core/converter/timestamp_converter.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'phoneNumber')
  String phoneNumber;
  String fullName;
  String birthYear;
  String sex;
  String? address;
  String idCertificateNumber;
  String password;
  double? distance;
  String? status;
  @TimestampConverter()
  DateTime registerDate;
  String role;
  String? phoneFcmToken;

  User({
    required this.fullName,
    required this.birthYear,
    required this.phoneNumber,
    required this.sex,
    this.distance,
    this.status,
    required this.role,
    required this.address,
    required this.idCertificateNumber,
    required this.password,
    required this.registerDate,
    this.phoneFcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return '{phoneNumber: $phoneNumber, fullName: $fullName, birthYear: $birthYear, sex: $sex, address: $address, idCertificateNumber: $idCertificateNumber, password: $password, distance: $distance, status: $status, registerDate: $registerDate, role: $role, phoneFcmToken: $phoneFcmToken}';
  }
}
