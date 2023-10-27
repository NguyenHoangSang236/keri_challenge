import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';

import '../../core/converter/timestamp_converter.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  @JsonKey(name: 'id')
  int id;
  double distance;
  double price;
  String fromLocation;
  String toLocation;
  String senderPhoneNumber;
  String receiverPhoneNumber;
  String receiverName;
  String status;
  @TimestampConverter()
  DateTime orderDate;

  Order(
    this.id,
    this.distance,
    this.price,
    this.fromLocation,
    this.toLocation,
    this.senderPhoneNumber,
    this.receiverPhoneNumber,
    this.receiverName,
    this.status,
    this.orderDate,
  );

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  String showFullInfo() {
    return 'ID: $id \nKhoảng cách: ${distance.format}km \nGiá tiền: ${price.format} đồng \nĐiểm đi: $fromLocation \nĐiểm đến: $toLocation \nSố điện thoại người gửi: $senderPhoneNumber \nSố điện thoại người nhận: $receiverPhoneNumber \nTên người nhận: $receiverName \nTrạng thái: ${status == 'shipping' ? 'Đang giao' : status == 'shipped' ? 'Đã giao' : 'Không xác định'} \nNgày đặt hàng: ${orderDate.date}';
  }

  @override
  String toString() {
    return '{id: $id, distance: $distance, price: $price, fromLocation: $fromLocation, toLocation: $toLocation, senderPhoneNumber: $senderPhoneNumber, receiverPhoneNumber: $receiverPhoneNumber, receiverName: $receiverName, status: $status, orderDate: $orderDate}';
  }
}
