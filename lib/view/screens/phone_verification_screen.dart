import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/core/router/app_router_path.dart';
import 'package:keri_challenge/main.dart';
import 'package:keri_challenge/util/ui_render.dart';

import '../../bloc/authorization/author_bloc.dart';
import '../../data/entities/user.dart' as custom_user;
import '../../util/value_render.dart';
import '../../view/components/gradient_button.dart';

@RoutePage()
class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key, required this.user});

  final custom_user.User user;

  @override
  State<StatefulWidget> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _verificationCodeController =
      TextEditingController();

  void _onPressBackButton() {
    context.router.pop();
  }

  String? _textFieldValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hãy nhập mã OTP';
    } else if (value.length != 6) {
      return 'Mã xác thực phải có 6 chữ số';
    }
    return null;
  }

  void _onPressVerifyButton() async {
    if (_formKey.currentState!.validate()) {
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: ValueRender.instance.verificationId ?? '',
          smsCode: _verificationCodeController.text,
        );

        await auth.signInWithCredential(credential).then((value) {
          BlocProvider.of<AuthorBloc>(context).add(
            OnRegisterEvent(widget.user),
          );

          UiRender.showSnackBar(
            context,
            'Chào mừng bạn, xin hãy đăng nhập để sử dụng ứng dụng',
          );

          context.router.pushNamed(AppRouterPath.login);
        });
      } catch (e) {
        UiRender.showSnackBar(context, e.toString());
      }
    }
  }

  void _onPressResendButton() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onSecondary,
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
      ),
      body: Container(
        padding: EdgeInsets.all(10.size),
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Xác thực số điện thoại',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 25.size,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              20.verticalSpace,
              Container(
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
                        controller: _verificationCodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Nhập mã OTP từ tin nhăn điện thoại...',
                          border: InputBorder.none,
                        ),
                        validator: _textFieldValidator,
                      ),
                    ),
                  ],
                ),
              ),
              GradientElevatedButton(
                text: 'Xác thực',
                buttonHeight: 50.height,
                onPress: _onPressVerifyButton,
              ),
              TextButton(
                onPressed: _onPressResendButton,
                child: const Text(
                  'Chưa nhận mã?',
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
    );
  }
}
