import 'package:auto_route/annotations.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/view/components/layout.dart';

@RoutePage()
class ShipperServiceManagementScreen extends StatefulWidget {
  const ShipperServiceManagementScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ShipperServiceManagementScreenState();
}

class _ShipperServiceManagementScreenState
    extends State<ShipperServiceManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Quản lí gói dịch vụ',
      canComeBack: false,
      body: Container(),
    );
  }
}
