import 'dart:async';
import 'dart:math';
import 'package:calori_wise_app/screens/homeScreen/request/homeScreenReuest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/macro_data.dart';
import '../../models/food_log.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/calorie_calendar_widget.dart';
import '../../widgets/macro_tracking_card.dart';
import '../../widgets/painters/multi_color_circular_progress_painter.dart';
import '../../widgets/recent_food_logs.dart';
import '../../widgets/painters/heart_rate_graph_painter.dart';
import '../add_food_screen.dart';
import 'bloc/home_screen_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Map<DateTime, CalorieData> _mockCalorieData;
  late List<FoodLog> _mockRecentFoodLogs;
  late DateTime _selectedDay;
  late MacroData _mockMacroData;
  static const String nameScreen = "HomeScreen";
  // Tab Controller สำหรับ Bottom Navigation - เปลี่ยนจาก 3 เป็น 4 แท็บ
  late TabController _tabController;

  // Animation controller สำหรับ effect หัวใจ
  late AnimationController _heartbeatController;
  late Animation<double> _heartbeatAnimation;

  // สถานะการเชื่อมต่อและข้อมูลอัตราการเต้นหัวใจ
  bool _isHeartRateConnected = false;
  Timer? _heartRateTimer;
  List<int> _mockHeartRates = [];
  int _currentHeartRate = 0;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _tabController = TabController(length: 3, vsync: this);
    _generateMockData();
    _generateMockMacroData();
    _generateMockFoodLogs();
    _setupHeartRateMockData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = HomeScreenRequest(collection: nameScreen, version: 0.3);
      context.read<HomeScreenBloc>().add(FetchHomeScreenItems(request: request));
    });

    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _heartbeatAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartbeatController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _setupHeartRateMockData() {
    _isHeartRateConnected = Random().nextDouble() < 0.7;

    if (_isHeartRateConnected) {
      _mockHeartRates = List.generate(30, (index) {
        double baseRate = 75.0;
        double amplitude = 10.0;
        double frequency = 0.3;
        double sineValue = baseRate + amplitude * sin(frequency * index);
        double randomNoise = (Random().nextDouble() * 4) - 2;
        return (sineValue + randomNoise).round();
      });
      _currentHeartRate = _mockHeartRates.last;

      _heartRateTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (mounted) {
          setState(() {
            double time = timer.tick * 0.3;
            double newRate = 75.0 + 10.0 * sin(time) + (Random().nextDouble() * 4) - 2;
            _mockHeartRates.removeAt(0);
            _mockHeartRates.add(newRate.round());
            _currentHeartRate = _mockHeartRates.last;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _heartRateTimer?.cancel();
    _heartbeatController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _generateMockData() {
    _mockCalorieData = {};
    final today = DateTime.now();
    final lastMonth = DateTime(today.year, today.month - 1);

    final previousMonthData = {
      25: {"consumed": 1600, "target": 2000},
      26: {"consumed": 1850, "target": 2000},
      27: {"consumed": 2400, "target": 2000},
      28: {"consumed": 2800, "target": 2000},
      29: {"consumed": 1700, "target": 2000},
      30: {"consumed": 2200, "target": 2000},
    };

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
      today.day: {"consumed": 1800, "target": 2000},
    };

    // Add data to _mockCalorieData
    [...previousMonthData.entries, ...currentMonthData.entries].forEach((entry) {
      final day = entry.key;
      final data = entry.value;
      final date = day <= 31 && day > 20 ? DateTime(lastMonth.year, lastMonth.month, day) : DateTime(today.year, today.month, day);
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
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        protein: 28.0,
        carbs: 42.0,
        fat: 12.0,
      ),
      FoodLog(
        name: 'Greek Salad',
        imageUrl: 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?ixlib=rb-4.0.3',
        calories: 180,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        protein: 12.0,
        carbs: 24.0,
        fat: 6.0,
      ),
      FoodLog(
        name: 'Grilled Chicken',
        imageUrl: 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?ixlib=rb-4.0.3',
        calories: 350,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        protein: 45.0,
        carbs: 15.0,
        fat: 10.0,
      ),
      FoodLog(
        name: 'Avocado Toast',
        imageUrl: 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?ixlib=rb-4.0.3',
        calories: 280,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        protein: 8.0,
        carbs: 32.0,
        fat: 18.0,
      ),
      FoodLog(
        name: 'Protein Smoothie',
        imageUrl: 'https://images.unsplash.com/photo-1570197788417-0e82375c9371?ixlib=rb-4.0.3',
        calories: 220,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        protein: 25.0,
        carbs: 28.0,
        fat: 4.0,
      ),
      FoodLog(
        name: 'Quinoa Bowl',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3',
        calories: 420,
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        protein: 18.0,
        carbs: 65.0,
        fat: 12.0,
      ),
      FoodLog(
        name: 'Chicken Caesar Salad',
        imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?ixlib=rb-4.0.3',
        calories: 380,
        timestamp: DateTime.now().subtract(const Duration(hours: 7)),
        protein: 32.0,
        carbs: 18.0,
        fat: 22.0,
      ),
      FoodLog(
        name: 'Oatmeal with Berries',
        imageUrl: 'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?ixlib=rb-4.0.3',
        calories: 240,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        protein: 8.0,
        carbs: 48.0,
        fat: 4.0,
      ),
      FoodLog(
        name: 'Tuna Sandwich',
        imageUrl: 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?ixlib=rb-4.0.3',
        calories: 340,
        timestamp: DateTime.now().subtract(const Duration(hours: 9)),
        protein: 24.0,
        carbs: 38.0,
        fat: 14.0,
      ),
      FoodLog(
        name: 'Vegetable Stir Fry',
        imageUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3',
        calories: 190,
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        protein: 8.0,
        carbs: 28.0,
        fat: 6.0,
      ),
      FoodLog(
        name: 'Beef Steak',
        imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?ixlib=rb-4.0.3',
        calories: 450,
        timestamp: DateTime.now().subtract(const Duration(hours: 11)),
        protein: 42.0,
        carbs: 8.0,
        fat: 28.0,
      ),
      FoodLog(
        name: 'Banana Smoothie Bowl',
        imageUrl: 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?ixlib=rb-4.0.3',
        calories: 310,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        protein: 12.0,
        carbs: 58.0,
        fat: 8.0,
      ),
      FoodLog(
        name: 'Fish and Chips',
        imageUrl: 'https://images.unsplash.com/photo-1579952363873-27d3bfad9c0d?ixlib=rb-4.0.3',
        calories: 520,
        timestamp: DateTime.now().subtract(const Duration(hours: 13)),
        protein: 28.0,
        carbs: 45.0,
        fat: 26.0,
      ),
      FoodLog(
        name: 'Veggie Burger',
        imageUrl: 'https://images.unsplash.com/photo-1525059696034-4967a729002e?ixlib=rb-4.0.3',
        calories: 290,
        timestamp: DateTime.now().subtract(const Duration(hours: 14)),
        protein: 15.0,
        carbs: 35.0,
        fat: 12.0,
      ),
      FoodLog(
        name: 'Thai Green Curry',
        imageUrl: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?ixlib=rb-4.0.3',
        calories: 380,
        timestamp: DateTime.now().subtract(const Duration(hours: 15)),
        protein: 22.0,
        carbs: 35.0,
        fat: 18.0,
      ),
      FoodLog(
        name: 'Chocolate Protein Bar',
        imageUrl: 'https://images.unsplash.com/photo-1511690656952-34342bb7c2f2?ixlib=rb-4.0.3',
        calories: 190,
        timestamp: DateTime.now().subtract(const Duration(hours: 16)),
        protein: 20.0,
        carbs: 22.0,
        fat: 6.0,
      ),
      FoodLog(
        name: 'Sushi Roll Set',
        imageUrl: 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?ixlib=rb-4.0.3',
        calories: 420,
        timestamp: DateTime.now().subtract(const Duration(hours: 17)),
        protein: 24.0,
        carbs: 65.0,
        fat: 8.0,
      ),
      FoodLog(
        name: 'Pasta Carbonara',
        imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d946?ixlib=rb-4.0.3',
        calories: 580,
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        protein: 28.0,
        carbs: 68.0,
        fat: 22.0,
      ),
      FoodLog(
        name: 'Fresh Fruit Salad',
        imageUrl: 'https://images.unsplash.com/photo-1511690743698-d9d85f2fbf38?ixlib=rb-4.0.3',
        calories: 120,
        timestamp: DateTime.now().subtract(const Duration(hours: 19)),
        protein: 2.0,
        carbs: 32.0,
        fat: 1.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: BlocConsumer<HomeScreenBloc, HomeScreenState>(
        listener: (context, state) {
          if (state is HomeScreenError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeScreenLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // สามารถเพิ่มการเช็ค state อื่น ๆ ได้ตามต้องการ
          return Column(
            children: [
              // Tab Bar
              SafeArea(
                bottom: false,
                child: _buildTabBar(),
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildNutritionTab(),
                    _buildFoodLogTab(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final selectedDate = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedData = _mockCalorieData[selectedDate];
    final hasData = selectedData != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryPurple.withAlpha(204),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Profile Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withAlpha(230),
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ยินดีต้อนรับ',
                          style: AppTextStyle.titleSmall(context).copyWith(
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                        Text(
                          'คุณ แคลอรี่ไวส์',
                          style: AppTextStyle.titleLarge(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            // Today's Summary Card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Main Calorie Display
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'วันนี้',
                          style: AppTextStyle.titleSmall(context).copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (hasData) ...[
                          Text(
                            '${selectedData.consumedCalories.toInt()}',
                            style: AppTextStyle.headlineLarge(context).copyWith(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'จาก ${selectedData.targetCalories.toInt()} kcal',
                            style: AppTextStyle.bodyMedium(context).copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ] else ...[
                          Text(
                            '0',
                            style: AppTextStyle.headlineLarge(context).copyWith(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'จาก 2000 kcal',
                            style: AppTextStyle.bodyMedium(context).copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Circular Progress
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: hasData ? selectedData.progress.clamp(0.0, 1.0) : 0,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            hasData ? _getProgressColor(selectedData.status) : Colors.grey[400]!,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.local_fire_department,
                        color: hasData ? _getProgressColor(selectedData.status) : Colors.grey[400],
                        size: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryPurple,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppTheme.primaryPurple,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'ภาพรวม'),
          Tab(text: 'โภชนาการ'),
          Tab(text: 'บันทึกอาหาร'), // เพิ่มแท็บใหม่
        ],
      ),
    );
  }

  // Tab 1: ภาพรวม - แคลอรี่และกิจกรรมล่าสุด
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          _buildHeader(),
          // Content with padding
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Quick Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStatCard(
                        'เผาผลาญ',
                        '320 kcal',
                        Icons.fitness_center,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStatCard(
                        'เหลือ',
                        '1200 kcal',
                        Icons.flag,
                        AppTheme.primaryPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Recent Food Logs (Compact)
                _buildCompactFoodLogs(),
                const SizedBox(height: 16),
                // Calendar Widget (Smaller)
                CalorieCalendarWidget(
                  calorieData: _mockCalorieData,
                  selectedDay: _selectedDay,
                  onDaySelected: (date) {
                    setState(() {
                      _selectedDay = date;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 2: โภชนาการ - Macro แ������อาหาร
  Widget _buildNutritionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          MacroTrackingCard(data: _mockMacroData),
          const SizedBox(height: 16),
          RecentFoodLogs(logs: _mockRecentFoodLogs),
        ],
      ),
    );
  }

  // Tab 3: บันทึกอาหาร - เพิ่มอาหารและรายการอาหารที่บันทึกไว้
  Widget _buildFoodLogTab() {
    return Container(
      color: AppTheme.backgroundLight,
      child: Column(
        children: [
          // Quick Add Food Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddFoodScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline),
                  SizedBox(width: 8),
                  Text('เพิ่มอาหาร', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          // Food Log List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'รายการอาหารที่เพิ่ม',
                  style: AppTextStyle.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_mockRecentFoodLogs.length} รายกา���',
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Food Log List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _mockRecentFoodLogs.length,
              itemBuilder: (context, index) {
                final food = _mockRecentFoodLogs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        food.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      food.name,
                      style: AppTextStyle.titleSmall(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${food.calories} kcal',
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'โปรตีน: ${food.protein}g • คาร์บ: ${food.carbs}g • ไขมัน: ${food.fat}g',
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormatter.formatTimeAgo(food.timestamp),
                          style: AppTextStyle.bodySmall(context).copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.more_vert,
                          color: AppTheme.textSecondary,
                          size: 16,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Show food details or edit
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyle.titleLarge(context).copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFoodLogs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'อาหารล่าสุด',
                    style: AppTextStyle.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: Text(
                    'ดูทั้งหมด',
                    style: TextStyle(color: AppTheme.primaryPurple),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _mockRecentFoodLogs.take(3).length,
              itemBuilder: (context, index) {
                final food = _mockRecentFoodLogs[index];
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          food.imageUrl,
                          height: 60,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 60,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        food.name,
                        style: AppTextStyle.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${food.calories} kcal',
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeartRateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'อัตราการเต้นของหัวใจ',
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_isHeartRateConnected) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _heartbeatAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _heartbeatAnimation.value,
                      child: const Icon(
                        Icons.favorite,
                        color: AppTheme.primaryPurple,
                        size: 32,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Text(
                  '$_currentHeartRate',
                  style: AppTextStyle.headlineLarge(context).copyWith(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'BPM',
                  style: AppTextStyle.titleMedium(context).copyWith(
                    color: AppTheme.primaryPurple.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: CustomPaint(
                size: const Size(double.infinity, 100),
                painter: HeartRateGraphPainter(
                  points: _mockHeartRates.map((e) => e.toDouble()).toList(),
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_outline,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ไม่มีข้อมูลอ��ต��าการเต้นของหัวใจ',
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Connect device
                    },
                    child: const Text('เชื่อมต่ออุปกรณ์'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildHealthMetrics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตัวชี้วัดสุขภาพ',
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'น้ำหนัก',
                  '65 กก.',
                  Icons.monitor_weight,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'BMI',
                  '22.1',
                  Icons.health_and_safety,
                  Colors.teal,
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
        return const Color(0xFFEF4444);
      case CalorieStatus.perfect:
        return const Color(0xFF10B981);
      case CalorieStatus.over:
        return const Color(0xFFF59E0B);
      case CalorieStatus.wayOver:
        return const Color(0xFFDC2626);
      case CalorieStatus.noData:
        return Colors.grey[400]!;
    }
  }
}
