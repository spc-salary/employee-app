import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overtime_calculator/src/app_theme.dart';
import 'package:overtime_calculator/src/calculator_screen.dart';

void main() {
  runApp(const OvertimeCalculatorApp());
}

class OvertimeCalculatorApp extends StatefulWidget {
  const OvertimeCalculatorApp({super.key});

  @override
  State<OvertimeCalculatorApp> createState() => _OvertimeCalculatorAppState();
}

class _OvertimeCalculatorAppState extends State<OvertimeCalculatorApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حاسبة الإضافي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      locale: const Locale('ar'),
      supportedLocales: const <Locale>[Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: CalculatorScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
