import 'package:flutter_screenutil/flutter_screenutil.dart';

const bool isPhone = true;

extension NumberFormatAndDeviceSizeScale on num {
  double get width => isPhone ? w : this * 1;

  double get height => isPhone ? h : this * 1;

  double get size => isPhone ? sp : this * 1;

  double get radius => isPhone ? r : this * 1;

  String get formatMoney {
    String str = toStringAsFixed(0).toString();
    List<int> commaPos = [3, 7, 12, 18];

    for (int pos in commaPos) {
      if (pos < str.length) {
        int length = str.length;
        str =
            '${str.substring(0, length - pos)},${str.substring(length - pos)}';
      } else {
        break;
      }
    }

    return str;
  }

  String get format {
    String str = toStringAsFixed(2).toString();
    List<int> commaPos = [3, 7, 12, 18];
    bool hasDecimal = this % 1 != 0;

    int dotIndex = str.indexOf('.');
    String startAtDot = str.substring(dotIndex);
    String beforeDot = str.substring(0, dotIndex);

    for (int pos in commaPos) {
      if (pos < beforeDot.length) {
        int length = beforeDot.length;
        beforeDot =
            '${beforeDot.substring(0, length - pos)},${beforeDot.substring(length - pos)}';
      } else {
        break;
      }
    }

    return hasDecimal ? beforeDot + startAtDot : beforeDot;
  }
}
