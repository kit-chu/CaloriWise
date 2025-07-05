import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'widgets/app_top_bar.dart';

class CaloriWiseApp extends StatelessWidget {
  const CaloriWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalorieWiseApp',
      theme: AppTheme.lightTheme.copyWith(
        appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
          elevation: 0,
        ),
      ),
      builder: (context, child) {
        return Scaffold(
          appBar: const AppTopBar(title: 'Calories Wise',streakDays:2),
          body: child,
        );
      },
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
