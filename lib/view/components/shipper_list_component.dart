import 'package:flutter/material.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/entities/order.dart';
import '../../data/entities/user.dart';

class ShipperListComponent extends StatefulWidget {
  const ShipperListComponent({super.key, required this.shipper});

  final User shipper;

  @override
  State<StatefulWidget> createState() => _ShipperListComponentState();
}

class _ShipperListComponentState extends State<ShipperListComponent> {
  bool _isSelected = false;

  void _onSelectShipper(User shipper) {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _onPressForwardOrderButton(Order order) {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onSelectShipper(widget.shipper),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.shipper.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(widget.shipper.phoneNumber),
            trailing: Text('${widget.shipper.distance?.format}km'),
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
                  text: 'Gọi ngay',
                  buttonWidth: 150.width,
                  buttonHeight: 40.height,
                  buttonMargin: EdgeInsets.zero,
                  onPress: () => _makePhoneCall(widget.shipper.phoneNumber),
                ),
                GradientElevatedButton(
                  text: 'Chuyển đơn',
                  buttonWidth: 150.width,
                  buttonHeight: 40.height,
                  buttonMargin: EdgeInsets.zero,
                  onPress: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
