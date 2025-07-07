import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import 'package:fl_chart/fl_chart.dart';

class ExerciseCalculatorScreen extends StatefulWidget {
  const ExerciseCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseCalculatorScreen> createState() => _ExerciseCalculatorScreenState();
}

class _ExerciseCalculatorScreenState extends State<ExerciseCalculatorScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();
  final _searchController = TextEditingController();

  // Tab Controller
  late TabController _tabController;

  String _selectedExercise = 'เดิน';
  double _calculatedCalories = 0;
  int _hours = 0;
  int _minutes = 0;
  String _searchQuery = '';

  // Exercise categories with icons
  final Map<String, List<Map<String, dynamic>>> exerciseCategories = {
    'คาร์ดิโอ': [
      {'name': 'เดิน', 'icon': Icons.directions_walk, 'calories': 5},
      {'name': 'วิ่ง', 'icon': Icons.directions_run, 'calories': 11.5},
      {'name': 'ปั่นจักรยาน', 'icon': Icons.directions_bike, 'calories': 8.5},
      {'name': 'ว่ายน้ำ', 'icon': Icons.pool, 'calories': 10},
      {'name': 'กระโดดเชือก', 'icon': Icons.sports_volleyball, 'calories': 12},
      {'name': 'เต้นซุมบ้า', 'icon': Icons.music_note, 'calories': 7.5},
    ],
    'กีฬา': [
      {'name': 'บาสเกตบอล', 'icon': Icons.sports_basketball, 'calories': 8},
      {'name': 'ฟุตบอล', 'icon': Icons.sports_soccer, 'calories': 9},
      {'name': 'เทนนิส', 'icon': Icons.sports_tennis, 'calories': 7.5},
      {'name': 'แบดมินตัน', 'icon': Icons.sports_handball, 'calories': 7},
      {'name': 'วอลเลย์บอล', 'icon': Icons.sports_volleyball, 'calories': 6},
      {'name': 'ปิงปอง', 'icon': Icons.sports_baseball, 'calories': 4},
    ],
    'การออกกำลังกาย': [
      {'name': 'โยคะ', 'icon': Icons.self_improvement, 'calories': 4},
      {'name': 'เวทเทรนนิ่ง', 'icon': Icons.fitness_center, 'calories': 6},
      {'name': 'เต้นแอโรบิก', 'icon': Icons.directions_run, 'calories': 7.5},
      {'name': 'พิลาทิส', 'icon': Icons.sports_gymnastics, 'calories': 5},
      {'name': 'คาร์ดิโอคิกบ็อกซิ่ง', 'icon': Icons.sports_martial_arts, 'calories': 8.5},
      {'name': 'บอดี้เวท', 'icon': Icons.accessibility_new, 'calories': 5.5},
    ],
    'กิจกรรมประจำวัน': [
      {'name': 'ทำสวน', 'icon': Icons.grass, 'calories': 4.5},
      {'name': 'ทำความสะอาดบ้าน', 'icon': Icons.cleaning_services, 'calories': 3.5},
      {'name': 'เดินช็อปปิ้ง', 'icon': Icons.shopping_bag, 'calories': 3.0},
      {'name': 'เล่นกับสัตว์เลี้ยง', 'icon': Icons.pets, 'calories': 3.5},
      {'name': 'ขึ้นบันได', 'icon': Icons.stairs, 'calories': 6.0},
      {'name': 'ล้างรถ', 'icon': Icons.local_car_wash, 'calories': 4.0},
    ],
  };

  // แคลอรี่เป้าหมายต่อวัน
  final double _dailyCalorieGoal = 2000;
  double _remainingCalories = 2000;

  // ข้อมูลการออกกำลังกายวันนี้
  final List<Map<String, dynamic>> _todayExercises = [];

  // ข้อมูลอัตราการเต้นของหัวใจ
  final List<FlSpot> _heartRateData = [
    const FlSpot(0, 75),
    const FlSpot(5, 90),
    const FlSpot(10, 120),
    const FlSpot(15, 140),
    const FlSpot(20, 130),
    const FlSpot(25, 110),
    const FlSpot(30, 85),
  ];

  late AnimationController _pulseAnimationController;
  final int _currentHeartRate = 85;

  // ค่า MET สำหรับแต่ละประเภทการออกกำลังกาย
  final Map<String, double> _exerciseMETs = {
    'เดิน': 3.5, 'วิ่ง': 8.0, 'ปั่นจักรยาน': 6.0, 'ว่ายน้ำ': 7.0,
    'กระโดดเชือก': 10.0, 'เต้นซุมบ้า': 6.5, 'บาสเกตบอล': 6.5,
    'ฟุตบอล': 7.0, 'เทนนิส': 5.5, 'แบดมินตัน': 5.5, 'วอลเลย์บอล': 5.0,
    'ปิงปอง': 4.0, 'โยคะ': 3.0, 'เวทเทรนนิ่ง': 4.5, 'เต้นแอโรบิก': 5.5,
    'พิลาทิส': 3.5, 'คาร์ดิโอคิกบ็อกซิ่ง': 7.5, 'บอดี้เวท': 4.5,
    'ทำสวน': 4.0, 'ทำความสะอาดบ้าน': 3.5, 'เดินช็อปปิ้ง': 3.0,
    'เล่นกับสัตว์เลี้ยง': 3.5, 'ขึ้นบันได': 6.0, 'ล้างรถ': 4.0,
  };

  void _calculateCalories() {
    if (_formKey.currentState!.validate()) {
      if (_hours == 0 && _minutes == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณากรอกเวลาออกกำลังกาย (ชั่วโมงหรือนาที)'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // ปิด keyboard ก่อนทำอะไร
      FocusScope.of(context).unfocus();

      final totalMinutes = (_hours * 60) + _minutes;
      const weight = 65.0;
      final met = _exerciseMETs[_selectedExercise] ?? 3.5;
      final calories = (met * weight * (totalMinutes / 60));

      setState(() {
        _calculatedCalories = calories;
        _remainingCalories -= calories;

        _todayExercises.add({
          'exercise': _selectedExercise,
          'duration': _hours > 0 && _minutes > 0
              ? '$_hours ชั่วโมง $_minutes นาที'
              : _hours > 0
              ? '$_hours ชั่วโมง'
              : '$_minutes นาที',
          'calories': calories,
          'time': TimeOfDay.now().format(context),
        });

        _hours = 0;
        _minutes = 0;
        _hoursController.clear();
        _minutesController.clear();
      });

      // แสดงข้อความแจ้งเตือน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกสำเร็จ! เผาผลาญ ${calories.toInt()} แคลอรี่'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // ไปหน้าภาพรวมหลังบันทึกเสร็จ
      Future.delayed(const Duration(milliseconds: 300), () {
        _tabController.animateTo(0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseAnimationController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.primaryPurple,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryPurple,
              indicatorWeight: 3,
              tabs: const [
                Tab(
                  icon: Icon(Icons.dashboard),
                  text: 'ภาพรวม',
                ),
                Tab(
                  icon: Icon(Icons.fitness_center),
                  text: 'เลือกกิจกรรม',
                ),
                Tab(
                  icon: Icon(Icons.add_circle),
                  text: 'บันทึก',
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildExerciseSelectionTab(),
                _buildRecordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 1: ภาพรวม
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCalorieProgress(),
          const SizedBox(height: 24),
          _buildHeartRateChart(),
          const SizedBox(height: 24),
          _buildTodayExercises(),
        ],
      ),
    );
  }

  // Tab 2: เลือกกิจกรรม
  Widget _buildExerciseSelectionTab() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildExerciseCategories()),
        // Selected Exercise Info
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: _buildSelectedExerciseInfo(),
        ),
      ],
    );
  }

  // Tab 3: บันทึก
  Widget _buildRecordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildSelectedExerciseInfo(),
          const SizedBox(height: 24),
          _buildExerciseForm(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาการออกกำลังกาย...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildExerciseCategories() {
    return DefaultTabController(
      length: exerciseCategories.length,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelPadding: const EdgeInsets.only(right: 20),
              tabs: exerciseCategories.keys.map((category) {
                final categoryIndex = exerciseCategories.keys.toList().indexOf(category);
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${exerciseCategories.values.elementAt(categoryIndex).length}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: exerciseCategories.entries.map((category) {
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: category.value.length,
                  itemBuilder: (context, index) {
                    final exercise = category.value[index];
                    final isSelected = _selectedExercise == exercise['name'];

                    return Card(
                      elevation: isSelected ? 4 : 1,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primaryPurple
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedExercise = exercise['name'];
                          });
                          // เพิ่ม: ไปหน้าบันทึกทันทีหลังเลือกกิจกรรม
                          _tabController.animateTo(2);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: isSelected
                                ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryPurple.withOpacity(0.1),
                                AppTheme.primaryPurple.withOpacity(0.05),
                              ],
                            )
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryPurple.withOpacity(0.15)
                                      : Colors.grey[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  exercise['icon'] as IconData,
                                  color: isSelected ? AppTheme.primaryPurple : Colors.grey[600],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                exercise['name'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryPurple.withOpacity(0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${exercise['calories']} kcal/ชม',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isSelected ? AppTheme.primaryPurple : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedExerciseInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              exerciseCategories.values
                  .expand((category) => category)
                  .firstWhere(
                    (exercise) => exercise['name'] == _selectedExercise,
                orElse: () => {'icon': Icons.directions_run},
              )['icon'] as IconData,
              color: AppTheme.primaryPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedExercise,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_exerciseMETs[_selectedExercise]?.toStringAsFixed(1)} MET · ${exerciseCategories.values
                      .expand((category) => category)
                      .firstWhere(
                        (exercise) => exercise['name'] == _selectedExercise,
                    orElse: () => {'calories': 0},
                  )['calories']} kcal/ชม',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: AppTheme.primaryPurple,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieProgress() {
    final progress = (_dailyCalorieGoal - _remainingCalories) / _dailyCalorieGoal;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
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
            'แคลอรี่วันนี้',
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress > 1 ? Colors.red : AppTheme.primaryPurple,
                    ),
                    minHeight: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$percentage%',
                style: AppTextStyle.titleMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: progress > 1 ? Colors.red : AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'เผาผลาญแล้ว ${(_dailyCalorieGoal - _remainingCalories).toInt()} kcal',
            style: AppTextStyle.bodyMedium(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'อัตราการเต้นของหัวใจ',
                  style: AppTextStyle.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildHeartRateCard(),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(color: Colors.grey[200], strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${value.toInt()}m',
                            style: AppTextStyle.bodySmall(context),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppTextStyle.bodySmall(context),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                minX: 0, maxX: 30, minY: 60, maxY: 160,
                lineBarsData: [
                  LineChartBarData(
                    spots: _heartRateData,
                    isCurved: true,
                    color: AppTheme.primaryPurple,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryPurple.withOpacity(0.2),
                          AppTheme.primaryPurple.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: AppTheme.primaryPurple, size: 16),
          const SizedBox(width: 6),
          Text(
            '$_currentHeartRate BPM',
            style: TextStyle(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ระบุเวลาออกกำลังกาย',
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'กรอกเวลาออกกำลังกาย (ชั่วโมง หรือ นาที หรือ ทั้งคู่)',
                    style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ชั่วโมง',
                    hintText: '0',
                    suffixText: 'ชม.',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final hours = int.tryParse(value);
                      if (hours == null || hours < 0) {
                        return 'กรอกตัวเลขที่ถูกต้อง';
                      }
                      _hours = hours;
                    } else {
                      _hours = 0;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'นาที',
                    hintText: '0',
                    suffixText: 'นาที',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final minutes = int.tryParse(value);
                      if (minutes == null || minutes < 0 || minutes >= 60) {
                        return 'กรอกนาที 0-59';
                      }
                      _minutes = minutes;
                    } else {
                      _minutes = 0;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculateCalories,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: const Text(
                'บันทึกการออกกำลังกาย',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayExercises() {
    if (_todayExercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'ยังไม่มีการออกกำลังกายวันนี้',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เริ่มบันทึกกิจกรรมของคุณได้เลย!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'การออกกำลังกายวันนี้',
                    style: AppTextStyle.titleMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_todayExercises.length} กิจกรรม',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _todayExercises.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final exercise = _todayExercises[index];
              return Dismissible(
                key: Key('${exercise['time']}_$index'),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red[600]),
                      Text(
                        'ลบ',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(() {
                    _remainingCalories += exercise['calories'];
                    _todayExercises.removeAt(index);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('ลบรายการออกกำลังกายแล้ว'),
                      action: SnackBarAction(
                        label: 'เลิกทำ',
                        onPressed: () {
                          setState(() {
                            _todayExercises.insert(index, exercise);
                            _remainingCalories -= exercise['calories'];
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          exerciseCategories.values
                              .expand((category) => category)
                              .firstWhere(
                                (ex) => ex['name'] == exercise['exercise'],
                            orElse: () => {'icon': Icons.directions_run},
                          )['icon'] as IconData,
                          color: AppTheme.primaryPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise['exercise'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              exercise['duration'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '-${exercise['calories'].toInt()} kcal',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exercise['time'],
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}