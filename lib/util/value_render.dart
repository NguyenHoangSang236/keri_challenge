import 'dart:math';

class ValueRender {
  ValueRender._();

  static final instance = ValueRender._();

  String? verificationId;

  static String randomPhoneNumber() {
    const chars = '1234567890';
    Random rnd = Random();

    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(
          rnd.nextInt(chars.length),
        ),
      ),
    );
  }
}
