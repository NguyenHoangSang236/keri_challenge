import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';

extension SpaceWidget on double {
  Widget get horizontalSpace => SizedBox(height: width);
  Widget get verticalSpace => SizedBox(height: height);
}
