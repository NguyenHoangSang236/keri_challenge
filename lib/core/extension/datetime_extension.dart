import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension FormatDateTime on DateTime {
  String get date => DateFormat('dd-MM-yyyy').format(this);
  String get dateApiFormat => DateFormat('yyyy-MM-dd').format(this);
  DateTime get dateOnly => DateUtils.dateOnly(this);
  String get dateTime => DateFormat('HH:mm   dd-MM-yyyy').format(this);
  String get time => DateFormat('HH:mm').format(this);
}
