import 'package:flutter/material.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';

import '../../data/entities/order.dart';

class WaitingOrderListComponent extends StatefulWidget {
  const WaitingOrderListComponent({super.key, required this.order});

  final Order order;

  @override
  State<StatefulWidget> createState() => _WaitingOrderListComponentState();
}

class _WaitingOrderListComponentState extends State<WaitingOrderListComponent> {
  bool _isSelected = false;

  void _onSelectOrder(Order order) {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  void _acceptOrder(Order order) {}

  void _refuseOrder(Order order) {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onSelectOrder(widget.order),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.order.packageName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'SĐT người gửi: ${widget.order.senderPhoneNumber}',
              maxLines: 2,
              softWrap: true,
            ),
            trailing: Text('${widget.order.distance.format}km'),
          ),
          AnimatedContainer(
            height: _isSelected ? 70.height : 0,
            width: MediaQuery.of(context).size.width,
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GradientElevatedButton(
                  text: 'Nhận đơn',
                  buttonWidth: 150.width,
                  buttonHeight: 40.height,
                  buttonMargin: EdgeInsets.zero,
                  onPress: () => _acceptOrder(widget.order),
                ),
                GradientElevatedButton(
                  text: 'Từ chối',
                  buttonWidth: 150.width,
                  buttonHeight: 40.height,
                  buttonMargin: EdgeInsets.zero,
                  endColor: Theme.of(context).colorScheme.error,
                  beginColor: Theme.of(context).colorScheme.error,
                  onPress: () => _refuseOrder(widget.order),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
