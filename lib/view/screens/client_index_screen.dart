import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/google_map/google_map_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:keri_challenge/view/components/layout.dart';

@RoutePage()
class ClientIndexScreen extends StatefulWidget {
  const ClientIndexScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ClientIndexScreenState();
}

class _ClientIndexScreenState extends State<ClientIndexScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _toLocationController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _codController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  void _onPressShipperBookingButton() {
    if (_formKey.currentState!.validate()) {
      UiRender.showDialog(
        context,
        '',
        '${_fromLocationController.text}\n${_toLocationController.text}\n${_receiverController.text}\n${_phoneNumberController.text}\n${_codController.text}\n${_fromLocationController.text}\n${_noteController.text}\n',
      );
    }
  }

  void _onPressSelectLocation() {
    context.router.pushNamed(AppRouterPath.googleMap);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Trang chủ',
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
                      _shipperBooking(),
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

  Widget _shipperBooking() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.height,
          horizontal: 10.width,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<GoogleMapBloc, GoogleMapState>(
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
                'Số tiền tạm tính: -VND (- km)',
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
