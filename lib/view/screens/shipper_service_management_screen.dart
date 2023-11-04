import 'package:auto_route/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';
import 'package:keri_challenge/data/enum/firestore_enum.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/components/layout.dart';
import 'package:keri_challenge/view/components/shipper_service_list_compoment.dart';

import '../../bloc/shipper_service/shipper_service_bloc.dart';
import '../../main.dart';
import '../components/gradient_button.dart';

@RoutePage()
class ShipperServiceManagementScreen extends StatefulWidget {
  const ShipperServiceManagementScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ShipperServiceManagementScreenState();
}

class _ShipperServiceManagementScreenState
    extends State<ShipperServiceManagementScreen> {
  final TextEditingController _textController = TextEditingController();

  Stream<QuerySnapshot> _shipperServiceStream = fireStore
      .collection(FireStoreCollectionEnum.shipperService.name)
      .orderBy('beginDate', descending: true)
      .limit(10)
      .snapshots();

  void _increaseLimit() {
    setState(() {
      int limit = int.parse(_textController.text);
      limit++;
      _textController.text = limit.toString();

      _shipperServiceStream = fireStore
          .collection(FireStoreCollectionEnum.shipperService.name)
          .orderBy('beginDate', descending: true)
          .limit(limit)
          .snapshots();
    });
  }

  void _decreaseLimit() {
    setState(() {
      int limit = int.parse(_textController.text);
      limit--;
      _textController.text = limit.toString();

      _shipperServiceStream = fireStore
          .collection(FireStoreCollectionEnum.shipperService.name)
          .orderBy('beginDate', descending: true)
          .limit(limit)
          .snapshots();
    });
  }

  void _onChangeLimit(String value) {
    setState(() {
      if (value.isNotEmpty) {
        int limit = int.parse(value);

        if (limit > 0) {
          _textController.text = limit.toString();

          _shipperServiceStream = fireStore
              .collection(FireStoreCollectionEnum.shipperService.name)
              .orderBy('beginDate', descending: true)
              .limit(limit)
              .snapshots();
        }
      }
    });
  }

  @override
  void initState() {
    _textController.text = '10';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Quản lí gói dịch vụ',
      canComeBack: false,
      body: SingleChildScrollView(
        child: BlocListener<ShipperServiceBloc, ShipperServiceState>(
          listener: (context, state) {
            if (state is ShipperServiceErrorState) {
              UiRender.showDialog(context, '', state.message);
            } else if (state is ShipperServiceAcceptedState) {
              UiRender.showDialog(context, '', state.message);
            } else if (state is ShipperServiceRejectedState) {
              UiRender.showDialog(context, '', state.message);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Row(
                  children: [
                    15.horizontalSpace,
                    const Text('Xem '),
                    GradientElevatedButton(
                      text: '-',
                      buttonHeight: 30.size,
                      textSize: 18.size,
                      buttonWidth: 30.size,
                      buttonMargin: EdgeInsets.zero,
                      onPress: _decreaseLimit,
                    ),
                    Flexible(
                      child: SizedBox(
                        width: 60.width,
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: _textController,
                          showCursor: false,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: _onChangeLimit,
                        ),
                      ),
                    ),
                    GradientElevatedButton(
                      text: '+',
                      textSize: 18.size,
                      buttonHeight: 30.size,
                      buttonWidth: 30.size,
                      buttonMargin: EdgeInsets.zero,
                      onPress: _increaseLimit,
                    ),
                    5.horizontalSpace,
                    const Text('dòng'),
                  ],
                ),
              ),
              20.verticalSpace,
              Flexible(
                child: Text(
                  'Nhấn vào đơn hàng để xem các hành động',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: StreamBuilder(
                  stream: _shipperServiceStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Xảy ra lỗi');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Đang tải");
                    }

                    return ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return ShipperServiceListComponent(
                              shipperService: ShipperService.fromJson(data),
                            );
                          })
                          .toList()
                          .cast(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
