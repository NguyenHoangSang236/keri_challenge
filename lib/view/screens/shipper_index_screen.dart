import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/authorization/author_bloc.dart';
import 'package:keri_challenge/bloc/order/order_bloc.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/core/extension/geopoint_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/data/enum/shipper_enum.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/util/value_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:keri_challenge/view/components/layout.dart';
import 'package:keri_challenge/view/components/waiting_order_list_component.dart';

import '../../bloc/google_map/google_map_bloc.dart';
import '../../data/entities/order.dart' as my_order;
import '../../main.dart';

@RoutePage()
class ShipperIndexScreen extends StatefulWidget {
  const ShipperIndexScreen({super.key, required this.initialTabIndex});

  final int initialTabIndex;

  @override
  State<StatefulWidget> createState() => _ShipperIndexScreenState();
}

class _ShipperIndexScreenState extends State<ShipperIndexScreen> {
  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _toLocationController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _codController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _waitingListLimitController =
      TextEditingController();
  final TextEditingController _historyListLimitController =
      TextEditingController();

  Stream<QuerySnapshot> _waitingOrdersStream = fireStore
      .collection('orders')
      .where('status', isEqualTo: ShipperEnum.shipper_waiting.name)
      .where(
        'shipperPhoneNumber',
        isEqualTo: ValueRender.currentUser!.phoneNumber,
      )
      .limit(10)
      .snapshots();

  void _increaseHistoryListLimit() {
    setState(() {
      int limit = int.parse(_historyListLimitController.text);
      limit++;
      _historyListLimitController.text = limit.toString();

      context.read<OrderBloc>().add(OnLoadShipperHistoryOrderList(
            context.read<AuthorBloc>().currentUser!.phoneNumber,
            limit,
            1,
          ));
    });
  }

  void _decreaseHistoryListLimit() {
    setState(() {
      int limit = int.parse(_historyListLimitController.text);

      if (limit > 1) {
        limit--;
        _historyListLimitController.text = limit.toString();

        context.read<OrderBloc>().add(OnLoadShipperHistoryOrderList(
              context.read<AuthorBloc>().currentUser!.phoneNumber,
              limit,
              1,
            ));
      }
    });
  }

  void _increaseWaitingListLimit() {
    setState(() {
      int limit = int.parse(_waitingListLimitController.text);
      limit++;
      _waitingListLimitController.text = limit.toString();

      _waitingOrdersStream = fireStore
          .collection('orders')
          .where('status', isEqualTo: ShipperEnum.shipper_waiting.name)
          .where(
            'shipperPhoneNumber',
            isEqualTo: context.read<AuthorBloc>().currentUser!.phoneNumber,
          )
          .limit(limit)
          .snapshots();
    });
  }

  void _decreaseWaitingListLimit() {
    setState(() {
      int limit = int.parse(_waitingListLimitController.text);

      if (limit > 1) {
        limit--;
        _waitingListLimitController.text = limit.toString();

        _waitingOrdersStream = fireStore
            .collection('orders')
            .where('status', isEqualTo: ShipperEnum.shipper_waiting.name)
            .where(
              'shipperPhoneNumber',
              isEqualTo: context.read<AuthorBloc>().currentUser!.phoneNumber,
            )
            .limit(limit)
            .snapshots();
      }
    });
  }

  void _showOrderInfo(my_order.Order order) {
    UiRender.showDialog(
      context,
      'Thông tin đơn hàng',
      order.showFullInfo(),
      textAlign: TextAlign.start,
    );
  }

  void _changeWaitingOrderListLimit(String value) {
    setState(() {
      if (value.isNotEmpty) {
        int limit = int.parse(value);

        if (limit > 0) {
          _waitingListLimitController.text = limit.toString();

          _waitingOrdersStream = fireStore
              .collection('orders')
              .where('status', isEqualTo: ShipperEnum.shipper_waiting.name)
              .where(
                'shipperPhoneNumber',
                isEqualTo: context.read<AuthorBloc>().currentUser!.phoneNumber,
              )
              .limit(limit)
              .snapshots();
        }
      }
    });
  }

  void _changeHistoryOrderListLimit(String value) {
    setState(() {
      if (value.isNotEmpty) {
        int limit = int.parse(value);

        if (limit > 0) {
          _historyListLimitController.text = limit.toString();

          context.read<OrderBloc>().add(OnLoadShipperHistoryOrderList(
                context.read<AuthorBloc>().currentUser!.phoneNumber,
                limit,
                1,
              ));
        }
      }
    });
  }

  void _watchMap(my_order.Order order) {
    context.read<GoogleMapBloc>().add(OnLoadOrderRouteEvent(
          order.fromLocation,
          order.toLocation,
          order.fromLocationGeoPoint.toLatLng,
          order.toLocationGeoPoint.toLatLng,
        ));

    context.router.pushNamed(AppRouterPath.googleMap);
  }

  void _confirmFinishShipping(my_order.Order order) {
    context
        .read<OrderBloc>()
        .add(OnFinishShippingOrderEvent(order.getOrderDoc()));
  }

