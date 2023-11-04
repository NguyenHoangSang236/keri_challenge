import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/data/enum/firestore_enum.dart';
import 'package:keri_challenge/main.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:keri_challenge/view/components/layout.dart';
import 'package:keri_challenge/view/components/shipper_list_component.dart';

import '../../bloc/order/order_bloc.dart';
import '../../data/entities/user.dart';

@RoutePage()
class OnlineShipperScreen extends StatefulWidget {
  const OnlineShipperScreen({super.key});

  @override
  State<StatefulWidget> createState() => _OnlineShipperScreenState();
}

class _OnlineShipperScreenState extends State<OnlineShipperScreen> {
  final TextEditingController _textController = TextEditingController();

  Stream<QuerySnapshot> _usersStream = fireStore
      .collection(FireStoreCollectionEnum.users.name)
      .where('role', isEqualTo: 'shipper')
      .where('isOnline', isEqualTo: true)
      .where(
        'shipperServiceEndDate',
        isNull: false,
        isGreaterThan: Timestamp.fromDate(DateTime.now()),
      )
      .limit(10)
      .snapshots();

  void _increaseLimit() {
    setState(() {
      int limit = int.parse(_textController.text);
      limit++;
      _textController.text = limit.toString();

      _usersStream = fireStore
          .collection(FireStoreCollectionEnum.users.name)
          .where('role', isEqualTo: 'shipper')
          .where('isOnline', isEqualTo: true)
          .where(
            'shipperServiceEndDate',
            isNull: false,
            isGreaterThan: Timestamp.fromDate(DateTime.now()),
          )
          .limit(limit)
          .snapshots();
    });
  }

  void _decreaseLimit() {
    setState(() {
      int limit = int.parse(_textController.text);

      if (limit > 1) {
        limit--;
        _textController.text = limit.toString();

        _usersStream = fireStore
            .collection(FireStoreCollectionEnum.users.name)
            .where('role', isEqualTo: 'shipper')
            .where('isOnline', isEqualTo: true)
            .where(
              'shipperServiceEndDate',
              isNull: false,
              isGreaterThan: Timestamp.fromDate(DateTime.now()),
            )
            .limit(limit)
            .snapshots();
      }
    });
  }

  void _onChangeLimit(String value) {
    setState(() {
      if (value.isNotEmpty) {
        int limit = int.parse(value);

        if (limit > 0) {
          _textController.text = limit.toString();

          _usersStream = fireStore
              .collection(FireStoreCollectionEnum.users.name)
              .where('role', isEqualTo: 'shipper')
              .where('isOnline', isEqualTo: true)
              .where(
                'shipperServiceEndDate',
                isNull: false,
                isGreaterThan: Timestamp.fromDate(DateTime.now()),
              )
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
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Shipper đang hoạt động',
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderErrorState) {
            UiRender.showDialog(context, '', state.message);
          } else if (state is OrderForwardedState) {
            UiRender.showDialog(context, '', state.message)
                .then((value) => context.router.pop());
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 15.height,
            horizontal: 10.width,
          ),
          child: Column(
            children: [
              Row(
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
              20.verticalSpace,
              Text(
                'Nhấn vào shipper bạn muốn đặt để xem các hành động',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              20.verticalSpace,
              StreamBuilder(
                stream: _usersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Xảy ra lỗi');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Đang tải");
                  }

                  return SizedBox(
                    height: 500.height,
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;
                            return ShipperListComponent(
                              shipper: User.fromJson(data),
                            );
                          })
                          .toList()
                          .cast(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
