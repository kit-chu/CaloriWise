import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
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

  // สร้าง list ของหน้าต่างๆ
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Chat AI')), // TODO: สร้างหน้า Chat AI
    const Center(child: Text('Camera')), // TODO: สร้างหน้ากล้อง
    const Center(child: Text('Add')), // TODO: สร้างหน้าเพิ่มรายการ
    const Center(child: Text('History')), // TODO: สร้างหน้าประวัติ
  ];

  // สร้าง list ของชื่อหน้าต่างๆ
  final List<String> _titles = [
    'Calories Wise',
    'Chat AI',
    'ถ่ายรูปอาหาร',
    'เพิ่มรายการ',
    'ชุมชนแคลอรี่',
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
