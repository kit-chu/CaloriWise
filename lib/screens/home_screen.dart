import 'package:flutter/material.dart';
import '../models/macro_data.dart';
import '../models/food_log.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import '../utils/date_formatter.dart';
import '../widgets/calorie_calendar_widget.dart';
import '../widgets/macro_tracking_card.dart';
import '../widgets/recent_food_logs.dart';
import '../widgets/painters/multi_color_circular_progress_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map<DateTime, CalorieData> _mockCalorieData;
  late List<FoodLog> _mockRecentFoodLogs;
  late DateTime _selectedDay;

  // เพิ่ม mock data สำหรับ Macro
  late MacroData _mockMacroData;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _generateMockData();
    _generateMockMacroData();
    _generateMockFoodLogs();
  }

  void _generateMockData() {
    _mockCalorieData = {};
    final today = DateTime.now();
    final lastMonth = DateTime(today.year, today.month - 1);

    // Mock data for previous month with varied percentages
    final previousMonthData = {
      25: {"consumed": 1600, "target": 2000}, // 80% - Under (Red)
      26: {"consumed": 1850, "target": 2000}, // 92.5% - Perfect (Green)
      27: {"consumed": 2400, "target": 2000}, // 120% - Over (Orange)
      28: {"consumed": 2800, "target": 2000}, // 140% - Way Over (Dark Red)
      29: {"consumed": 1700, "target": 2000}, // 85% - Perfect (Green)
      30: {"consumed": 2200, "target": 2000}, // 110% - Over (Orange)
    };

    // Mock data for current month with varied percentages
    final currentMonthData = {
      1: {"consumed": 1600, "target": 2000},
      2: {"consumed": 2600, "target": 2000},
      3: {"consumed": 1900, "target": 2000},
      4: {"consumed": 2200, "target": 2000},
      5: {"consumed": 1700, "target": 2000},
      6: {"consumed": 2400, "target": 2000},
      7: {"consumed": 1650, "target": 2000},
      8: {"consumed": 1800, "target": 2000},
      9: {"consumed": 2300, "target": 2000},
      10: {"consumed": 1950, "target": 2000},
      11: {"consumed": 2100, "target": 2000},
      12: {"consumed": 1850, "target": 2000},
      13: {"consumed": 2250, "target": 2000},
      14: {"consumed": 1750, "target": 2000},
      15: {"consumed": 2050, "target": 2000},
      // เพิ่มข้อมูลถึงวันปัจจุบัน
      today.day: {"consumed": 1800, "target": 2000},
    };

    // Add previous month data
    previousMonthData.forEach((day, data) {
      final date = DateTime(lastMonth.year, lastMonth.month, day);
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

    // Add current month data
    currentMonthData.forEach((day, data) {
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

  void _generateMockMacroData() {
    _mockMacroData = MacroData(
      protein: 40,
      carbs: 286,
      fat: 22,
      proteinGoal: 150,
      carbsGoal: 300,
      fatGoal: 65,
    );
  }

  void _generateMockFoodLogs() {
    _mockRecentFoodLogs = [
      FoodLog(
        name: 'Bruschetta with egg',
        imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?ixlib=rb-4.0.3',
        calories: 250,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        protein: 30.0,
        carbs: 55.0,
        fat: 8.0,
      ),
      FoodLog(
        name: 'Salmon toast',
        imageUrl: 'https://images.unsplash.com/photo-1546039907-7fa05f864c02?ixlib=rb-4.0.3',
        calories: 320,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        protein: 28.0,
        carbs: 42.0,
        fat: 12.0,
      ),
      FoodLog(
        name: 'Greek Salad',
        imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-4.0.3',
        calories: 180,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        protein: 12.0,
        carbs: 24.0,
        fat: 6.0,
      ),
      FoodLog(
        name: 'Grilled Chicken',
        imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?ixlib=rb-4.0.3',
        calories: 350,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        protein: 45.0,
        carbs: 15.0,
        fat: 10.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // ใช้เฉพาะวันที่ (ไม่รวมเวลา) เพื่อให้ตรงกับข้อมูลใน _mockCalorieData
    final selectedDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedData = _mockCalorieData[selectedDate];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile section with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryPurple,
                    AppTheme.primaryPurple.withAlpha(204), // 0.8 opacity
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withAlpha(230), // 0.9 opacity
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ยินดีต้อนรับ',
                              style: AppTextStyle.titleSmall(context).copyWith(
                                color: Colors.white.withAlpha(230), // 0.9 opacity
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'คุณ แคลอรี่ไวส์',
                              style: AppTextStyle.headlineSmall(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51), // 0.2 opacity
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Handle notification tap
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CalorieCalendarWidget(
                    calorieData: _mockCalorieData,
                    selectedDay: _selectedDay,
                    onDaySelected: (date) {
                      setState(() {
                        _selectedDay = date;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  MacroTrackingCard(data: _mockMacroData),
                  const SizedBox(height: 16.0),
                  _buildSelectedDayInfo(selectedData),
                  const SizedBox(height: 24.0),
                  RecentFoodLogs(logs: _mockRecentFoodLogs),
                  const SizedBox(height: 32.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayInfo(CalorieData? data) {
    final bool hasData = data != null;
    final statusColor = hasData ? _getProgressColor(data.status) : Colors.grey[400]!;

    // คำนวณสัดส่วนของ macro nutrients
    final macroColors = [
      const Color(0xFF10B981), // Protein - Green
      const Color(0xFFF59E0B), // Carbs - Orange
      const Color(0xFF7C3AED), // Fat - Purple
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Circular progress indicator with fire icon
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: CustomPaint(
                      painter: MultiColorCircularProgressPainter(
                        colors: macroColors,
                        strokeWidth: 8,
                        percent: hasData ? data.progress.clamp(0.0, 1.0) : 0,
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(26), // 0.1 opacity
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.local_fire_department,
                            color: statusColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Calories info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.getFullDate(_selectedDay),
                      style: AppTextStyle.titleSmall(context).copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (hasData) ...[
                      Text(
                        '${(data.targetCalories - data.consumedCalories).abs().toInt()} kcal',
                        style: AppTextStyle.headlineMedium(context).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        data.targetCalories - data.consumedCalories >= 0
                            ? 'คงเหลือวันนี้'
                            : 'เกินวันนี้',
                        style: AppTextStyle.titleSmall(context).copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'ไม่มีข้อมูลแคลอรี่',
                        style: AppTextStyle.headlineMedium(context).copyWith(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'กรุณาเพิ่มข้อมูลแคลอรี่สำหรับวันนี้',
                        style: AppTextStyle.titleSmall(context).copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status or Add button
          if (hasData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(26), // 0.1 opacity
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getStatusText(data.percentage),
                style: AppTextStyle.titleSmall(context).copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            InkWell(
              onTap: () {
                // TODO: Handle add data
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withAlpha(26), // 0.1 opacity
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'เพิ่มข้อมูลแคลอรี่',
                      style: AppTextStyle.titleSmall(context).copyWith(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Calorie details cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  label: 'บริโภคแล้ว',
                  value: hasData ? '${data.consumedCalories.toInt()}' : '0',
                  unit: 'kcal',
                  icon: Icons.local_fire_department,
                  color: hasData ? AppTheme.primaryCoral : Colors.grey[400]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  label: 'เป้าหมาย',
                  value: hasData ? '${data.targetCalories.toInt()}' : '2000',
                  unit: 'kcal',
                  icon: Icons.flag,
                  color: hasData ? AppTheme.primaryPurple : Colors.grey[400]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(double percentage) {
    if (percentage < 85) {
      return 'ต่ำกว่าเป้าหมาย';
    } else if (percentage <= 110) {
      return 'อยู่ในเกณฑ์ที่ดี';
    } else if (percentage <= 130) {
      return 'เกินเล็กน้อย';
    } else {
      return 'เกินมาก';
    }
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // 0.1 opacity
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.labelMedium(context).copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '$value $unit',
                style: AppTextStyle.titleMedium(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(CalorieStatus status) {
    switch (status) {
      case CalorieStatus.under:
        return const Color(0xFFEF4444); // Red
      case CalorieStatus.perfect:
        return const Color(0xFF10B981); // Green
      case CalorieStatus.over:
        return const Color(0xFFF59E0B); // Orange
      case CalorieStatus.wayOver:
        return const Color(0xFFDC2626); // Dark Red
      case CalorieStatus.noData:
        return Colors.grey[400]!;
    }
  }
}
