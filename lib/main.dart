import 'package:casinoapp/assets/themedata.dart';
import 'package:casinoapp/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casino Bernard',
      theme: dataTheme,
      home: const HomePage(),
    );
  }
}
