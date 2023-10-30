import 'package:auto_route/auto_route.dart';
import 'package:counter/counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/google_map/google_map_bloc.dart';
import 'package:keri_challenge/bloc/order/order_bloc.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/extension/pointLatLng_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/data/entities/order.dart';
import 'package:keri_challenge/data/enum/ship_status_enum.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:keri_challenge/view/components/layout.dart';

import '../../bloc/appConfig/app_config_bloc.dart';
import '../../bloc/authorization/author_bloc.dart';

@RoutePage()
class ClientIndexScreen extends StatefulWidget {
  const ClientIndexScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ClientIndexScreenState();
}

class _ClientIndexScreenState extends State<ClientIndexScreen> {
  final GlobalKey<FormState> _clientIndexFormKey = GlobalKey<FormState>();

  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _toLocationController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _codController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int orderListLimit = 10;
  double distance = 0;

  void _onPressShipperBookingButton() {
    // context.router.pushNamed(AppRouterPath.onlineShipperList);

    if (_clientIndexFormKey.currentState!.validate()) {
      UiRender.showConfirmDialog(
        context,
        'Thông tin đơn hàng của bạn',
        '${_fromLocationController.text}\n${_toLocationController.text}\n${_receiverController.text}\n${_phoneNumberController.text}\n${_codController.text}\n${_fromLocationController.text}\n${_noteController.text}\n',
      ).then((value) {
        if (value) {
          context.read<OrderBloc>().add(
                OnAddNewOrderEvent(
                  Order(
                    id: 0,
                    distance: distance,
                    price: context.read<AppConfigBloc>().appConfig!.pricePerKm *
                        distance,
                    fromLocationGeoPoint: context
                        .read<GoogleMapBloc>()
                        .currentSelectedFromPointLatLng!
                        .toGeoPoint,
                    toLocationGeoPoint: context
                        .read<GoogleMapBloc>()
                        .currentSelectedToPointLatLng!
                        .toGeoPoint,
                    packageName: _packageNameController.text,
                    cod: _codController.text,
                    noteForShipper: _noteController.text,
                    fromLocation: _fromLocationController.text,
                    toLocation: _toLocationController.text,
                    senderPhoneNumber:
                        context.read<AuthorBloc>().currentUser!.phoneNumber,
                    receiverPhoneNumber: _phoneNumberController.text,
                    receiverName: _receiverController.text,
                    status: ShipStatusEnum.shipper_waiting.name,
                    orderDate: DateTime.now(),
                  ),
                ),
              );

          context.router.pushNamed(AppRouterPath.onlineShipperList);
        }
      });
    }
  }

  void _onPressSelectLocation() {
    context.router.pushNamed(AppRouterPath.googleMap);
  }

  void _onChangeCounter(num value) {
    int limit = value as int;

    context.read<OrderBloc>().add(OnLoadOrderListEvent(
          context.read<AuthorBloc>().currentUser!.phoneNumber,
          limit,
          1,
        ));
  }

  void _onLongPressDataRow(Order order) {
    UiRender.showDialog(
      context,
      'Thông tin đơn hàng',
      order.showFullInfo(),
      textAlign: TextAlign.start,
    );
  }

  String? _textFieldValidator(
    String? value,
    String? Function(String?)? additionalValidator,
  ) {
    if (value == null || value.isEmpty) {
      return 'Không được để trống!';
    } else if (additionalValidator != null) {
      return additionalValidator(value);
    }
    return null;
  }

  final String? Function(String?) _phoneNumberValidator = (String? value) {
    if (value!.trim().length != 10) {
      return 'Số điện thoại phải có 10 chữ số';
    } else if (value.trim().contains(' ')) {
      return 'Số điện thoại không được chứa khoảng trống';
    }

    return null;
  };

  String _covertShippingStatus(String status) {
    return status == ShipStatusEnum.shipping.name
        ? 'Đang giao'
        : status == ShipStatusEnum.shipped.name
            ? 'Đã giao'
            : status == ShipStatusEnum.shipper_waiting.name
                ? 'Đợi shipper'
                : 'Không xác định';
  }

