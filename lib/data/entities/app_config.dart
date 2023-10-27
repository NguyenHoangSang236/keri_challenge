import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig {
  String email;
  String hotline;
  double pricePerKm;
  String slogan;

  AppConfig(this.email, this.hotline, this.pricePerKm, this.slogan);

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  @override
  String toString() {
    return '{email: $email, hotline: $hotline, pricePerKm: $pricePerKm, slogan: $slogan}';
  }
}
