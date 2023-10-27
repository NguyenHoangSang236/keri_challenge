import 'package:auto_route/auto_route.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/screens/phone_verification_screen.dart';

import '../../bloc/authorization/author_bloc.dart';
import '../../data/entities/user.dart';
import '../../services/firebase_sms_service.dart';
import '../../view/components/gradient_button.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.isShipper});

  final bool isShipper;

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordTextEditingController =
      TextEditingController();
  final TextEditingController _addressTextEditingController =
      TextEditingController();
  final TextEditingController _idCertNumTextEditingController =
      TextEditingController();
  final TextEditingController _birthYearTextEditingController =
      TextEditingController();
  final SingleValueDropDownController _sexDropdownController =
      SingleValueDropDownController();

  bool _isPasswordObscure = true;
  bool _isCfmPasswordObscure = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _onPressBackButton() {
    context.router.pop();
  }

  void _onPressedRegisterButton() async {
    if (_passwordTextEditingController.text !=
        _confirmPasswordTextEditingController.text) {
      UiRender.showSnackBar(
        context,
        'Password field must match Confirm password field',
      );
    }
    if (_formKey.currentState!.validate()) {
      FirebaseSmsService.verifyPhoneNumber(
        _phoneNumberTextEditingController.text,
      );

      User newUser = User(
        fullName: _fullNameTextEditingController.text,
        password: _passwordTextEditingController.text,
        phoneNumber: _phoneNumberTextEditingController.text,
        phoneFcmToken: '',
        isOnline: false,
        role: widget.isShipper ? 'shipper' : 'client',
        birthYear: _birthYearTextEditingController.text,
        address: _addressTextEditingController.text,
        idCertificateNumber: _idCertNumTextEditingController.text,
        sex: _sexDropdownController.dropDownValue?.value,
        registerDate: DateTime.now(),
      );

      context.router.pushWidget(
        PhoneVerificationScreen(
          user: newUser,
        ),
      );
    }
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

  void _onPressPasswordEyeButton() {
    setState(() {
      _isPasswordObscure = !_isPasswordObscure;
    });
  }

  void _onPressCfmPasswordEyeButton() {
    setState(() {
      _isCfmPasswordObscure = !_isCfmPasswordObscure;
    });
  }

  final String? Function(String?) _passwordValidator = (String? value) {
    if (value!.trim().contains(' ')) {
      return 'Mật khẩu không được phép có khoảng trống';
    }

    return null;
  };

  final String? Function(String?) _sexValidator = (String? value) {
    if (value == null || value.isEmpty || value.trim().contains(' ')) {
      return 'Cần phải chọn giới tính';
    }

    return null;
  };

  final String? Function(String?) _phoneValidator = (String? value) {
    if (value!.length != 10) {
      return 'Số điện thoại phải bao gồm 10 số';
    }

    return null;
  };

  final String? Function(String?) _idCertNumValidator = (String? value) {
    if (value!.length != 12) {
      return 'Số CCCD/CMT phải bao gồm 12 số';
    }

    return null;
  };

  final String? Function(String?) _birthYearValidator = (String? value) {
    if (value!.length != 4) {
      return 'Năm sinh phải có 4 số';
    } else if (int.parse(value!) < 1930 ||
        int.parse(value!) > DateTime.now().year) {
      return 'Năm sinh phải chỉ được phép từ 1930 - năm hiện tại';
    }

    return null;
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: _onPressBackButton,
        ),
        title: Text(
          'Tạo tài khoản ${widget.isShipper ? 'Shipper' : 'Khách hàng'}',
          style: TextStyle(
            fontSize: 17.size,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: BlocListener<AuthorBloc, AuthorState>(
          listener: (context, state) {
            if (state is AuthorRegisteredState) {
              UiRender.showSnackBar(context, state.message);
              context.router.pushNamed(AppRouterPath.phoneVerification);
            }
          },
          child: Container(
            padding: EdgeInsets.all(20.size),
            color: Colors.white,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nhập thông tin tài khoản',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20.size,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  25.verticalSpace,
                  _customTextField(
                    controller: _phoneNumberTextEditingController,
                    hintText: 'Số điện thoại (*)',
                    keyboardType: TextInputType.number,
                    additionalValidator: _phoneValidator,
                  ),
                  _customTextField(
                    controller: _fullNameTextEditingController,
                    hintText: 'Họ và Tên',
                  ),
                  _dropdownTextField(),
                  _customTextField(
                    controller: _birthYearTextEditingController,
                    hintText: 'Năm sinh',
                    keyboardType: TextInputType.number,
                    additionalValidator: _birthYearValidator,
                  ),
                  _customTextField(
                    controller: _addressTextEditingController,
                    hintText: 'Địa chỉ',
                  ),
                  _customTextField(
                    controller: _idCertNumTextEditingController,
                    hintText: 'Số CCCD/CMT',
                    keyboardType: TextInputType.number,
                    additionalValidator: _idCertNumValidator,
                  ),
                  _customTextField(
                    controller: _passwordTextEditingController,
                    hintText: 'Mật khẩu',
                    isPassword: true,
                    isObscure: _isPasswordObscure,
                    type: PasswordTextFieldType.password,
                    additionalValidator: _passwordValidator,
                  ),
                  _customTextField(
                    controller: _confirmPasswordTextEditingController,
                    hintText: 'Xác nhận mật khẩu',
                    isPassword: true,
                    isObscure: _isCfmPasswordObscure,
                    type: PasswordTextFieldType.confirmPassword,
                    additionalValidator: _passwordValidator,
                  ),
                  GradientElevatedButton(
                    text: 'Tạo tài khoản',
                    buttonHeight: 50.height,
                    onPress: _onPressedRegisterButton,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownTextField() {
    return Container(
      padding: const EdgeInsets.all(7),
      margin: EdgeInsets.symmetric(vertical: 15.height),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
      child: DropDownTextField(
        controller: _sexDropdownController,
        textFieldDecoration: const InputDecoration(
          hintText: "Giới tính",
        ),
        clearOption: true,
        validator: _sexValidator,
        dropDownItemCount: 3,
        dropDownList: const [
          DropDownValueModel(name: 'Nam', value: "male"),
          DropDownValueModel(name: 'Nữ', value: "female"),
          DropDownValueModel(name: 'Khác', value: "other"),
        ],
      ),
    );
  }

  Widget _customTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isObscure = false,
    String? Function(String?)? additionalValidator,
    PasswordTextFieldType? type,
  }) {
    return Container(
      padding: const EdgeInsets.all(7),
      margin: EdgeInsets.symmetric(vertical: 15.height),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 5.width),
              ),
              validator: (value) => _textFieldValidator(
                value,
                additionalValidator,
              ),
              obscureText: isObscure,
            ),
          ),
          !isPassword
              ? const SizedBox()
              : IconButton(
                  onPressed: type == PasswordTextFieldType.password
                      ? _onPressPasswordEyeButton
                      : _onPressCfmPasswordEyeButton,
                  icon: Icon(
                    isObscure
                        ? Icons.remove_red_eye
                        : Icons.remove_red_eye_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
        ],
      ),
    );
  }
}

enum PasswordTextFieldType {
  password,
  confirmPassword,
}
