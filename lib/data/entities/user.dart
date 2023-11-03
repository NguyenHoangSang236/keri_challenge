import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:keri_challenge/core/converter/geopoint_converter.dart';
import 'package:keri_challenge/core/converter/timestamp_converter.dart';
import 'package:keri_challenge/data/enum/role_enum.dart';

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
  @GeoPointConverter()
  GeoPoint? currentLocation;
  bool isOnline;
  @TimestampConverter()
  DateTime? shipperServiceStartDate;
  @TimestampConverter()
  DateTime? shipperServiceEndDate;
  @TimestampConverter()
  DateTime registerDate;
  String role;
  String? phoneFcmToken;

  User({
    required this.fullName,
    required this.birthYear,
    required this.phoneNumber,
    required this.sex,
    required this.isOnline,
    this.distance,
    this.currentLocation,
    this.status,
    required this.role,
    required this.address,
    required this.idCertificateNumber,
    required this.password,
    required this.registerDate,
    this.shipperServiceStartDate,
    this.shipperServiceEndDate,
    this.phoneFcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  String getRole() {
    return role == RoleEnum.admin.name
        ? 'Quản trị viên'
        : role == RoleEnum.client.name
            ? 'Khách hàng'
            : role == RoleEnum.shipper.name
                ? 'Shipper'
                : 'Không xác định';
  }

  String getSex() {
    return sex == 'male'
        ? 'Nam'
        : sex == 'female'
            ? 'Nữ'
            : 'Khác';
  }

  @override
  String toString() {
    return '{phoneNumber: $phoneNumber, fullName: $fullName, birthYear: $birthYear, sex: $sex, address: $address, idCertificateNumber: $idCertificateNumber, password: $password, distance: $distance, status: $status, currentLocation: $currentLocation, isOnline: $isOnline, shipperServiceStartDate: $shipperServiceStartDate, shipperServiceEndDate: $shipperServiceEndDate, registerDate: $registerDate, role: $role, phoneFcmToken: $phoneFcmToken}';
  }
}
