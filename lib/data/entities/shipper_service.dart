import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/converter/timestamp_converter.dart';
import '../enum/shipper_service_enum.dart';

part 'shipper_service.g.dart';

@JsonSerializable()
class ShipperService {
  @JsonKey(name: 'id')
  int id;
  String? billImageUrl;
  String content;
  String shipperPhoneNumber;
  String status;
  String type;
  String shipperName;
  @TimestampConverter()
  DateTime beginDate;
  @TimestampConverter()
  DateTime endDate;

  ShipperService({
    required this.id,
    required this.shipperName,
    required this.content,
    required this.shipperPhoneNumber,
    required this.status,
    required this.type,
    required this.beginDate,
    required this.endDate,
    this.billImageUrl,
  });

  factory ShipperService.fromJson(Map<String, dynamic> json) =>
      _$ShipperServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ShipperServiceToJson(this);

  String getShipperServiceDoc() {
    return '$shipperPhoneNumber-$id';
  }

  String getServiceType() {
    return type == ShipperServiceEnum.month.name
        ? 'Gói tháng'
        : type == ShipperServiceEnum.day.name
            ? 'Gói ngày'
            : 'Không xác định';
  }

  String getShipperServiceStatus() {
    return status == ShipperServiceEnum.waiting.name
        ? 'Đang chờ xác nhận'
        : status == ShipperServiceEnum.accepted.name
            ? 'Đã chấp nhận'
            : status == ShipperServiceEnum.expired.name
                ? 'Đã hết hạn'
                : status == ShipperServiceEnum.rejected.name
                    ? 'Đã từ chối'
                    : 'Không xác định';
  }

  @override
  String toString() {
    return '{id: $id, billImageUrl: $billImageUrl, content: $content, shipperPhoneNumber: $shipperPhoneNumber, status: $status, type: $type, shipperName: $shipperName, beginDate: $beginDate, endDate: $endDate}';
  }
}
