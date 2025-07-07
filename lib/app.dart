import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_food_screen.dart';
import 'screens/exercise_calculator_screen.dart';
import 'widgets/app_top_bar.dart';
import 'widgets/custom_bottom_nav.dart';

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
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AddFoodScreen(),
    const ExerciseCalculatorScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    'Calories Wise',
    'เพิ่มอาหาร',
    'คำนวณแคลอรี่',
    'Chat AI',
    'โปรไฟล์',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _titles[_currentIndex],
        streakDays: 2,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