  @override
  void initState() {
    _fromLocationController.text = context
            .read<GoogleMapBloc>()
            .currentSelectedFromPrediction
            .description ??
        'Điểm đi';
    _toLocationController.text =
        context.read<GoogleMapBloc>().currentSelectedToPrediction.description ??
            'Điểm đến';

    distance = context.read<GoogleMapBloc>().distance;

    context.read<OrderBloc>().add(
          OnLoadOrderListEvent(
            context.read<AuthorBloc>().currentUser!.phoneNumber,
            10,
            1,
          ),
        );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Trang chủ',
      canComeBack: false,
      body: DefaultTabController(
        length: 2,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10.height,
              horizontal: 10.width,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                10.verticalSpace,
                Text(
                  'Giao hàng',
                  style: TextStyle(
                    fontSize: 25.size,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                20.verticalSpace,
                const TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.delivery_dining),
                      text: "Đặt shipper",
                    ),
                    Tab(
                      icon: Icon(Icons.featured_play_list_outlined),
                      text: "Danh sách đã đặt",
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 3,
                  child: TabBarView(
                    children: [
                      _shipperBooking(),
                      _myOrderList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _myOrderList() {
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
                Counter(
                  min: 0,
                  max: 10000,
                  initial: orderListLimit,
                  onValueChanged: _onChangeCounter,
                  configuration: CounterConfig(context),
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
                List<Order> orderList =
                    context.read<OrderBloc>().currentOrderList;
                int page = context.read<OrderBloc>().currentPage;

                if (state is OrderListLoadedState) {
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
                    _dataColumn('Số điện thoại'),
                    _dataColumn('Ngày đặt'),
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

  DataRow _dataRow(Order order) {
    return DataRow(
      onLongPress: () => _onLongPressDataRow(order),
      cells: [
        DataCell(
          Text(
            order.id.toString(),
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
            order.orderDate.date,
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            _covertShippingStatus(order.status),
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _shipperBooking() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.height,
          horizontal: 10.width,
        ),
        child: Form(
          key: _clientIndexFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocConsumer<GoogleMapBloc, GoogleMapState>(
                listener: (context, state) {
                  if (state is GoogleMapDistanceCalculatedState) {
                    setState(() {
                      distance = state.distance;
                    });
                  }
                },
                builder: (context, state) {
                  _fromLocationController.text = context
                          .read<GoogleMapBloc>()
                          .currentSelectedFromPrediction
                          .description ??
                      'Điểm đi';
                  _toLocationController.text = context
                          .read<GoogleMapBloc>()
                          .currentSelectedToPrediction
                          .description ??
                      'Điểm đến';

                  if (state is GoogleMapNewLocationLoadedState) {
                    if (state.isFromLocation) {
                      _fromLocationController.text =
                          state.prediction?.description ?? 'Điểm đi';
                    } else {
                      _toLocationController.text =
                          state.prediction?.description ?? 'Điểm đến';
                    }
                  }

                  return Column(
                    children: [
                      _textFieldWithLabel(
                        label: 'Điểm bắt đầu (Nhấn chọn hoặc điền địa chỉ)',
                        controller: _fromLocationController,
                        isFromLocation: true,
                        onPress: _onPressSelectLocation,
                      ),
                      _textFieldWithLabel(
                        label: 'Điểm đến (Nhấn chọn hoặc điền địa chỉ)',
                        controller: _toLocationController,
                        isFromLocation: false,
                        onPress: _onPressSelectLocation,
                      ),
                    ],
                  );
                },
              ),
              10.verticalSpace,
              Text(
                'THÔNG TIN NGƯỜI NHẬN',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16.size,
                  fontWeight: FontWeight.w500,
                ),
              ),
              10.verticalSpace,
              _textFieldWithLabel(
                label: 'Tên người nhận',
                controller: _receiverController,
              ),
              _textFieldWithLabel(
                label: 'Số điện thoại',
                controller: _phoneNumberController,
                textInputType: TextInputType.phone,
                additionalValidator: _phoneNumberValidator,
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
                needValidate: false,
              ),
              Text(
                'Số tiền tạm tính: ${(context.read<AppConfigBloc>().appConfig!.pricePerKm * distance).formatMoney}VND (${distance.format} km)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 15.size,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Center(
                child: GradientElevatedButton(
                  text: 'Đặt shipper',
                  buttonHeight: 43.height,
                  onPress: _onPressShipperBookingButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFieldWithLabel({
    required String label,
    required TextEditingController controller,
    void Function()? onPress,
    bool? isFromLocation,
    bool needValidate = true,
    TextInputType? textInputType,
    String? Function(String?)? additionalValidator,
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
        validator: (value) => needValidate
            ? _textFieldValidator(
                value,
                additionalValidator,
              )
            : null,
        keyboardType: textInputType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class CounterConfig implements Configuration {
  final BuildContext context;

  CounterConfig(this.context);

  @override
  double get size => 22.size;

  @override
  double get fontSize => 15.size;

  @override
  Color? get textColor => Colors.black;

  @override
  Color? get textBackgroundColor => Colors.transparent;

  @override
  double get textWidth => 40.width;

  @override
  IconStyle get iconStyle => IconStyle.add_minus_bold;

  @override
  Color? get iconColor => Theme.of(context).colorScheme.primary;

  @override
  Color? get disableColor => Theme.of(context).colorScheme.error;

  @override
  Color? get backgroundColor => Colors.transparent;

  @override
  double? get iconBorderWidth => null;

  @override
  double? get iconBorderRadius => size / 2;
}
