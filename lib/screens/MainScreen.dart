import 'package:calori_wise_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_theme.dart';
import '../widgets/app_top_bar.dart';
import 'achievements_screen.dart';
import 'analytics_screen.dart';
import 'exercise_calculator_screen.dart';
import 'homeScreen/bloc/home_screen_bloc.dart';
import 'homeScreen/home_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    BlocProvider(
      create: (context) => HomeScreenBloc(),
      child: const HomeScreen(),
    ),
    const ExerciseCalculatorScreen(), // ออกกำลังกาย
    const AnalyticsScreen(), // Combined การวิเคราะห์ + AI Chat
    const AchievementsScreen(), // เป้าหมาย + รางวัล
    const ProfileScreen(), // โปรไฟล์
  ];

  final List<String> _titles = [
    'หน้าแรก',
    'ออกกำ',
    'วิเคราะห์',
    'เป้าหมาย',
    'โปรไฟล์',
  ];

  final List<IconData> _icons = [
    Icons.home,
    // Icons.fitness_center,
    Icons.analytics,
    // Icons.emoji_events,
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
        title: "Calorie",
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
              color: Colors.black.withOpacity(0.1),
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
