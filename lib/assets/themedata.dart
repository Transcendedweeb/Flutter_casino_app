import 'package:flutter/material.dart';

const ColorScheme appColorScheme = ColorScheme(
  primary: Color.fromARGB(255, 255, 255, 255),
  secondary: Colors.orange,
  surface: Color.fromARGB(255, 59, 59, 59),
  surfaceVariant: Colors.white,
  error: Color(0xFFCCCCCC),
  background: Color.fromARGB(255, 29, 29, 29),
  onPrimary: Colors.white,
  onSecondary: Color(0xFFFF0000),
  onSurface: Colors.orange,
  onBackground: Colors.white,
  onError: Color(0xFF333333),
  brightness: Brightness.dark,
);

final ThemeData dataTheme = ThemeData(
  colorScheme: appColorScheme,
  textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
      displayMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white),
      displaySmall: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white)),
  useMaterial3: true,
);
