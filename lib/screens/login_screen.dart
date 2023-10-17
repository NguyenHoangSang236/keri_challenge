import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/authorization/author_bloc.dart';
import 'package:keri_challenge/components/gradient_button.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/util/ui_render.dart';

import '../services/firebase_message_service.dart';

@RoutePage()
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userNameTextEditingController =
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
      return 'Please enter some text';
    } else if (additionalValidator != null) {
      return additionalValidator(value);
    }
    return null;
  }

  final String? Function(String?) _userNameAndPasswordValidator =
      (String? value) {
    if (value!.trim().contains(' ')) {
      return 'User name and password can not contain space';
    }

    return null;
  };

  void _onPressPasswordEyeButton() {
    setState(() {
      _isPasswordObscure = !_isPasswordObscure;
    });
  }

  void _onPressedLoginButton() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthorBloc>().add(
            OnLoginEvent(
              _userNameTextEditingController.text,
              _passwordTextEditingController.text,
            ),
          );
    }
  }

  void _onPressedRegisterButton() {
    context.router.pushNamed(AppRouterPath.register);
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
                  Text(
                    'Sign in',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 25.size,
                      color: Colors.orange,
                    ),
                  ),
                  20.verticalSpace,
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
                  ),
                  GradientElevatedButton(
                    text: 'Login',
                    buttonHeight: 50.height,
                    onPress: _onPressedLoginButton,
                  ),
                  TextButton(
                    onPressed: _onPressedRegisterButton,
                    child: const Text(
                      'Register an account',
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
                  icon: Icon(
                    isObscure
                        ? Icons.remove_red_eye
                        : Icons.remove_red_eye_outlined,
                  ),
                  onPressed: _onPressPasswordEyeButton,
                ),
        ],
      ),
    );
  }
}
