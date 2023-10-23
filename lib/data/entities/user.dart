import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String fullName;
  String birthYear;
  String phoneNumber;
  String sex;
  String address;
  String idCertificateNumber;
  String password;
  DateTime registerDate;
  String? phoneFcmToken;

  User({
    required this.fullName,
    required this.birthYear,
    required this.phoneNumber,
    required this.sex,
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
    return '{fullName: $fullName, birthYear: $birthYear, phoneNumber: $phoneNumber, sex: $sex, address: $address, idCertificateNumber: $idCertificateNumber, password: $password, registerDate: $registerDate, phoneFcmToken: $phoneFcmToken}';
  }
}
