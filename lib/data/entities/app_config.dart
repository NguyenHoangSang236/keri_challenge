import 'package:json_annotation/json_annotation.dart';

part 'app_config.g.dart';

@JsonSerializable()
class AppConfig {
  String email;
  String hotline;
  String bankName;
  String bankAccount;
  String bankReceiverName;
  double pricePerKm;
  double oneDayShipperServicePrice;
  double oneMonthShipperServicePrice;
  String slogan;

  AppConfig(
    this.email,
    this.hotline,
    this.bankName,
    this.bankAccount,
    this.bankReceiverName,
    this.pricePerKm,
    this.oneDayShipperServicePrice,
    this.oneMonthShipperServicePrice,
    this.slogan,
  );

  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigToJson(this);

  @override
  String toString() {
    return '{email: $email, hotline: $hotline, bankName: $bankName, bankAccount: $bankAccount, bankReceiverName: $bankReceiverName, pricePerKm: $pricePerKm, oneDayShipperServicePrice: $oneDayShipperServicePrice, oneMonthShipperServicePrice: $oneMonthShipperServicePrice, slogan: $slogan}';
  }
}
