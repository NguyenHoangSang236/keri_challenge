import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/converter/timestamp_converter.dart';

part 'shipper_service.g.dart';

@JsonSerializable()
class ShipperService {
  @JsonKey(name: 'id')
  int id;
  String? billImageBase64;
  String content;
  String shipperPhoneNumber;
  String status;
  String type;
  @TimestampConverter()
  DateTime beginDate;
  @TimestampConverter()
  DateTime endDate;

  ShipperService({
    required this.id,
    required this.content,
    required this.shipperPhoneNumber,
    required this.status,
    required this.type,
    required this.beginDate,
    required this.endDate,
    this.billImageBase64,
  });

  factory ShipperService.fromJson(Map<String, dynamic> json) =>
      _$ShipperServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ShipperServiceToJson(this);

  String getShipperServiceDoc() {
    return '$shipperPhoneNumber-$id';
  }

  @override
  String toString() {
    return '{id: $id, billImageBase64: $billImageBase64, content: $content, shipperPhoneNumber: $shipperPhoneNumber, status: $status, type: $type, beginDate: $beginDate, endDate: $endDate}';
  }
}