  void _reloadShippingOrder() {
    context.read<OrderBloc>().add(
          OnLoadShippingOrderEvent(
            context.read<AuthorBloc>().currentUser!.phoneNumber,
          ),
        );
  }

  @override
  void initState() {
    context.read<OrderBloc>().add(
          OnLoadShippingOrderEvent(
            context.read<AuthorBloc>().currentUser!.phoneNumber,
          ),
        );

    _waitingListLimitController.text = '10';
    _historyListLimitController.text = '10';

    _waitingOrdersStream = fireStore
        .collection('orders')
        .where('status', isEqualTo: ShipperEnum.shipper_waiting.name)
        .where(
          'shipperPhoneNumber',
          isEqualTo: context.read<AuthorBloc>().currentUser!.phoneNumber,
        )
        .limit(10)
        .snapshots();

    context.read<OrderBloc>().add(OnLoadShipperHistoryOrderList(
          context.read<AuthorBloc>().currentUser!.phoneNumber,
          10,
          1,
        ));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Trang chủ',
      canComeBack: false,
      body: DefaultTabController(
        length: 3,
        initialIndex: widget.initialTabIndex,
        child: Column(
          children: [
            TabBar(
              unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
              tabAlignment: TabAlignment.fill,
              padding: EdgeInsets.symmetric(
                vertical: 5.height,
                horizontal: 5.width,
              ),
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.delivery_dining,
                    size: 33.size,
                  ),
                  // height: 120.height,
                  child: const Expanded(
                    child: Text(
                      "Đang giao",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.checklist_rtl_rounded,
                    size: 33.size,
                  ),
                  // height: 120.height,
                  child: const Expanded(
                    child: Text(
                      "Nhận đơn",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.featured_play_list_outlined,
                    size: 33.size,
                  ),
                  // height: 120.height,
                  child: const Expanded(
                    child: Text(
                      "Lịch sử",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _shippingOrder(),
                  _waitingOrders(),
                  _historyOrderList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shippingOrder() {
    return RefreshIndicator(
      onRefresh: () async {
        _reloadShippingOrder();
      },
      child: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderErrorState) {
            setState(() {
              _fromLocationController.clear();
              _toLocationController.clear();
              _receiverController.clear();
              _phoneNumberController.clear();
              _packageNameController.clear();
              _codController.clear();
              _noteController.clear();
              _senderController.clear();
            });

            context.read<OrderBloc>().add(OnClearOrderEvent());

            UiRender.showDialog(context, '', state.message);
          } else if (state is OrderAcceptedState) {
            UiRender.showDialog(context, '', state.message);
          } else if (state is OrderFinishedShippingState) {
            context.read<GoogleMapBloc>().add(OnClearMapEvent());
            setState(() {
              _fromLocationController.clear();
              _toLocationController.clear();
              _receiverController.clear();
              _phoneNumberController.clear();
              _packageNameController.clear();
              _codController.clear();
              _noteController.clear();
              _senderController.clear();
            });

            UiRender.showDialog(context, '', state.message);
          } else if (state is ShippingOrderLoadedState) {
            my_order.Order shippingOrder = state.shippingOrder;

            setState(() {
              _fromLocationController.text = shippingOrder.fromLocation;
              _toLocationController.text = shippingOrder.toLocation;
              _receiverController.text = shippingOrder.receiverName;
              _phoneNumberController.text = shippingOrder.receiverPhoneNumber;
              _packageNameController.text = shippingOrder.packageName;
              _codController.text = shippingOrder.cod;
              _noteController.text = shippingOrder.noteForShipper ?? '';
              _senderController.text = shippingOrder.senderPhoneNumber;
            });
          }
        },
        builder: (context, state) {
          my_order.Order? shippingOrder =
              context.read<OrderBloc>().currentShippingOrder;

          if (state is OrderLoadingState) {
            return UiRender.loadingCircle(context);
          } else if (state is ShippingOrderLoadedState) {
            shippingOrder = state.shippingOrder;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: 20.height,
              horizontal: 10.width,
            ),
            child: Column(
              children: [
                Text(
                  'THÔNG TIN ĐƠN HÀNG ĐANG GIAO',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17.size,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                10.verticalSpace,
                _textFieldWithLabel(
                  label: 'Điểm bắt đầu',
                  controller: _fromLocationController,
                ),
                _textFieldWithLabel(
                  label: 'Điểm đến',
                  controller: _toLocationController,
                ),
                _textFieldWithLabel(
                  label: 'Tên người nhận',
                  controller: _receiverController,
                ),
                _textFieldWithLabel(
                  label: 'Số điện thoại người nhận',
                  controller: _phoneNumberController,
                ),
                _textFieldWithLabel(
                  label: 'Tên hàng hoá',
                  controller: _packageNameController,
                ),
                _textFieldWithLabel(
                  label: 'Cod',
                  controller: _codController,
                ),
                _textFieldWithLabel(
                  label: 'Ghi chú cho shipper',
                  controller: _noteController,
                ),
                _textFieldWithLabel(
                  label: 'Số điện thoại người gửi',
                  controller: _senderController,
                ),
                shippingOrder != null
                    ? GradientElevatedButton(
                        text: 'Xem bản đồ',
                        onPress: () => _watchMap(shippingOrder!),
                        buttonHeight: 50.height,
                      )
                    : const SizedBox(),
                shippingOrder != null
                    ? GradientElevatedButton(
                        text: 'Xác nhận hoàn tất',
                        buttonMargin: EdgeInsets.only(top: 20.height),
                        onPress: () => _confirmFinishShipping(
                          shippingOrder!,
                        ),
                        buttonHeight: 50.height,
                      )
                    : const SizedBox(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _waitingOrders() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: 15.height,
        horizontal: 10.width,
      ),
      child: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderAcceptedState) {
            DefaultTabController.of(context).animateTo(0);

            context.read<OrderBloc>().add(
                  OnLoadShippingOrderEvent(
                    context.read<AuthorBloc>().currentUser!.phoneNumber,
                  ),
                );
          } else if (state is OrderRefusedState) {
            UiRender.showDialog(context, '', state.message);
          } else if (state is OrderErrorState) {
            UiRender.showDialog(context, '', state.message);
          }
        },
        child: Column(
          children: [
            Text(
              'Nhấn vào đơn hàng để xem các hành động',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Text(
              'Nhấn và giữ vào đơn hàng để xem thông tin',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            20.verticalSpace,
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
                  onPress: _decreaseWaitingListLimit,
                ),
                Flexible(
                  child: SizedBox(
                    width: 60.width,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: _waitingListLimitController,
                      showCursor: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _changeWaitingOrderListLimit,
                    ),
                  ),
                ),
                GradientElevatedButton(
                  text: '+',
                  textSize: 18.size,
                  buttonHeight: 30.size,
                  buttonWidth: 30.size,
                  buttonMargin: EdgeInsets.zero,
                  onPress: _increaseWaitingListLimit,
                ),
                5.horizontalSpace,
                const Text('dòng'),
              ],
            ),
            20.verticalSpace,
            StreamBuilder(
              stream: _waitingOrdersStream,
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
                          return WaitingOrderListComponent(
                            order: my_order.Order.fromJson(data),
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
    );
  }

  Widget _historyOrderList() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  onPress: _decreaseHistoryListLimit,
                ),
                Flexible(
                  child: SizedBox(
                    width: 60.width,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: _historyListLimitController,
                      showCursor: false,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: _changeHistoryOrderListLimit,
                    ),
                  ),
                ),
                GradientElevatedButton(
                  text: '+',
                  textSize: 18.size,
                  buttonHeight: 30.size,
                  buttonWidth: 30.size,
                  buttonMargin: EdgeInsets.zero,
                  onPress: _increaseHistoryListLimit,
                ),
                5.horizontalSpace,
                const Text('dòng'),
              ],
            ),
            20.verticalSpace,
            Center(
              child: Text(
                'Nhẫn và giữ để xem thông tin chi tiết đơn hàng của bạn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.size,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
            20.verticalSpace,
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                List<my_order.Order> orderList =
                    context.read<OrderBloc>().currentOrderList;
                int page = context.read<OrderBloc>().currentPage;

                if (state is ShipperHistoryOrderListLoadedState) {
                  orderList = state.orderList;
                  page = state.page;
                } else if (state is OrderLoadingState) {
                  return UiRender.loadingCircle(context);
                }

                return DataTable(
                  columnSpacing: 10.width,
                  dataRowMinHeight: 30.height,
                  dataRowMaxHeight: 100.height,
                  dataTextStyle: TextStyle(
                    fontSize: 15.size,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onError,
                  ),
                  columns: [
                    _dataColumn('ID'),
                    _dataColumn('Tên người nhận'),
                    _dataColumn('SĐT người nhận'),
                    _dataColumn('Ngày giao'),
                    _dataColumn('Tình trạng'),
                  ],
                  rows: List.generate(
                    orderList.length,
                    (index) => _dataRow(orderList[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  DataColumn _dataColumn(String name) {
    return DataColumn(
      label: Expanded(
        child: Text(
          name,
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 5,
          overflow: TextOverflow.visible,
          style: TextStyle(
            fontSize: 15.size,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  DataRow _dataRow(my_order.Order order) {
    return DataRow(
      onLongPress: () => _showOrderInfo(order),
      cells: [
        DataCell(
          Text(
            order.shipperOrderId.toString(),
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            order.receiverName,
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            order.receiverPhoneNumber,
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            order.shipDate?.date ?? '',
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            order.getShippingStatus(),
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _textFieldWithLabel({
    required String label,
    required TextEditingController controller,
    void Function()? onPress,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.height),
      padding: EdgeInsets.symmetric(
        horizontal: 15.width,
        vertical: 4.height,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.background,
        ),
        borderRadius: BorderRadius.circular(20.radius),
      ),
      child: TextFormField(
        onTap: onPress,
        controller: controller,
        enabled: false,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
