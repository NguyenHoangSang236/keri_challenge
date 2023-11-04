import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';
import 'package:keri_challenge/data/enum/shipper_service_enum.dart';

import '../../bloc/shipper_service/shipper_service_bloc.dart';
import 'gradient_button.dart';

class ShipperServiceListComponent extends StatefulWidget {
  const ShipperServiceListComponent({super.key, required this.shipperService});

  final ShipperService shipperService;

  @override
  State<StatefulWidget> createState() => _ShipperServiceListComponentState();
}

class _ShipperServiceListComponentState
    extends State<ShipperServiceListComponent> {
  bool _isSelected = false;

  void _onSelectShipperService() {
    setState(() {
      _isSelected = !_isSelected;
    });
  }

  void _seeDetails() {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Thông tin người dùng'),
          content: _shipperServiceInfo(widget.shipperService),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                context.router.pop();
              },
              isDefaultAction: true,
              child: const Text('Xác nhận'),
            )
          ],
        );
      },
    );
  }

  void _accept() {
    context.read<ShipperServiceBloc>().add(
          OnAcceptShipperServiceEvent(widget.shipperService),
        );
  }

  void _reject() {
    context.read<ShipperServiceBloc>().add(
          OnRejectShipperServiceEvent(widget.shipperService),
        );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onSelectShipperService,
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.shipperService.shipperName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.shipperService.shipperPhoneNumber),
                Text(
                  'Trạng thái: ${widget.shipperService.getShipperServiceStatus()}',
                ),
              ],
            ),
            trailing: Text(widget.shipperService.getServiceType()),
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
                  text: 'Chi tiết',
                  buttonWidth: 100.width,
                  buttonHeight: 40.height,
                  buttonMargin: EdgeInsets.zero,
                  onPress: _seeDetails,
                ),
                if (widget.shipperService.status ==
                    ShipperServiceEnum.waiting.name) ...[
                  GradientElevatedButton(
                    text: 'Chấp nhận',
                    buttonWidth: 100.width,
                    buttonHeight: 40.height,
                    buttonMargin: EdgeInsets.zero,
                    endColor: Theme.of(context).colorScheme.onTertiary,
                    beginColor: Theme.of(context).colorScheme.onTertiary,
                    onPress: _accept,
                  ),
                  GradientElevatedButton(
                    text: 'Từ chối',
                    buttonWidth: 100.width,
                    buttonHeight: 40.height,
                    buttonMargin: EdgeInsets.zero,
                    endColor: Theme.of(context).colorScheme.error,
                    beginColor: Theme.of(context).colorScheme.error,
                    onPress: _reject,
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shipperServiceInfo(ShipperService shipperService) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shipperServiceInfoData(
            'ID',
            shipperService.id.toString(),
          ),
          _shipperServiceInfoData(
            'Tên shipper',
            shipperService.shipperName,
          ),
          _shipperServiceInfoData(
            'Số điện thoại',
            shipperService.shipperPhoneNumber,
          ),
          _shipperServiceInfoData(
            'Nội dung chuyển khoản',
            shipperService.content,
          ),
          _shipperServiceInfoData(
            'Trạng thái duyệt đơn',
            shipperService.getShipperServiceStatus(),
          ),
          _shipperServiceInfoData(
            'Ngày bắt đầu',
            shipperService.beginDate.date,
          ),
          _shipperServiceInfoData(
            'Ngày kết thúc',
            shipperService.endDate.date,
          ),
          _shipperServiceInfoData('Biên lai', ''),
          Image.network(shipperService.billImageUrl ?? ''),
        ],
      ),
    );
  }

  Widget _shipperServiceInfoData(String title, String data) {
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
