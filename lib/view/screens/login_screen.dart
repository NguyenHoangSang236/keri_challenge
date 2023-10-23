import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/authorization/author_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:keri_challenge/view/screens/register_screen.dart';

import '../../services/firebase_message_service.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberTextEditingController =
      TextEditingController();
  final TextEditingController _passwordTextEditingController =
      TextEditingController();

  bool _isPasswordObscure = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  final String? Function(String?) _phoneNumberAndPasswordValidator =
      (String? value) {
    if (value!.trim().contains(' ')) {
      return 'Số điện thoại và mật khẩu không được chứa khoảng trống';
    }

    return null;
  };

  void _onPressPasswordEyeButton() {
    setState(() {
      _isPasswordObscure = !_isPasswordObscure;
    });
  }

  void _onPressedLoginButton() async {
    /// for getting total number of users
    // final snapshot = await FirebaseDatabaseService.get('/users');
    //
    // Map jsonMap = jsonDecode(snapshot.toString().formatToJson);
    //
    // print(jsonMap.keys.length);

    /// for setting new users
    // FirebaseDatabaseService.remove('users');
    // Set<String> phoneList = {};
    //
    // for (int i = 0; i < 5000; i++) {
    //   String phone = '09${ValueRender.randomPhoneNumber()}';
    //
    //   FirebaseDatabaseService.set(
    //     User('user${i + 1}', phone, '123', ''),
    //     'users/user${i + 1}',
    //   );
    // }

    if (_formKey.currentState!.validate()) {
      context.read<AuthorBloc>().add(
            OnLoginEvent(
              _phoneNumberTextEditingController.text,
              _passwordTextEditingController.text,
            ),
          );
    }
  }

  void _onPressedRegisterButton(bool isShipper) {
    context.router.pushWidget(RegisterScreen(isShipper: isShipper));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FirebaseMessageService(context).initNotifications();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.size),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: BlocListener<AuthorBloc, AuthorState>(
            listener: (context, state) {
              if (state is AuthorLoggedInState) {
                context.router.pushNamed(AppRouterPath.googleMap);
              } else if (state is AuthorErrorState) {
                UiRender.showSnackBar(context, state.message);
              }
            },
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  50.verticalSpace,
                  Text(
                    'Giao Nhận Nhanh, Thanh Toán Đúng',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.size,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    'Hotline: 09190707386',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.size,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  10.verticalSpace,
                  Text(
                    'Email: abc@gmail.com',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.size,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  20.verticalSpace,
                  Image.asset('assets/images/LoGo.png'),
                  20.verticalSpace,
                  _customTextField(
                    controller: _phoneNumberTextEditingController,
                    hintText: 'Số điện thoại',
                    additionalValidator: _phoneNumberAndPasswordValidator,
                  ),
                  _customTextField(
                    controller: _passwordTextEditingController,
                    hintText: 'Mật khẩu',
                    isPassword: true,
                    isObscure: _isPasswordObscure,
                  ),
                  GradientElevatedButton(
                    text: 'Đăng nhập',
                    buttonHeight: 50.height,
                    onPress: _onPressedLoginButton,
                  ),
                  10.verticalSpace,
                  TextButton(
                    onPressed: () => _onPressedRegisterButton(true),
                    child: const Text(
                      'Đăng ký dành cho Shipper',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _onPressedRegisterButton(false),
                    child: const Text(
                      'Đăng ký dành cho Khách hàng',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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
                  icon: Icon(
                    isObscure
                        ? Icons.remove_red_eye
                        : Icons.remove_red_eye_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: _onPressPasswordEyeButton,
                ),
        ],
      ),
    );
  }
}
