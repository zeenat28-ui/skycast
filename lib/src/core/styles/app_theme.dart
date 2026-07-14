import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF35A2FF),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
    textTheme: Typography.blackMountainView.copyWith(
      bodyLarge: const TextStyle(fontSize: 16, height: 1.4),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.4),
      titleLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF090B12),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF35A2FF),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
    textTheme: Typography.whiteMountainView.copyWith(
      bodyLarge: const TextStyle(fontSize: 16, height: 1.4),
      bodyMedium: const TextStyle(fontSize: 14, height: 1.4),
      titleLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    ),
  );
}
