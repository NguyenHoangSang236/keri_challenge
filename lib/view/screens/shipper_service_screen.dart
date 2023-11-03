import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:counter/counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keri_challenge/bloc/appConfig/app_config_bloc.dart';
import 'package:keri_challenge/bloc/authorization/author_bloc.dart';
import 'package:keri_challenge/bloc/shipper_service/shipper_service_bloc.dart';
import 'package:keri_challenge/core/extension/datetime_extension.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';
import 'package:keri_challenge/data/enum/shipper_service_enum.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/util/value_render.dart';
import 'package:keri_challenge/view/components/layout.dart';

import '../../config/counter_config.dart';
import '../components/gradient_button.dart';

@RoutePage()
class ShipperServiceScreen extends StatefulWidget {
  const ShipperServiceScreen({super.key, this.isShipperServiceExpired = false});

  final bool isShipperServiceExpired;

  @override
  State<StatefulWidget> createState() => _ShipperServiceScreenState();
}

class _ShipperServiceScreenState extends State<ShipperServiceScreen> {
  final GlobalKey<FormState> _shipperServiceFormKey = GlobalKey<FormState>();
  final List<String> _serviceTypeList = [
    ShipperServiceEnum.month.name,
    ShipperServiceEnum.day.name,
  ];
  String _currentServiceType = '';
  File? imageFile;
  int shipperServiceListLimit = 10;

  void _copyText(String value) {
    Clipboard.setData(ClipboardData(text: value)).then((val) {
      UiRender.showSnackBar(context, 'Đã sao chép văn bản vào bộ nhớ tạm');
    });
  }

  String _getServiceType(String value) {
    return value == ShipperServiceEnum.month.name
        ? 'Gói tháng'
        : value == ShipperServiceEnum.day.name
            ? 'Gói ngày'
            : 'Không xác định';
  }

  String _getShipperServiceStatus(String value) {
    return value == ShipperServiceEnum.waiting.name
        ? 'Đang chờ xác nhận'
        : value == ShipperServiceEnum.accepted.name
            ? 'Đã chấp nhận'
            : value == ShipperServiceEnum.expired.name
                ? 'Đã hết hạn'
                : value == ShipperServiceEnum.rejected.name
                    ? 'Đã từ chối'
                    : 'Không xác định';
  }

  void _selectServiceType(String? type) {
    setState(() {
      _currentServiceType = type ?? '';
    });
  }

  void _removeImage() {
    setState(() {
      imageFile = null;
    });
  }

  void _pickImage() {
    ImagePicker()
        .pickImage(
      source: ImageSource.gallery,
    )
        .then(
      (XFile? image) {
        setState(() {
          imageFile = File(image?.path ?? '');
        });
      },
    );
  }

  void _onChangeCounter(num value) {
    int limit = value as int;

    context.read<ShipperServiceBloc>().add(OnLoadHistoryShipperServiceListEvent(
          ValueRender.currentUser!.phoneNumber,
          limit,
          1,
        ));
  }

  DateTime _getServiceEndDate() {
    return _currentServiceType == ShipperServiceEnum.day.name
        ? DateTime.now().add(const Duration(days: 1))
        : _currentServiceType == ShipperServiceEnum.month.name
            ? DateTime(
                DateTime.now().year,
                DateTime.now().month + 1,
                DateTime.now().day,
              )
            : DateTime.now();
  }

  void _registerService() {
    if (imageFile != null) {
      context.read<ShipperServiceBloc>().add(
            OnAddNewShipperServiceEvent(
              ShipperService(
                id: 0,
                content:
                    '${context.read<AuthorBloc>().currentUser!.phoneNumber} đăng kí ${_getServiceType(_currentServiceType)}',
                shipperPhoneNumber:
                    context.read<AuthorBloc>().currentUser!.phoneNumber,
                status: ShipperServiceEnum.waiting.name,
                type: _currentServiceType,
                beginDate: DateTime.now(),
                endDate: _getServiceEndDate(),
                billImageBase64: ValueRender.convertImageToBase64(imageFile!),
              ),
            ),
          );
    } else {
      UiRender.showDialog(
        context,
        '',
        'Hãy chọn hình chụp kết quả giao dịch của bạn để quản trị viên duyệt đơn dịch vụ',
      );
    }
  }

