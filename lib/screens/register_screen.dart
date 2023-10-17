import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/screens/phone_verification_screen.dart';
import 'package:keri_challenge/util/ui_render.dart';

import '../bloc/authorization/author_bloc.dart';
import '../components/gradient_button.dart';
import '../entities/user.dart' as custom_user;
import '../services/firebase_sms_service.dart';

@RoutePage()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _userNameTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();
  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _confirmPasswordTextEditingController =
      TextEditingController();

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

      context.router.pushWidget(
        PhoneVerificationScreen(
          user: custom_user.User(
            _userNameTextEditingController.text,
            _passwordTextEditingController.text,
            _phoneNumberTextEditingController.text,
            '',
          ),
        ),
      );
    }
  }

  String? _textFieldValidator(
    String? value,
    String? Function(String?)? additionalValidator,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
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

  final String? Function(String?) _userNameAndPasswordValidator =
      (String? value) {
    if (value!.trim().contains(' ')) {
      return 'User name and password can not contain space';
    }

    return null;
  };

  final String? Function(String?) _phoneValidator = (String? value) {
    if (value!.length != 10) {
      return 'Phone number must be 10-digit';
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
        title: const Text(
          'Sign up for a new account',
          style: TextStyle(
            color: Colors.orange,
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
            height: MediaQuery.of(context).size.height,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   'Sign in',
                  //   style: TextStyle(
                  //     fontWeight: FontWeight.w600,
                  //     fontSize: 25.size,
                  //     color: Colors.orange,
                  //   ),
                  // ),
                  // 20.verticalSpace,
                  _customTextField(
                    controller: _userNameTextEditingController,
                    hintText: 'User name',
                    additionalValidator: _userNameAndPasswordValidator,
                  ),
                  _customTextField(
                    controller: _passwordTextEditingController,
                    hintText: 'Password',
                    isPassword: true,
                    isObscure: _isPasswordObscure,
                    type: PasswordTextFieldType.password,
                  ),
                  _customTextField(
                    controller: _confirmPasswordTextEditingController,
                    hintText: 'Confirm password',
                    isPassword: true,
                    isObscure: _isCfmPasswordObscure,
                    type: PasswordTextFieldType.confirmPassword,
                  ),
                  _customTextField(
                    controller: _phoneNumberTextEditingController,
                    hintText: 'Phone number',
                    keyboardType: TextInputType.number,
                    additionalValidator: _phoneValidator,
                  ),
                  GradientElevatedButton(
                    text: 'Register',
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
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 15.height),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.radius),
        border: Border.all(
          color: Colors.grey,
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
