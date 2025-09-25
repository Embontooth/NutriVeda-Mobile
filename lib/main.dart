import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';
import 'package:nutriveda_mobile/screens/login_screen.dart';

void main() {
  runApp(const NutriVedaApp());
}

class NutriVedaApp extends StatelessWidget {
  const NutriVedaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriVeda Mobile',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}