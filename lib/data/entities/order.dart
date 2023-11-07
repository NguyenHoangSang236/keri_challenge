import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../core/converter/geopoint_converter.dart';
import '../../core/converter/timestamp_converter.dart';
import '../enum/shipper_enum.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  @JsonKey(name: 'id')
  int id;
  int? shipperOrderId;
  double distance;
  double price;
  String fromLocation;
  String toLocation;
  String senderPhoneNumber;
  String receiverPhoneNumber;
  String receiverName;
  String status;
  String packageName;
  String cod;
  String? noteForShipper;
  String? shipperPhoneNumber;
  @GeoPointConverter()
  GeoPoint fromLocationGeoPoint;
  @GeoPointConverter()
  GeoPoint toLocationGeoPoint;
  @TimestampConverter()
  DateTime? shipDate;
  @TimestampConverter()
  DateTime orderDate;

  Order({
    required this.id,
    required this.distance,
    required this.price,
    required this.fromLocation,
    required this.toLocation,
    required this.senderPhoneNumber,
    required this.receiverPhoneNumber,
    required this.receiverName,
    required this.status,
    required this.packageName,
    required this.cod,
    required this.fromLocationGeoPoint,
    required this.toLocationGeoPoint,
    this.noteForShipper,
    this.shipperOrderId,
    this.shipperPhoneNumber,
    this.shipDate,
    required this.orderDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // String showFullInfo() {
  //   return 'ID: $id \nKhoảng cách: ${distance.format}km \nGiá tiền: ${price.format} đồng \nĐiểm đi: $fromLocation \n Số điện thoại shipper: ${shipperPhoneNumber == null || shipperPhoneNumber!.isEmpty ? 'Chưa xác định' : shipperPhoneNumber} \nĐiểm đến: $toLocation \nSố điện thoại người gửi: $senderPhoneNumber \nSố điện thoại người nhận: $receiverPhoneNumber \nTên người nhận: $receiverName \nTrạng thái: ${status == ShipperEnum.shipping.name ? 'Đang giao' : status == ShipperEnum.shipped.name ? 'Đã giao' : status == ShipperEnum.shipper_waiting.name ? 'Đợi shipper' : 'Không xác định'} \nNgày đặt hàng: ${orderDate.date} \nNgày giao hàng: ${shipDate ?? 'Chưa xác định'} \nGhi chú cho shipper: $noteForShipper \nTên kiện hàng: $packageName \nCod: $cod';
  // }

  String getOrderDoc() {
    return '$senderPhoneNumber-$id';
  }

  String getShippingStatus() {
    return status == ShipperEnum.shipping.name
        ? 'Đang giao'
        : status == ShipperEnum.shipped.name
            ? 'Đã giao'
            : status == ShipperEnum.shipper_waiting.name
                ? 'Đợi shipper'
                : 'Không xác định';
  }

  @override
  String toString() {
    return '{id: $id, shipperOrderId: $shipperOrderId, distance: $distance, price: $price, fromLocation: $fromLocation, toLocation: $toLocation, senderPhoneNumber: $senderPhoneNumber, receiverPhoneNumber: $receiverPhoneNumber, receiverName: $receiverName, status: $status, packageName: $packageName, cod: $cod, noteForShipper: $noteForShipper, shipperPhoneNumber: $shipperPhoneNumber, fromLocationGeoPoint: $fromLocationGeoPoint, toLocationGeoPoint: $toLocationGeoPoint, shipDate: $shipDate, orderDate: $orderDate}';
  }
}
