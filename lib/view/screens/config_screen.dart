import 'package:auto_route/annotations.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/appConfig/app_config_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/data/entities/app_config.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';

import '../components/layout.dart';

@RoutePage()
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final GlobalKey<FormState> _configFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hotlineController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _bankReceiverNameController =
      TextEditingController();
  final TextEditingController _pricePerKmController = TextEditingController();
  final TextEditingController _oneDayShipperServicePriceController =
      TextEditingController();
  final TextEditingController _oneMonthShipperServicePriceController =
      TextEditingController();
  final TextEditingController _sloganController = TextEditingController();
  final TextEditingController _websiteUrlController = TextEditingController();

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

  final String? Function(String?) _phoneValidator = (String? value) {
    if (value!.length != 10) {
      return 'Số điện thoại phải bao gồm 10 số';
    } else if (value.trim().contains(' ')) {
      return 'Không được chứa khoảng trắng';
    }

    return null;
  };

  final String? Function(String?) _numberValidator = (String? value) {
    if (value!.trim().contains(' ')) {
      return 'Không được chứa khoảng trắng';
    }

    return null;
  };

  void _updateAppConfig() {
    if (_configFormKey.currentState!.validate()) {
      if (double.parse(_oneDayShipperServicePriceController.text) >
          double.parse(_oneMonthShipperServicePriceController.text)) {
        UiRender.showDialog(
          context,
          'Lỗi giá tiền dịch vụ',
          'Số tiền gói dịch vụ tháng cần phải lớn hơn số tiền gới dịch vụ ngày',
        );
      } else {
        context.read<AppConfigBloc>().add(
              OnUpdateAppConfigEvent(
                AppConfig(
                  _emailController.text,
                  _hotlineController.text,
                  _bankNameController.text,
                  _bankAccountController.text,
                  _bankReceiverNameController.text,
                  double.parse(_pricePerKmController.text),
                  double.parse(_oneDayShipperServicePriceController.text),
                  double.parse(_oneMonthShipperServicePriceController.text),
                  _sloganController.text,
                  _websiteUrlController.text,
                ),
              ),
            );
      }
    }
  }

  @override
  void initState() {
    _emailController.text = context.read<AppConfigBloc>().appConfig!.email;
    _hotlineController.text = context.read<AppConfigBloc>().appConfig!.hotline;
    _bankNameController.text =
        context.read<AppConfigBloc>().appConfig!.bankName;
    _bankAccountController.text =
        context.read<AppConfigBloc>().appConfig!.bankAccount;
    _bankReceiverNameController.text =
        context.read<AppConfigBloc>().appConfig!.bankReceiverName;
    _pricePerKmController.text =
        context.read<AppConfigBloc>().appConfig!.pricePerKm.toString();
    _oneDayShipperServicePriceController.text = context
        .read<AppConfigBloc>()
        .appConfig!
        .oneDayShipperServicePrice
        .toString();
    _oneMonthShipperServicePriceController.text = context
        .read<AppConfigBloc>()
        .appConfig!
        .oneMonthShipperServicePrice
        .toString();
    _sloganController.text = context.read<AppConfigBloc>().appConfig!.slogan;
    _websiteUrlController.text =
        context.read<AppConfigBloc>().appConfig!.websiteUrl;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Cấu hình Admin',
      canComeBack: false,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AppConfigBloc>().add(
                OnLoadAppConfigEvent(),
              );
        },
        child: BlocListener<AppConfigBloc, AppConfigState>(
          listener: (context, state) {
            if (state is AppConfigUpdatedState) {
              UiRender.showDialog(context, '', state.message);
            } else if (state is AppConfigErrorState) {
              UiRender.showDialog(context, '', state.message);
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 25.width,
              vertical: 30.height,
            ),
            child: Form(
              key: _configFormKey,
              child: Column(
                children: [
                  _fieldComponent(
                    title: 'Slogan',
                    controller: _sloganController,
                  ),
                  _fieldComponent(
                    title: 'Email',
                    controller: _emailController,
                    additionalValidator: (value) =>
                        EmailValidator.validate(value ?? '')
                            ? null
                            : "Email không hợp lệ",
                  ),
                  _fieldComponent(
                    title: 'Hotline',
                    controller: _hotlineController,
                    keyboardType: TextInputType.phone,
                    additionalValidator: _phoneValidator,
                  ),
                  _fieldComponent(
                    title: 'Link website',
                    controller: _websiteUrlController,
                  ),
                  _fieldComponent(
                    title: 'Giá 1km',
                    controller: _pricePerKmController,
                    keyboardType: TextInputType.phone,
                    additionalValidator: _numberValidator,
                  ),
                  _fieldComponent(
                    title: 'Giá tiền gói dịch vụ 1 ngày',
                    controller: _oneDayShipperServicePriceController,
                    keyboardType: TextInputType.phone,
                    additionalValidator: _numberValidator,
                  ),
                  _fieldComponent(
                    title: 'Giá tiền gói dịch vụ 1 tháng',
                    controller: _oneMonthShipperServicePriceController,
                    keyboardType: TextInputType.phone,
                    additionalValidator: _numberValidator,
                  ),
                  _fieldComponent(
                    title: 'Tên ngân hàng',
                    controller: _bankNameController,
                  ),
                  _fieldComponent(
                    title: 'Tên người thụ hưởng',
                    controller: _bankReceiverNameController,
                  ),
                  _fieldComponent(
                    title: 'Số tài khoản',
                    controller: _bankAccountController,
                    additionalValidator: _numberValidator,
                  ),
                  GradientElevatedButton(
                    text: 'Cập nhật',
                    onPress: _updateAppConfig,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldComponent({
    required String title,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? additionalValidator,
  }) {
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
            padding: EdgeInsets.all(5.size),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              borderRadius: BorderRadius.circular(10.radius),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 5.width),
              ),
              validator: (value) => _textFieldValidator(
                value,
                additionalValidator,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
