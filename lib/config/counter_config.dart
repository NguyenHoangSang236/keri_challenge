import 'package:counter/counter.dart';
import 'package:flutter/material.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';

class CounterConfig implements Configuration {
  final BuildContext context;

  CounterConfig(this.context);

  @override
  double get size => 22.size;

  @override
  double get fontSize => 15.size;

  @override
  Color? get textColor => Colors.black;

  @override
  Color? get textBackgroundColor => Colors.transparent;

  @override
  double get textWidth => 40.width;

  @override
  IconStyle get iconStyle => IconStyle.add_minus_bold;

  @override
  Color? get iconColor => Theme.of(context).colorScheme.primary;

  @override
  Color? get disableColor => Theme.of(context).colorScheme.error;

  @override
  Color? get backgroundColor => Colors.transparent;

  @override
  double? get iconBorderWidth => null;

  @override
  double? get iconBorderRadius => size / 2;
}
