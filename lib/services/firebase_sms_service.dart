import 'package:firebase_auth/firebase_auth.dart';
import 'package:keri_challenge/core/extension/string%20_extension.dart';
import 'package:keri_challenge/util/value_render.dart';

import '../main.dart';

class FirebaseSmsService {
  static Future<void> verifyPhoneNumber(String phoneNumber) async {
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber.formatPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        print('Verification done!');
      },
      verificationFailed: (FirebaseAuthException e) {
        // print('@@@ verificationFailed');
        // print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        // print('@@@ codeSent');
        // print('verification id: $verificationId');
        // print('resend token: $resendToken');

        ValueRender.instance.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // print('@@@ codeAutoRetrievalTimeout');
        // print('time out verification id: $verificationId');
      },
    );
  }
}
