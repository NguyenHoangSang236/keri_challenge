import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/authorization/author_bloc.dart';
import 'package:keri_challenge/bloc/google_map/google_map_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/data/entities/app_config.dart';
import 'package:keri_challenge/data/enum/local_storage_enum.dart';
import 'package:keri_challenge/util/ui_render.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';
import 'package:keri_challenge/view/screens/register_screen.dart';

import '../../bloc/appConfig/app_config_bloc.dart';
import '../../services/local_storage_service.dart';

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
  bool _rememberPassword = false;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

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

  void _onChangeRememberPasswordCheckbox(bool? value) {
    setState(() {
      if (value == true &&
          (_phoneNumberTextEditingController.text != '' &&
              _passwordTextEditingController.text != '')) {
        LocalStorageService.setLocalStorageData(
          LocalStorageEnum.phoneNumber.name,
          _phoneNumberTextEditingController.text,
        );

        LocalStorageService.setLocalStorageData(
          LocalStorageEnum.password.name,
          _passwordTextEditingController.text,
        );

        _rememberPassword = true;

        LocalStorageService.setLocalStorageData(
          LocalStorageEnum.rememberLogin.name,
          _rememberPassword,
        );
      } else if (_phoneNumberTextEditingController.text == '' ||
          _passwordTextEditingController.text == '') {
        UiRender.showDialog(
          context,
          '',
          'Hãy điền đầy đủ số điện thoại và mật khẩu!',
        );
        _rememberPassword = false;
      } else {
        _rememberPassword = false;

        LocalStorageService.removeLocalStorageData(
          LocalStorageEnum.phoneNumber.name,
        );

        LocalStorageService.removeLocalStorageData(
          LocalStorageEnum.password.name,
        );

        LocalStorageService.removeLocalStorageData(
          LocalStorageEnum.rememberLogin.name,
        );
      }
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

    // User newAdmin = User(
    //   fullName: 'Nguyen Van A',
    //   birthYear: '1998',
    //   phoneNumber: '0321546789',
    //   sex: 'male',
    //   address: 'Ho chi minh',
    //   idCertificateNumber: '012365478965',
    //   password: '123',
    //   registerDate: DateTime.now(),
    // );
    //
    // FirebaseDatabaseService.getObjectMap(
    //   collection: 'users',
    //   document: '0321564897',
    // );
    // FirebaseDatabaseService.getObjectMapList(collection: 'users');
    // FirebaseDatabaseService.addData(
    //   data: newAdmin.toJson(),
    //   collection: 'admins',
    //   document: newAdmin.phoneNumber,
    // );

    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthorBloc>().add(
            OnLoginEvent(
              _phoneNumberTextEditingController.text,
              _passwordTextEditingController.text,
            ),
          );
    }
  }

  Future<void> _initLocalStorageValues() async {
    _phoneNumberTextEditingController.text =
        await LocalStorageService.getLocalStorageData(
      LocalStorageEnum.phoneNumber.name,
    ) as String;

    _passwordTextEditingController.text =
        await LocalStorageService.getLocalStorageData(
      LocalStorageEnum.password.name,
    ) as String;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (_phoneNumberTextEditingController.text != '' &&
            _passwordTextEditingController.text != '') {
          _rememberPassword = true;
        }
      });
    });
  }

  void _onPressedRegisterButton(bool isShipper) {
    context.router.pushWidget(RegisterScreen(isShipper: isShipper));
  }

  @override
  void initState() {
    _initLocalStorageValues();

    context.read<AppConfigBloc>().add(OnLoadAppConfigEvent());

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
                if (state.user.role == 'client') {
                  context.router.pushNamed(AppRouterPath.clientIndex);
                } else if (state.user.role == 'shipper') {
                  context.read<GoogleMapBloc>().add(
                        OnLoadCurrentLocationEvent(state.user.phoneNumber),
                      );
                  context.router.pushNamed(AppRouterPath.shipperIndex);
                } else if (state.user.role == 'admin') {}
              } else if (state is AuthorErrorState) {
                UiRender.showSnackBar(context, state.message);
              }
            },
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  50.verticalSpace,
                  Flexible(
                    child: BlocBuilder<AppConfigBloc, AppConfigState>(
                      builder: (context, state) {
                        AppConfig? appConfig =
                            context.read<AppConfigBloc>().appConfig;

                        if (state is AppConfigLoadingState) {
                          return UiRender.loadingCircle(context);
                        } else if (state is AppConfigLoadState) {
                          appConfig = state.appConfig;
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              appConfig?.slogan ?? 'UNDEFINED',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18.size,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            10.verticalSpace,
                            Text(
                              'Hotline: ${appConfig?.hotline}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.size,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            10.verticalSpace,
                            Text(
                              'Email: ${appConfig?.email}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.size,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  20.verticalSpace,
                  Flexible(
                    child: Image.asset('assets/images/LoGo.png'),
                  ),
                  20.verticalSpace,
                  _customTextField(
                    controller: _phoneNumberTextEditingController,
                    hintText: 'Số điện thoại',
                    additionalValidator: _phoneNumberAndPasswordValidator,
                    keyboardType: TextInputType.number,
                  ),
                  _customTextField(
                    controller: _passwordTextEditingController,
                    hintText: 'Mật khẩu',
                    isPassword: true,
                    isObscure: _isPasswordObscure,
                  ),
                  10.verticalSpace,
                  _rememberPasswordCheckBox('Ghi nhớ mật khẩu'),
                  10.verticalSpace,
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
              ),
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

  Widget _rememberPasswordCheckBox(String content) {
    return Row(
      children: [
        SizedBox(
          width: 24.width,
          height: 24.height,
          child: Checkbox(
            activeColor: Theme.of(context).colorScheme.secondary,
            checkColor: Theme.of(context).colorScheme.primary,
            value: _rememberPassword,
            onChanged: _onChangeRememberPasswordCheckbox,
          ),
        ),
        Text(
          ' $content',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15.size,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        )
      ],
    );
  }
}
