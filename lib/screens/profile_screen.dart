import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import '../models/food_log.dart';
import '../models/macro_data.dart';
import '../widgets/painters/weight_chart_painter.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  // ========================================
  // DATA MODELS
  // ========================================

  final Map<String, dynamic> _userData = {
    'name': 'คุณกิตติคุณ',
    'currentWeight': 67.5,
    'targetWeight': 65.0,
    'startWeight': 75.0,
    'height': 175,
    'age': 30,
    'streakDays': 12,
    'totalDays': 45,
    'level': 3,
    'xp': 2850,
    'nextLevelXP': 3000,
    'bmi': 22.0,
    'bodyFat': 18.5,
  };

  final List<Map<String, dynamic>> _weightHistory = [
    {'date': '1/7', 'weight': 70.2},
    {'date': '2/7', 'weight': 70.0},
    {'date': '3/7', 'weight': 69.8},
    {'date': '4/7', 'weight': 69.5},
    {'date': '5/7', 'weight': 69.2},
    {'date': '6/7', 'weight': 68.8},
    {'date': '7/7', 'weight': 68.5},
    {'date': '8/7', 'weight': 68.2},
    {'date': '9/7', 'weight': 67.8},
    {'date': '10/7', 'weight': 67.5},
  ];

  final Map<String, dynamic> _healthSummary = {
    'todayCalories': 1850,
    'targetCalories': 2000,
    'todayProtein': 85,
    'targetProtein': 120,
    'todayCarbs': 230,
    'targetCarbs': 250,
    'todayFat': 65,
    'targetFat': 70,
    'todayExercise': 45,
    'targetExercise': 60,
    'waterIntake': 1.8,
    'targetWater': 2.5,
    'sleepHours': 7.5,
    'targetSleep': 8.0,
  };

  final List<Map<String, dynamic>> _weeklyHealthOverview = [
    {
      'day': 'จ', 'date': '8', 'calories': 1900, 'exercise': 60, 'weight': 68.2,
      'sleep': 8.0, 'water': 2.2, 'mood': 'great', 'completed': true, 'healthScore': 85,
    },
    {
      'day': 'อ', 'date': '9', 'calories': 2100, 'exercise': 45, 'weight': 68.0,
      'sleep': 7.5, 'water': 2.0, 'mood': 'good', 'completed': true, 'healthScore': 78,
    },
    {
      'day': 'พ', 'date': '10', 'calories': 1800, 'exercise': 30, 'weight': 67.8,
      'sleep': 6.5, 'water': 1.8, 'mood': 'okay', 'completed': false, 'healthScore': 65,
    },
    {
      'day': 'พฤ', 'date': '11', 'calories': 2000, 'exercise': 60, 'weight': 67.6,
      'sleep': 8.2, 'water': 2.5, 'mood': 'great', 'completed': true, 'healthScore': 90,
    },
    {
      'day': 'ศ', 'date': '12', 'calories': 1950, 'exercise': 50, 'weight': 67.5,
      'sleep': 7.8, 'water': 2.3, 'mood': 'good', 'completed': true, 'healthScore': 82,
    },
    {
      'day': 'ส', 'date': '13', 'calories': 1850, 'exercise': 45, 'weight': 67.5,
      'sleep': 7.5, 'water': 2.1, 'mood': 'good', 'completed': true, 'healthScore': 80,
    },
    {
      'day': 'อา', 'date': '14', 'calories': 1850, 'exercise': 45, 'weight': 67.5,
      'sleep': 7.5, 'water': 1.9, 'mood': 'good', 'completed': true, 'healthScore': 75,
    },
  ];

  final Map<String, dynamic> _sleepData = {
    'lastNightHours': 7.5,
    'targetHours': 8.0,
    'sleepQuality': 0.82,
    'deepSleepHours': 2.1,
    'remSleepHours': 1.8,
    'weeklyAverage': 7.2,
  };

  final Map<String, dynamic> _healthMetrics = {
    'heartRate': 72,
    'bloodPressureSystolic': 120,
    'bloodPressureDiastolic': 80,
    'bodyTemperature': 36.5,
    'oxygenSaturation': 98,
  };

  final List<Map<String, dynamic>> _exerciseHistory = [
    {'date': '9/7', 'type': 'วิ่ง', 'duration': 30, 'calories': 250},
    {'date': '8/7', 'type': 'ยิม', 'duration': 45, 'calories': 300},
    {'date': '7/7', 'type': 'โยคะ', 'duration': 60, 'calories': 180},
    {'date': '6/7', 'type': 'ว่ายน้ำ', 'duration': 40, 'calories': 280},
    {'date': '5/7', 'type': 'ปั่นจักรยาน', 'duration': 35, 'calories': 220},
  ];

  final List<Map<String, dynamic>> _achievements = [
    {'name': 'นักวิ่งมือใหม่', 'description': 'วิ่งครบ 10 ครั้ง', 'icon': Icons.directions_run, 'color': Colors.blue, 'unlocked': true},
    {'name': 'ผู้พิชิตแคลอรี่', 'description': 'เบิร์นแคลอรี่ครบ 1000 kcal', 'icon': Icons.local_fire_department, 'color': Colors.orange, 'unlocked': true},
    {'name': 'นักนอนตรงเวลา', 'description': 'นอนตรงเวลา 7 วันติดต่อกัน', 'icon': Icons.bedtime, 'color': Colors.purple, 'unlocked': true},
    {'name': 'ผู้ชนะน้ำหนัก', 'description': 'ลดน้ำหนักได้ 5 กก.', 'icon': Icons.trending_down, 'color': Colors.green, 'unlocked': false},
  ];

  final Map<String, dynamic> _monthlyGoals = {
    'weightLoss': {'target': 2.0, 'current': 1.2, 'unit': 'กก.'},
    'exerciseDays': {'target': 20, 'current': 15, 'unit': 'วัน'},
    'waterIntake': {'target': 30, 'current': 22, 'unit': 'วัน'},
    'sleepQuality': {'target': 25, 'current': 18, 'unit': 'วัน'},
  };

  final Map<String, dynamic> _nutritionData = {
    'vitaminC': {'current': 85, 'target': 90, 'unit': 'mg'},
    'vitaminD': {'current': 15, 'target': 20, 'unit': 'µg'},
    'calcium': {'current': 800, 'target': 1000, 'unit': 'mg'},
    'iron': {'current': 12, 'target': 15, 'unit': 'mg'},
    'fiber': {'current': 22, 'target': 25, 'unit': 'g'},
  };

  // ========================================
  // LIFECYCLE METHODS
  // ========================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ========================================
  // MAIN BUILD METHOD
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(),
                _buildProgressTab(),
                _buildHealthTab(),
                _buildActivityTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // HEADER SECTION
  // ========================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryPurple,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userData['name'],
                      style: AppTextStyle.titleLarge(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เลเวล ${_userData['level']} • ${_userData['streakDays']} วันติดต่อกัน',
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _navigateToEditProfile(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildQuickStat('น้ำหนักปัจจุบัน', '${_userData['currentWeight']} กก.', Icons.scale)),
              Expanded(child: _buildQuickStat('เป้าหมาย', '${_userData['targetWeight']} กก.', Icons.flag)),
              Expanded(child: _buildQuickStat('BMI', '${_userData['bmi'].toStringAsFixed(1)}', Icons.monitor_weight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyle.titleMedium(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: AppTextStyle.bodySmall(context).copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
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
        labelStyle: AppTextStyle.bodySmall(context).copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyle.bodySmall(context),
        tabs: const [
          Tab(icon: Icon(Icons.today, size: 20), text: 'วันนี้'),
          Tab(icon: Icon(Icons.trending_up, size: 20), text: 'ความคืบหน้า'),
          Tab(icon: Icon(Icons.health_and_safety, size: 20), text: 'สุขภาพ'),
          Tab(icon: Icon(Icons.fitness_center, size: 20), text: 'กิจกรรม'),
        ],
      ),
    );
  }

  // ========================================
  // TAB CONTENT BUILDERS
  // ========================================

  Widget _buildTodayTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTodayOverview(),
          const SizedBox(height: 16),
          _buildHealthCalendar(),
          const SizedBox(height: 16),
          _buildQuickStatsCard(),
          const SizedBox(height: 16),
          _buildWeightUpdateCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWeightTrendChart(),
          const SizedBox(height: 16),
          _buildMonthlyGoals(),
          const SizedBox(height: 16),
          _buildAchievements(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHealthMetrics(),
          const SizedBox(height: 16),
          _buildSleepMetrics(),
          const SizedBox(height: 16),
          _buildHealthVitals(),
          const SizedBox(height: 16),
          _buildNutritionMetrics(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildExerciseHistory(),
          const SizedBox(height: 16),
          _buildSettingsSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ========================================
  // TODAY TAB COMPONENTS
  // ========================================

  Widget _buildTodayOverview() {
    final calorieProgress = _healthSummary['todayCalories'] / _healthSummary['targetCalories'];
    final exerciseProgress = _healthSummary['todayExercise'] / _healthSummary['targetExercise'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ภาพรวมวันนี้', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildProgressCircle('แคลอรี่', '${_healthSummary['todayCalories']}', '${_healthSummary['targetCalories']}', calorieProgress, Colors.orange, 'kcal')),
                const SizedBox(width: 16),
                Expanded(child: _buildProgressCircle('ออกกำลังกาย', '${_healthSummary['todayExercise']}', '${_healthSummary['targetExercise']}', exerciseProgress, Colors.blue, 'นาที')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildProgressCircle('น้ำ', '${_healthSummary['waterIntake']}', '${_healthSummary['targetWater']}', _healthSummary['waterIntake'] / _healthSummary['targetWater'], Colors.cyan, 'ลิตร')),
                const SizedBox(width: 16),
                Expanded(child: _buildProgressCircle('นอนหลับ', '${_healthSummary['sleepHours']}', '${_healthSummary['targetSleep']}', _healthSummary['sleepHours'] / _healthSummary['targetSleep'], Colors.indigo, 'ชม.')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(String title, String current, String target, double progress, Color color, String unit) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 6,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              children: [
                Text(current, style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.bold, color: color)),
                Text(unit, style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600], fontSize: 10)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(title, style: AppTextStyle.bodySmall(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        Text('เป้าหมาย $target $unit', style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600], fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildHealthCalendar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ปฏิทินสุขภาพ 7 วัน', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'เฉลี่ย ${_calculateWeeklyAverage()}%',
                    style: AppTextStyle.bodySmall(context).copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weeklyHealthOverview.map((day) => _buildHealthDayCard(day)).toList(),
            ),
            const SizedBox(height: 16),
            _buildHealthLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthDayCard(Map<String, dynamic> day) {
    Color scoreColor = _getHealthScoreColor(day['healthScore']);
    IconData moodIcon = _getMoodIcon(day['mood']);

    return Expanded(
      child: GestureDetector(
        onTap: () => _showDayDetails(day),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scoreColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              Text(day['day'], style: AppTextStyle.bodySmall(context).copyWith(fontWeight: FontWeight.bold, color: scoreColor)),
              Text(day['date'], style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600], fontSize: 10)),
              const SizedBox(height: 6),
              Icon(moodIcon, color: scoreColor, size: 16),
              const SizedBox(height: 4),
              Container(width: 20, height: 4, decoration: BoxDecoration(color: scoreColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 2),
              Text('${day['healthScore']}%', style: AppTextStyle.bodySmall(context).copyWith(color: scoreColor, fontSize: 9, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${day['weight']}kg', style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600], fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('ดีเยี่ยม', Colors.green, Icons.sentiment_very_satisfied),
          _buildLegendItem('ดี', Colors.blue, Icons.sentiment_satisfied),
          _buildLegendItem('พอใช้', Colors.orange, Icons.sentiment_neutral),
          _buildLegendItem('ควรปรับปรุง', Colors.red, Icons.sentiment_dissatisfied),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyle.bodySmall(context).copyWith(fontSize: 9, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildQuickStatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ข้อมูลส่วนตัว', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatItem('น้ำหนักปัจจุบัน', '${_userData['currentWeight']} กก.', Icons.monitor_weight, Colors.blue)),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(child: _buildStatItem('BMI', '${_userData['bmi'].toStringAsFixed(1)}', Icons.health_and_safety, Colors.green)),
                Container(width: 1, height: 50, color: Colors.grey[300]),
                Expanded(child: _buildStatItem('ลดไปแล้ว', '${(_userData['startWeight'] - _userData['currentWeight']).toStringAsFixed(1)} กก.', Icons.trending_down, Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildWeightUpdateCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('อัพเดทน้ำหนัก', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
                Icon(Icons.scale, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Text('น้ำหนักล่าสุด', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.blue, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${_userData['currentWeight']} กก.', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
                        Text('วันนี้', style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        Text('ลดไปแล้ว', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.green, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${(_userData['startWeight'] - _userData['currentWeight']).toStringAsFixed(1)} กก.', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
                        Text('จากเป้าหมาย ${(_userData['startWeight'] - _userData['targetWeight']).toStringAsFixed(1)} กก.', style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showWeightUpdateDialog,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text('บันทึกน้ำหนักวันนี้', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // PROGRESS TAB COMPONENTS
  // ========================================

  Widget _buildWeightTrendChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('แนวโน้มน้ำหนัก (10 วันที่ผ่านมา)', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(height: 180, child: CustomPaint(painter: WeightChartPainter(_weightHistory), child: Container())),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('เริ่มต้น: ${_weightHistory.first['weight']} กก.', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.grey[600])),
                Text('ปัจจุบัน: ${_weightHistory.last['weight']} กก.', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyGoals() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: Colors.purple),
                const SizedBox(width: 8),
                Text('เป้าหมายประจำเดือน', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...(_monthlyGoals.entries.map((entry) {
              final goal = entry.value;
              final progress = goal['current'] / goal['target'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildGoalItem(
                  _getGoalTitle(entry.key),
                  '${goal['current']}/${goal['target']} ${goal['unit']}',
                  progress,
                  _getGoalColor(entry.key),
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
            Text(value, style: AppTextStyle.bodyMedium(context).copyWith(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Text('ความสำเร็จ', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: _achievements.length,
              itemBuilder: (context, index) => _buildAchievementCard(_achievements[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: achievement['unlocked'] ? achievement['color'].withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: achievement['unlocked'] ? achievement['color'] : Colors.grey, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(achievement['icon'], color: achievement['unlocked'] ? achievement['color'] : Colors.grey, size: 28),
          const SizedBox(height: 6),
          Text(
            achievement['name'],
            style: AppTextStyle.bodySmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: achievement['unlocked'] ? achievement['color'] : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            achievement['description'],
            style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600], fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========================================
  // HEALTH TAB COMPONENTS
  // ========================================

  Widget _buildHealthMetrics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ตัวชี้วัดโภชนาการ', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildMetricItem('โปรตีน', '${_healthSummary['todayProtein']}/${_healthSummary['targetProtein']}g', _healthSummary['todayProtein'] / _healthSummary['targetProtein'], Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricItem('คาร์บ', '${_healthSummary['todayCarbs']}/${_healthSummary['targetCarbs']}g', _healthSummary['todayCarbs'] / _healthSummary['targetCarbs'], Colors.amber)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMetricItem('ไขมัน', '${_healthSummary['todayFat']}/${_healthSummary['targetFat']}g', _healthSummary['todayFat'] / _healthSummary['targetFat'], Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildMetricItem('น้ำ', '${_healthSummary['waterIntake']}/${_healthSummary['targetWater']}L', _healthSummary['waterIntake'] / _healthSummary['targetWater'], Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[700])),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepMetrics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: Colors.indigo),
                const SizedBox(width: 8),
                Text('การนอนหลับ', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSleepCard('เมื่อคืน', '${_sleepData['lastNightHours']} ชม.', _sleepData['lastNightHours'] / _sleepData['targetHours'], Colors.indigo)),
                const SizedBox(width: 12),
                Expanded(child: _buildSleepCard('คุณภาพ', '${(_sleepData['sleepQuality'] * 100).toInt()}%', _sleepData['sleepQuality'], Colors.purple)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSleepCard('Deep Sleep', '${_sleepData['deepSleepHours']} ชม.', _sleepData['deepSleepHours'] / 3.0, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildSleepCard('REM Sleep', '${_sleepData['remSleepHours']} ชม.', _sleepData['remSleepHours'] / 2.5, Colors.teal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard(String title, String value, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthVitals() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                const SizedBox(width: 8),
                Text('ข้อมูลสุขภาพ', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildVitalCard('Heart Rate', '${_healthMetrics['heartRate']} bpm', Icons.favorite, Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalCard('Blood Pressure', '${_healthMetrics['bloodPressureSystolic']}/${_healthMetrics['bloodPressureDiastolic']}', Icons.bloodtype, Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildVitalCard('Body Temp', '${_healthMetrics['bodyTemperature']}°C', Icons.thermostat, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildVitalCard('Oxygen Sat', '${_healthMetrics['oxygenSaturation']}%', Icons.air, Colors.green)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600, color: color))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyle.titleMedium(context).copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNutritionMetrics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_pharmacy, color: Colors.green),
                const SizedBox(width: 8),
                Text('วิตามินและแร่ธาตุ', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...(_nutritionData.entries.take(3).map((entry) {
              final data = entry.value;
              final progress = data['current'] / data['target'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildNutritionItem(entry.key.toUpperCase(), '${data['current']}/${data['target']} ${data['unit']}', progress, _getNutritionColor(entry.key)),
              );
            }).toList()),
            if (_nutritionData.length > 3)
              TextButton(onPressed: () {}, child: Text('ดูทั้งหมด')),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String name, String value, double progress, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(name, style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600, color: color)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[700])),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================================
  // ACTIVITY TAB COMPONENTS
  // ========================================

  Widget _buildExerciseHistory() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fitness_center, color: Colors.blue),
                const SizedBox(width: 8),
                Text('ประวัติการออกกำลังกาย', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...(_exerciseHistory.take(3).map((exercise) => _buildExerciseItem(exercise))),
            if (_exerciseHistory.length > 3)
              TextButton(onPressed: () {}, child: Text('ดูทั้งหมด')),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(Map<String, dynamic> exercise) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.fitness_center, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise['type'], style: AppTextStyle.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                Text('${exercise['duration']} นาที • ${exercise['calories']} kcal', style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
          Text(exercise['date'], style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildMenuItem('แก้ไขโปรไฟล์', 'เปลี่ยนข้อมูลส่วนตัว เป้าหมาย', Icons.edit, Colors.green, _navigateToEditProfile),
          const Divider(height: 1),
          _buildMenuItem('การแจ้งเตือน', 'ตั้งค่าการแจ้งเตือนต่างๆ', Icons.notifications, Colors.orange, () {}),
          const Divider(height: 1),
          _buildMenuItem('ช่วยเหลือและติดต่อ', 'คำถามที่พบบ่อยและการติดต่อ', Icons.help, Colors.teal, () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  Color _getHealthScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 65) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  IconData _getMoodIcon(String mood) {
    switch (mood) {
      case 'great': return Icons.sentiment_very_satisfied;
      case 'good': return Icons.sentiment_satisfied;
      case 'okay': return Icons.sentiment_neutral;
      case 'poor': return Icons.sentiment_dissatisfied;
      default: return Icons.sentiment_neutral;
    }
  }

  String _getMoodText(String mood) {
    switch (mood) {
      case 'great': return 'ดีเยี่ยม';
      case 'good': return 'ดี';
      case 'okay': return 'พอใช้';
      case 'poor': return 'ควรปรับปรุง';
      default: return 'ปกติ';
    }
  }

  String _getGoalTitle(String key) {
    switch (key) {
      case 'weightLoss': return 'ลดน้ำหนัก';
      case 'exerciseDays': return 'ออกกำลังกาย';
      case 'waterIntake': return 'ดื่มน้ำเพียงพอ';
      case 'sleepQuality': return 'นอนหลับคุณภาพ';
      default: return key;
    }
  }

  Color _getGoalColor(String key) {
    switch (key) {
      case 'weightLoss': return Colors.green;
      case 'exerciseDays': return Colors.blue;
      case 'waterIntake': return Colors.cyan;
      case 'sleepQuality': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color _getNutritionColor(String nutrition) {
    switch (nutrition) {
      case 'vitaminC': return Colors.orange;
      case 'vitaminD': return Colors.yellow;
      case 'calcium': return Colors.blue;
      case 'iron': return Colors.red;
      case 'fiber': return Colors.green;
      default: return Colors.grey;
    }
  }

  int _calculateWeeklyAverage() {
    int total = _weeklyHealthOverview.fold(0, (sum, day) => sum + (day['healthScore'] as int));
    return (total / _weeklyHealthOverview.length).round();
  }

  // ========================================
  // DIALOG & NAVIGATION METHODS
  // ========================================

  void _navigateToEditProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
  }

  void _showDayDetails(Map<String, dynamic> day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('รายละเอียดวัน${day['day']} ที่ ${day['date']}', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getHealthScoreColor(day['healthScore']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('คะแนน ${day['healthScore']}%', style: AppTextStyle.bodySmall(context).copyWith(color: _getHealthScoreColor(day['healthScore']), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _buildDetailCard('น้ำหนัก', '${day['weight']} กก.', Icons.scale, Colors.blue),
                    _buildDetailCard('แคลอรี่', '${day['calories']} kcal', Icons.local_fire_department, Colors.orange),
                    _buildDetailCard('ออกกำลังกาย', '${day['exercise']} นาที', Icons.fitness_center, Colors.green),
                    _buildDetailCard('การนอน', '${day['sleep']} ชม.', Icons.bedtime, Colors.indigo),
                    _buildDetailCard('น้ำ', '${day['water']} ลิตร', Icons.water_drop, Colors.cyan),
                    _buildDetailCard('อารมณ์', _getMoodText(day['mood']), _getMoodIcon(day['mood']), _getHealthScoreColor(day['healthScore'])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyle.bodySmall(context).copyWith(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showWeightUpdateDialog() {
    TextEditingController weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('บันทึกน้ำหนักวันนี้', style: AppTextStyle.titleLarge(context).copyWith(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('น้ำหนักปัจจุบัน: ${_userData['currentWeight']} กก.', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.grey[600])),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'น้ำหนักใหม่ (กก.)',
                hintText: 'ใส่น้ำหนักปัจจุบัน',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.scale, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('แนะนำให้ชั่งน้ำหนักตอนเช้าหลังตื่นนอน', style: AppTextStyle.bodySmall(context).copyWith(color: Colors.blue))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              if (weightController.text.isNotEmpty) {
                _updateWeight(double.parse(weightController.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('บันทึก', style: AppTextStyle.bodyMedium(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _updateWeight(double newWeight) {
    setState(() {
      double oldWeight = _userData['currentWeight'];
      _userData['currentWeight'] = newWeight;

      // Update BMI
      double heightInM = _userData['height'] / 100;
      _userData['bmi'] = (newWeight / (heightInM * heightInM));

      // Add to weight history
      DateTime now = DateTime.now();
      _weightHistory.add({'date': '${now.day}/${now.month}', 'weight': newWeight});

      // Show success message with weight change
      double weightChange = newWeight - oldWeight;
      String message = weightChange > 0
          ? 'น้ำหนักเพิ่มขึ้น ${weightChange.toStringAsFixed(1)} กก.'
          : weightChange < 0
          ? 'น้ำหนักลดลง ${(-weightChange).toStringAsFixed(1)} กก.'
          : 'น้ำหนักเท่าเดิม';

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     children: [
      //       Icon(
      //         weightChange <= 0 ? Icons.trending_down : Icons.trending_up,
      //         color: Colors.white,
      //       ),
      //       const SizedBox(width: 8),
      //       Text('บันทึกสำเร็จ! $message'),
      //     ],
      //   ),
      //   backgroundColor: weightChange <= 0 ? Colors.green : Colors.orange,
      //   behavior: SnackBarBehavior.floating,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // ),
      // );
    });
  }
}