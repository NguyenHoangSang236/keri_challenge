import 'package:json_annotation/json_annotation.dart';
import 'package:keri_challenge/entities/searched_route.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String name;
  String password;
  String phoneNumber;
  String? fcmToken;

  User(
    this.name,
    this.phoneNumber,
    this.password,
    this.fcmToken,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return '{name: $name, password: $password, phoneNumber: $phoneNumber, fcmToken: $fcmToken}';
  }
}
