import 'package:flutter/material.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/data/entities/order.dart';

class OrderInfo extends StatefulWidget {
  const OrderInfo({super.key, required this.order});

  final Order order;

  @override
  State<StatefulWidget> createState() => _OrderInfoState();
}

class _OrderInfoState extends State<OrderInfo> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _orderInfoData(
            'Điểm đi',
            widget.order.fromLocation,
          ),
          _orderInfoData(
            'Điểm đến',
            widget.order.toLocation,
          ),
          _orderInfoData(
            'Thời gian đặt',
            widget.order.orderDate.dateTime,
          ),
          _orderInfoData(
            'Người nhận',
            widget.order.receiverName,
          ),
          _orderInfoData(
            'Số điện thoại người nhận',
            widget.order.receiverPhoneNumber,
          ),
          _orderInfoData(
            'COD',
            widget.order.cod,
          ),
          _orderInfoData(
            'Tên kiện hàng',
            widget.order.packageName,
          ),
          widget.order.noteForShipper != null &&
                  widget.order.noteForShipper!.isNotEmpty
              ? _orderInfoData(
                  'Ghi chú cho shipper',
                  widget.order.noteForShipper!,
                )
              : const SizedBox(),
          widget.order.shipDate != null
              ? _orderInfoData(
                  'Thời gian hoàn thành giao',
                  widget.order.shipDate!.dateTime,
                )
              : const SizedBox(),
          _orderInfoData(
            'Trạng thái',
            widget.order.getShippingStatus(),
          ),
        ],
      ),
    );
  }

  Widget _orderInfoData(String title, String data) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.height),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$title: ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextSpan(
              text: data,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onError,
              ),
            )
          ],
        ),
      ),
    );
  }
}
