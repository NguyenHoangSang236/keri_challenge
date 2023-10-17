import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/main.dart';
import 'package:keri_challenge/util/ui_render.dart';

import '../bloc/authorization/author_bloc.dart';
import '../components/gradient_button.dart';
import '../entities/user.dart' as custom_user;
import '../util/value_render.dart';

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
      return 'Please enter verification code';
    } else if (value.length != 6) {
      return 'Verification code must be 6-digit number';
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
            OnRegisterEvent(
              widget.user.name,
              widget.user.password,
              widget.user.phoneNumber,
            ),
          );

          UiRender.showSnackBar(
            context,
            'Welcome to Keri application, please login to enjoy!',
          );
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Phone verification',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 25.size,
                  color: Colors.orange,
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
                          hintText: 'Input verification code from SMS here...',
                          border: InputBorder.none,
                        ),
                        validator: _textFieldValidator,
                      ),
                    ),
                  ],
                ),
              ),
              GradientElevatedButton(
                text: 'Verify',
                buttonHeight: 50.height,
                onPress: _onPressVerifyButton,
              ),
              TextButton(
                onPressed: _onPressResendButton,
                child: const Text(
                  'Have not received any SMS yet?',
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
