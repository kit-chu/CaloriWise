import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/exercise_calculator_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/achievements_screen.dart';
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
    const HomeScreen(), // Combined หน้าแรก + บันทึกอาหาร
    const AnalyticsScreen(), // Combined การวิเคราะห์ + AI Chat
    const AchievementsScreen(), // เป้าหมาย + รางวัล
    const ExerciseCalculatorScreen(), // ออกกำลังกาย
    const ProfileScreen(), // โปรไฟล์
  ];

  final List<String> _titles = [
    'หน้าแรก',
    'วิเคราะห์',
    'เป้าหมาย',
    'ออกกำ',
    'โปรไฟล์',
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.analytics,
    Icons.emoji_events,
    Icons.fitness_center,
    Icons.person,
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
        streakDays: 5, // ค่าตัวอย่าง - สามารถเปลี่ยนเป็น dynamic ได้
        heartRate: 75, // ค่าตัวอย่าง - สามารถเปลี่ยนเป็น dynamic ได้
        onSettingsTap: () {
          // TODO: เพิ่มฟังก์ชันการตั้งค่า
        },
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryPurple,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
          ),
          items: List.generate(
            _icons.length,
            (index) => BottomNavigationBarItem(
              icon: Icon(_icons[index]),
              label: _titles[index],
            ),
          ),
        ),
      ),
    );
  }
}
