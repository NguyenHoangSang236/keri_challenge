import 'package:flutter/material.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  colorScheme: const ColorScheme(
    primary: Color(0xFFE8B535),
    // primary text color
    secondary: Colors.white,
    onPrimary: Color(0xFFFED852),
    onSecondary: Colors.white,
    error: Color(0xFFF54018),
    onError: Colors.black,
    onBackground: Colors.white,
    background: Color(0xFFE3E3E8),
    brightness: Brightness.light,
    tertiary: Colors.grey,
    onTertiary: Colors.green,
    surface: Color(0xFFE0E1E5),
    onSurface: Colors.black,
  ),
);
