import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import '../widgets/calorie_calendar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<DateTime, CalorieData> _mockCalorieData;

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    _mockCalorieData = {};
    final today = DateTime.now();

    // Mock data for current month with realistic patterns
    final mockData = {
      1: {"consumed": 1850, "target": 2000}, // 92.5% - Perfect
      2: {"consumed": 2100, "target": 2000}, // 105% - Perfect
      3: {"consumed": 1950, "target": 2000}, // 97.5% - Perfect
      4: {"consumed": 2600, "target": 2000}, // 130% - Way Over (Weekend)
      5: {"consumed": 2400, "target": 2000}, // 120% - Over (Weekend)
      6: {"consumed": 1800, "target": 2000}, // 90% - Perfect
      7: {"consumed": 1750, "target": 2000}, // 87.5% - Perfect
      8: {"consumed": 1650, "target": 2000}, // 82.5% - Under
      9: {"consumed": 1900, "target": 2000}, // 95% - Perfect
      10: {"consumed": 2050, "target": 2000}, // 102.5% - Perfect
      11: {"consumed": 2500, "target": 2000}, // 125% - Over (Weekend)
      12: {"consumed": 2300, "target": 2000}, // 115% - Over (Weekend)
      13: {"consumed": 1800, "target": 2000}, // 90% - Perfect
      14: {"consumed": 1700, "target": 2000}, // 85% - Perfect
      15: {"consumed": 1600, "target": 2000}, // 80% - Under
      16: {"consumed": 2200, "target": 2000}, // 110% - Perfect
      17: {"consumed": 1950, "target": 2000}, // 97.5% - Perfect
      18: {"consumed": 2700, "target": 2000}, // 135% - Way Over (Weekend)
      19: {"consumed": 2450, "target": 2000}, // 122.5% - Over (Weekend)
      20: {"consumed": 1850, "target": 2000}, // 92.5% - Perfect
      21: {"consumed": 1900, "target": 2000}, // 95% - Perfect
      22: {"consumed": 1750, "target": 2000}, // 87.5% - Perfect
      23: {"consumed": 1650, "target": 2000}, // 82.5% - Under
      24: {"consumed": 2000, "target": 2000}, // 100% - Perfect
      25: {"consumed": 2550, "target": 2000}, // 127.5% - Over (Weekend)
      26: {"consumed": 2350, "target": 2000}, // 117.5% - Over (Weekend)
      27: {"consumed": 1800, "target": 2000}, // 90% - Perfect
      28: {"consumed": 1950, "target": 2000}, // 97.5% - Perfect
      29: {"consumed": 1700, "target": 2000}, // 85% - Perfect
      30: {"consumed": 2150, "target": 2000}, // 107.5% - Perfect
      today.day: {"consumed": 1900, "target": 2000}, // 95% - Perfect (Today)
    };

    mockData.forEach((day, data) {
      final date = DateTime(today.year, today.month, day);
      final consumed = data["consumed"]!.toDouble();
      final target = data["target"]!.toDouble();
      final status = CalorieCalculator.calculateStatus(consumed, target);
      final progress = CalorieCalculator.calculateProgress(consumed, target);

      _mockCalorieData[date] = CalorieData(
        date: date,
        consumedCalories: consumed,
        targetCalories: target,
        status: status,
        progress: progress,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ยินดีต้อนรับ',
            style: AppTextStyle.headlineMedium(context),
          ),
          SizedBox(height: 16.0),
          CalorieCalendarWidget(
            calorieData: _mockCalorieData,
            selectedDay: DateTime.now(),
            onDaySelected: (date) {
              // TODO: จัดการเมื่อผู้ใช้เลือกวัน
            },
          ),
        ],
      ),
    );
  }
}