  void _onLongPressDataRow(ShipperService shipperService) {
    showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Thông tin đơn hàng dịch vụ'),
          content: _shipperServiceInfo(shipperService),
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

  @override
  void initState() {
    _currentServiceType = _serviceTypeList.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      canPush: !widget.isShipperServiceExpired,
      title: 'Dịch vụ shipper',
      canComeBack: false,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabAlignment: TabAlignment.fill,
              labelPadding: EdgeInsets.symmetric(
                horizontal: 5.width,
                vertical: 5.height,
              ),
              unselectedLabelColor: Theme.of(context).colorScheme.tertiary,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.app_registration_outlined,
                    size: 30.size,
                  ),
                  // height: 120.height,
                  child: const Expanded(
                    child: Text(
                      'Đăng ký dịch vụ',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.checklist_rtl_rounded,
                    size: 30.size,
                  ),
                  // height: 120.height,
                  child: const Expanded(
                    child: Text(
                      'Danh sách đã mua',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _registerNewShipperService(),
                  _myOrderList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerNewShipperService() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 15.height,
          horizontal: 20.width,
        ),
        child: BlocListener<ShipperServiceBloc, ShipperServiceState>(
          listener: (context, state) {
            if (state is ShipperServiceAddedState) {
              UiRender.showDialog(context, 'Thành công', state.message);
            } else if (state is ShipperServiceErrorState) {
              UiRender.showDialog(context, '', state.message);
            }
          },
          child: Form(
            key: _shipperServiceFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldComponent(
                  'Chọn gói',
                  DropdownButton<String>(
                    value: _currentServiceType,
                    padding: EdgeInsets.zero,
                    isExpanded: true,
                    items: List<DropdownMenuItem<String>>.generate(
                      _serviceTypeList.length,
                      (index) => DropdownMenuItem(
                        value: _serviceTypeList[index],
                        child: Text(
                          _getServiceType(_serviceTypeList[index]),
                        ),
                      ),
                    ),
                    onChanged: _selectServiceType,
                  ),
                ),
                _fieldComponent(
                  'Số tiền',
                  Text(
                    '${_currentServiceType == ShipperServiceEnum.day.name ? context.read<AppConfigBloc>().appConfig?.oneDayShipperServicePrice.format : _currentServiceType == ShipperServiceEnum.month.name ? context.read<AppConfigBloc>().appConfig?.oneMonthShipperServicePrice.format : '-'} đồng',
                  ),
                ),
                _fieldComponent(
                  'Số tài khoản ngân hàng',
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          context.read<AppConfigBloc>().appConfig!.bankAccount),
                      _copyButton(
                        context.read<AppConfigBloc>().appConfig!.bankAccount,
                      ),
                    ],
                  ),
                ),
                _fieldComponent(
                  'Tên ngân hàng',
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context.read<AppConfigBloc>().appConfig!.bankName),
                      _copyButton(
                        context.read<AppConfigBloc>().appConfig!.bankAccount,
                      ),
                    ],
                  ),
                ),
                _fieldComponent(
                  'Tên người thụ hưởng',
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(context
                          .read<AppConfigBloc>()
                          .appConfig!
                          .bankReceiverName),
                      _copyButton(
                        context.read<AppConfigBloc>().appConfig!.bankAccount,
                      ),
                    ],
                  ),
                ),
                _fieldComponent(
                  'Nội dung chuyển khoản',
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${context.read<AuthorBloc>().currentUser!.phoneNumber} đăng kí ${_getServiceType(_currentServiceType)}',
                      ),
                      _copyButton(
                          '${context.read<AuthorBloc>().currentUser!.phoneNumber} đăng kí ${_getServiceType(_currentServiceType)}'),
                    ],
                  ),
                ),
                _fieldComponent(
                  'Ảnh biên lai',
                  imageFile == null
                      ? GestureDetector(
                          onTap: _pickImage,
                          child: Text(
                            'Nhấn để chọn hình',
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.file(
                              imageFile!,
                              fit: BoxFit.fill,
                            ),
                            GradientElevatedButton(
                              text: 'Chọn lại',
                              buttonMargin: EdgeInsets.symmetric(
                                vertical: 10.height,
                              ),
                              onPress: _pickImage,
                            ),
                            GradientElevatedButton(
                              text: 'Xoá',
                              buttonMargin: EdgeInsets.symmetric(
                                vertical: 10.height,
                              ),
                              beginColor: Theme.of(context).colorScheme.error,
                              endColor: Theme.of(context).colorScheme.error,
                              onPress: _removeImage,
                            ),
                          ],
                        ),
                ),
                Center(
                  child: GradientElevatedButton(
                    text: 'Đăng kí dịch vụ',
                    buttonHeight: 43.height,
                    buttonMargin: EdgeInsets.symmetric(vertical: 35.height),
                    onPress: _registerService,
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
                  initial: shipperServiceListLimit,
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
            BlocBuilder<ShipperServiceBloc, ShipperServiceState>(
              builder: (context, state) {
                List<ShipperService> shipperServiceList =
                    context.read<ShipperServiceBloc>().shipperServiceList;

                if (state is ShipperServiceListLoadedState) {
                  shipperServiceList = state.shipperServiceList;
                } else if (state is ShipperServiceLoadingState) {
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
                    _dataColumn('Loại gói'),
                    _dataColumn('Nội dung chuyển khoản'),
                    _dataColumn('Biên lai'),
                    _dataColumn('Thời hạn'),
                  ],
                  rows: List.generate(
                    shipperServiceList.length,
                    (index) => _dataRow(shipperServiceList[index]),
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

  DataRow _dataRow(ShipperService shipperService) {
    return DataRow(
      onLongPress: () => _onLongPressDataRow(shipperService),
      cells: [
        DataCell(
          Text(
            shipperService.id.toString(),
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            _getServiceType(shipperService.type),
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            shipperService.content,
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        const DataCell(
          Text(
            'Ảnh',
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
        DataCell(
          Text(
            '${shipperService.beginDate.date} tới ${shipperService.endDate.date}',
            softWrap: true,
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
        ),
      ],
    );
  }

  Widget _shipperServiceInfo(ShipperService shipperService) {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shipperServiceInfoData('ID', shipperService.id.toString()),
          _shipperServiceInfoData(
            'Nội dung chuyển khoản',
            shipperService.content,
          ),
          _shipperServiceInfoData(
            'Trạng thái duyệt đơn',
            _getShipperServiceStatus(
              shipperService.status,
            ),
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
          Container(
            child: UiRender.convertBase64ToImage(
              shipperService.billImageBase64!,
            ),
          ),
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

  Widget _copyButton(String value) {
    return SizedBox(
      height: 35.size,
      width: 35.size,
      child: IconButton(
        onPressed: () => _copyText(value),
        icon: Icon(
          Icons.copy,
          size: 20.size,
        ),
      ),
    );
  }

  Widget _fieldComponent(String title, Widget content) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 15.height,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          5.verticalSpace,
          Container(
            padding: EdgeInsets.all(10.size),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              borderRadius: BorderRadius.circular(10.radius),
            ),
            child: content,
          ),
        ],
      ),
    );
  }
}
