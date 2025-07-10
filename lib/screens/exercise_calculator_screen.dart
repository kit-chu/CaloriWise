import 'dart:async';

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

  // Smart Watch Connection Status
  bool _isSmartWatchConnected = false;
  String _connectedDeviceName = '';
  String _deviceBatteryLevel = '';
  bool _isConnecting = false;
  DateTime? _lastSyncTime;
  int _currentHeartRate = 0;
  int _todaySteps = 0;
  double _todayDistance = 0.0;

  // Auto Exercise Detection
  bool _isAutoRecording = false;
  DateTime? _exerciseStartTime;
  String _autoDetectedExercise = '';
  int _previousHeartRate = 0;
  int _previousSteps = 0;
  Timer? _autoRecordingTimer;
  Timer? _heartRateMonitorTimer;

  // Available smart watch devices
  final List<Map<String, dynamic>> _availableDevices = [
    {
      'name': 'Apple Watch Series 9',
      'type': 'Apple Watch',
      'battery': '85%',
      'isConnected': false,
      'icon': Icons.watch,
    },
    {
      'name': 'Samsung Galaxy Watch 6',
      'type': 'Samsung Watch',
      'battery': '72%',
      'isConnected': false,
      'icon': Icons.watch,
    },
    {
      'name': 'Fitbit Charge 5',
      'type': 'Fitbit',
      'battery': '91%',
      'isConnected': false,
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Garmin Forerunner 965',
      'type': 'Garmin',
      'battery': '67%',
      'isConnected': false,
      'icon': Icons.watch,
    },
  ];

  // Exercise History Data
  final List<Map<String, dynamic>> _exerciseHistory = [
    {'date': '9/7', 'type': 'วิ่ง', 'duration': 30, 'calories': 250, 'time': '06:30'},
    {'date': '8/7', 'type': 'ยิม', 'duration': 45, 'calories': 300, 'time': '18:00'},
    {'date': '7/7', 'type': 'โยคะ', 'duration': 60, 'calories': 180, 'time': '07:00'},
    {'date': '6/7', 'type': 'ว่ายน้ำ', 'duration': 40, 'calories': 280, 'time': '17:30'},
    {'date': '5/7', 'type': 'ปั่นจักรยาน', 'duration': 35, 'calories': 220, 'time': '06:00'},
    {'date': '4/7', 'type': 'เดิน', 'duration': 45, 'calories': 150, 'time': '19:00'},
    {'date': '3/7', 'type': 'เต้นซุมบ้า', 'duration': 50, 'calories': 200, 'time': '18:30'},
  ];

  // Weekly Exercise Summary
  final Map<String, dynamic> _weeklyStats = {
    'totalCalories': 1580,
    'totalDuration': 305,
    'averagePerDay': 44,
    'mostPopularExercise': 'ว��่ง',
    'streakDays': 5,
  };

  // Exercise categories with icons (���รับขนาดให้น้อยลง)
  final Map<String, List<Map<String, dynamic>>> exerciseCategories = {
    'คาร์ดิโอ': [
      {'name': 'เดิน', 'icon': Icons.directions_walk, 'calories': 5},
      {'name': 'วิ่ง', 'icon': Icons.directions_run, 'calories': 11.5},
      {'name': 'ปั่นจักรยาน', 'icon': Icons.directions_bike, 'calories': 8.5},
      {'name': 'ว่ายน้ำ', 'icon': Icons.pool, 'calories': 10},
      {'name': 'กระโดดเชือก', 'icon': Icons.sports_volleyball, 'calories': 12},
      {'name': 'เต้นซุมบ้า', 'icon': Icons.music_note, 'calories': 7.5},
      {'name': 'วิ่งบันได', 'icon': Icons.stairs, 'calories': 15},
      {'name': 'แอโรบิก', 'icon': Icons.accessibility_new, 'calories': 8},
      {'name': 'เต้นรำ', 'icon': Icons.music_note, 'calories': 6.5},
    ],
    'กีฬา': [
      {'name': 'บาสเกตบอล', 'icon': Icons.sports_basketball, 'calories': 8},
      {'name': 'ฟุตบอล', 'icon': Icons.sports_soccer, 'calories': 9},
      {'name': 'เทนนิส', 'icon': Icons.sports_tennis, 'calories': 7.5},
      {'name': 'แบดมินตัน', 'icon': Icons.sports_handball, 'calories': 7},
      {'name': 'วอลเลย์บอล', 'icon': Icons.sports_volleyball, 'calories': 6},
      {'name': 'ปิงปอง', 'icon': Icons.sports_baseball, 'calories': 4},
      {'name': 'กอล์ฟ', 'icon': Icons.sports_golf, 'calories': 4.5},
      {'name': 'โบว์ลิ่ง', 'icon': Icons.sports_cricket, 'calories': 3.5},
      {'name': 'มวยไทย', 'icon': Icons.sports_martial_arts, 'calories': 10},
    ],
    'การออกกำลังกาย': [
      {'name': 'โยค���', 'icon': Icons.self_improvement, 'calories': 4},
      {'name': 'ยิม', 'icon': Icons.fitness_center, 'calories': 6},
      {'name': 'เต้นแอโรบิก', 'icon': Icons.directions_run, 'calories': 7.5},
      {'name': 'พิลาทิส', 'icon': Icons.sports_gymnastics, 'calories': 5},
      {'name': 'คิกบ็อกซิ่ง', 'icon': Icons.sports_martial_arts, 'calories': 8.5},
      {'name': 'ยกน้ำหนัก', 'icon': Icons.fitness_center, 'calories': 5.5},
      {'name': 'สเตรทชิ่ง', 'icon': Icons.accessibility, 'calories': 2.5},
      {'name': 'ไต่ป่าย', 'icon': Icons.terrain, 'calories': 9},
      {'name': 'ออกกำลังกาย', 'icon': Icons.sports_gymnastics, 'calories': 6},
    ],
  };

  // แคลอรี่เป้าหมายต่อวัน
  final double _dailyCalorieGoal = 2000;
  double _remainingCalories = 2000;

  // ข้อมูลการออกกำลังกายวันนี้
  final List<Map<String, dynamic>> _todayExercises = [];

  // ข้อมูลอั��ราการเต้นของหัวใจ
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

  // ค่า MET สำหรับแต่ละประเภทการออกกำลังกาย
  final Map<String, double> _exerciseMETs = {
    'เดิน': 3.5, 'วิ่ง': 8.0, 'ปั่นจักรยาน': 6.0, 'ว่ายน้ำ': 7.0,
    'กระโดดเชือก': 10.0, 'บาสเกตบอล': 6.5, 'ฟุตบอล': 7.0,
    'เทนนิส': 5.5, 'แบดมินตัน': 5.5, 'วอลเลย์บอล': 5.0,
    'โ��คะ': 3.0, 'ยิม': 4.5, 'เต้นแอโรบิ���': 5.5,
    'พิลาทิส': 3.5, 'คิกบ็อกซิ่ง': 7.5,
  };

  void _calculateCalories() {
    if (_formKey.currentState!.validate()) {
      if (_hours == 0 && _minutes == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('กรุณากรอกเวลาออกกำลังกาย'),
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
              ? '$_hours ชม $_minutes นาที'
              : _hours > 0
              ? '$_hours ชม'
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

  // Smart Watch Connection Methods
  Future<void> _connectToSmartWatch(Map<String, dynamic> device) async {
    setState(() {
      _isConnecting = true;
    });

    // Simulate connection process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isConnecting = false;
      _isSmartWatchConnected = true;
      _connectedDeviceName = device['name'];
      _deviceBatteryLevel = device['battery'];
      _lastSyncTime = DateTime.now();
      _currentHeartRate = 85;
      _todaySteps = 8247;
      _todayDistance = 6.2;
      _previousHeartRate = _currentHeartRate;
      _previousSteps = _todaySteps;

      // Update device list
      for (var d in _availableDevices) {
        d['isConnected'] = d['name'] == device['name'];
      }
    });

    // Start auto monitoring when connected
    _startAutoExerciseMonitoring();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('เชื่อมต่อกับ ${device['name']} สำเร็จ\nเปิดการตรวจจับการออกกำลังกายอัตโนมัติ'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _disconnectSmartWatch() async {
    // Stop monitoring when disconnecting
    _stopAutoExerciseMonitoring();

    setState(() {
      _isSmartWatchConnected = false;
      _connectedDeviceName = '';
      _deviceBatteryLevel = '';
      _lastSyncTime = null;
      _currentHeartRate = 0;
      _todaySteps = 0;
      _todayDistance = 0.0;
      _previousHeartRate = 0;
      _previousSteps = 0;

      // Update device list
      for (var d in _availableDevices) {
        d['isConnected'] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ยกเลิกการเชื่อมต่อแล้ว'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Auto Exercise Detection Methods
  void _startAutoExerciseMonitoring() {
    if (!_isSmartWatchConnected) return;

    // Monitor heart rate and steps every 10 seconds
    _heartRateMonitorTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _monitorVitalSigns();
    });
  }

  void _stopAutoExerciseMonitoring() {
    _heartRateMonitorTimer?.cancel();
    _autoRecordingTimer?.cancel();

    if (_isAutoRecording) {
      _stopAutoRecording();
    }
  }

  void _monitorVitalSigns() {
    if (!_isSmartWatchConnected) return;

    // Simulate real-time data changes
    final random = DateTime.now().millisecond;
    final newHeartRate = 85 + (random % 40) - 20; // 65-125 bpm range
    final stepIncrement = random % 10; // 0-9 steps per monitoring cycle

    setState(() {
      _currentHeartRate = newHeartRate;
      _todaySteps += stepIncrement;
      _todayDistance += stepIncrement * 0.0008; // Approximate distance per step
      _lastSyncTime = DateTime.now();
    });

    // Check if exercise started
    if (!_isAutoRecording) {
      _checkForExerciseStart();
    } else {
      _checkForExerciseEnd();
    }

    _previousHeartRate = _currentHeartRate;
    _previousSteps = _todaySteps;
  }

  void _checkForExerciseStart() {
    // Exercise detection criteria:
    // 1. Heart rate > 100 bpm for sustained period
    // 2. Significant step increase
    final heartRateThreshold = _currentHeartRate > 100;
    final stepIncrease = _todaySteps - _previousSteps;
    final significantMovement = stepIncrease > 5;

    if (heartRateThreshold && significantMovement) {
      _startAutoRecording();
    }
  }

  void _checkForExerciseEnd() {
    // Stop criteria:
    // 1. Heart rate drops below 90 bpm
    // 2. No significant movement for a period
    final heartRateDropped = _currentHeartRate < 90;
    final stepIncrease = _todaySteps - _previousSteps;
    final minimalMovement = stepIncrease < 2;

    if (heartRateDropped && minimalMovement) {
      // Wait a bit more to confirm exercise has ended
      _autoRecordingTimer?.cancel();
      _autoRecordingTimer = Timer(const Duration(seconds: 30), () {
        if (_currentHeartRate < 90) {
          _stopAutoRecording();
        }
      });
    }
  }

  void _startAutoRecording() {
    if (_isAutoRecording) return;

    setState(() {
      _isAutoRecording = true;
      _exerciseStartTime = DateTime.now();
      _autoDetectedExercise = _detectExerciseType();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🏃 ตรวจพบการออกกำลังกาย: $_autoDetectedExercise\nกำลังบันทึกอัตโนมัติ...'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'หยุด',
          textColor: Colors.white,
          onPressed: _stopAutoRecording,
        ),
      ),
    );
  }

  void _stopAutoRecording() {
    if (!_isAutoRecording || _exerciseStartTime == null) return;

    final exerciseDuration = DateTime.now().difference(_exerciseStartTime!);
    final durationMinutes = exerciseDuration.inMinutes;

    // Only record if exercise lasted more than 2 minutes
    if (durationMinutes >= 2) {
      _saveAutoDetectedExercise(durationMinutes);
    }

    setState(() {
      _isAutoRecording = false;
      _exerciseStartTime = null;
      _autoDetectedExercise = '';
    });

    _autoRecordingTimer?.cancel();
  }

  String _detectExerciseType() {
    // Simple exercise detection based on heart rate zones
    if (_currentHeartRate >= 130) {
      return 'วิ่ง'; // High intensity
    } else if (_currentHeartRate >= 110) {
      return 'เดินเร็ว'; // Medium intensity
    } else {
      return 'เดิน'; // Low intensity
    }
  }

  void _saveAutoDetectedExercise(int durationMinutes) {
    const weight = 65.0;
    final met = _exerciseMETs[_autoDetectedExercise] ?? 3.5;
    final calories = (met * weight * (durationMinutes / 60));

    setState(() {
      _calculatedCalories = calories;
      _remainingCalories -= calories;

      _todayExercises.add({
        'exercise': '$_autoDetectedExercise (อัตโนมัติ)',
        'duration': durationMinutes >= 60
            ? '${(durationMinutes / 60).floor()} ชม ${durationMinutes % 60} นาที'
            : '$durationMinutes นาที',
        'calories': calories,
        'time': TimeOfDay.now().format(context),
        'isAutoDetected': true,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ บันทึกอัตโนมัติสำเร็จ!\n'
          '$_autoDetectedExercise เป็นเวลา $durationMinutes นาที\n'
          'เผาผลาญ ${calories.toInt()} แคลอรี่'
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );

    // Auto switch to overview tab to show the recorded exercise
    Future.delayed(const Duration(milliseconds: 500), () {
      _tabController.animateTo(0);
    });
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
    _heartRateMonitorTimer?.cancel();
    _autoRecordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header ที่ดูสะอาดขึ้น
            _buildHeader(),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: AppTheme.primaryPurple,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'การออกกำลังกาย',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          // Tab Bar
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryPurple,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppTheme.primaryPurple,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'ภาพรวม'),
              Tab(text: 'เลือกกิจกรรม'),
              Tab(text: 'บันทึก'),
            ],
          ),
        ],
      ),
    );
  }

  // Tab 1: ภาพรวม
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalorieProgress(),
          const SizedBox(height: 16),
          _buildSmartWatchStatus(),
          const SizedBox(height: 16),
          _buildTodayExercises(),
          const SizedBox(height: 16),
          _buildQuickStats(),
          const SizedBox(height: 16),
          _buildExerciseHistory(),
          const SizedBox(height: 80), // เพิ่ม space ล่างสุด
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
      ],
    );
  }

  // Tab 3: บันทึก
  Widget _buildRecordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSelectedExerciseInfo(),
          const SizedBox(height: 20),
          _buildExerciseForm(),
          const SizedBox(height: 80), // เพิ่ม space ล่างสุด
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ค้นหาการออกกำลังกาย...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.primaryPurple,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppTheme.primaryPurple,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              tabs: exerciseCategories.keys.map((category) {
                return Tab(text: category);
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: exerciseCategories.entries.map((category) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
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
                            color: isSelected ? AppTheme.primaryPurple : Colors.grey[200]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedExercise = exercise['name'];
                            });
                            _tabController.animateTo(2);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected ? AppTheme.primaryPurple.withOpacity(0.05) : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryPurple.withOpacity(0.15)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    exercise['icon'] as IconData,
                                    color: isSelected ? AppTheme.primaryPurple : Colors.grey[600],
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  exercise['name'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${exercise['calories']} kcal/ชม',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
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
          const SizedBox(width: 12),
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
                Text(
                  'MET: ${_exerciseMETs[_selectedExercise]?.toStringAsFixed(1)}',
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
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieProgress() {
    final progress = (_dailyCalorieGoal - _remainingCalories) / _dailyCalorieGoal;
    final percentage = (progress * 100).clamp(0, 100).toInt();
    final burnedCalories = (_dailyCalorieGoal - _remainingCalories).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'แคลอรี่วันนี้',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'เผาผลาญแล้ว $burnedCalories kcal จาก 2,000 kcal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ระบุเวลาออกกำลังกาย',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
                      labelText: 'ชั่ว��มง',
                      hintText: '0',
                      suffixText: 'ชม.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'นาที',
                      hintText: '0',
                      suffixText: 'นาที',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateCalories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'บันทึกการออกกำลังกาย',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayExercises() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                Icon(
                  Icons.today,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'กิจกรรมวันนี้',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_todayExercises.length}',
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
          if (_todayExercises.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ยังไม่มีกิจกรรมวันนี้',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _todayExercises.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final exercise = _todayExercises[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
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
                      const SizedBox(width: 12),
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
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'สถิติรายสัปดาห์',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('แคลอรี่', '${_weeklyStats['totalCalories']}', 'kcal'),
              ),
              Expanded(
                child: _buildStatItem('เวลา', '${_weeklyStats['totalDuration']}', 'นาที'),
              ),
              Expanded(
                child: _buildStatItem('ต่อเนื่อ���', '${_weeklyStats['streakDays']}', 'วัน'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseHistory() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                Icon(
                  Icons.history,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ประวัติการออกกำลังกาย',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (_exerciseHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '��ังไม่มีประวัติการออกกำลังกาย',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exerciseHistory.take(5).length, // แสดงแค่ 5 รายการล่าสุด
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final exercise = _exerciseHistory[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          exerciseCategories.values
                              .expand((category) => category)
                              .firstWhere(
                                (ex) => ex['name'] == exercise['type'],
                            orElse: () => {'icon': Icons.directions_run},
                          )['icon'] as IconData,
                          color: AppTheme.primaryPurple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise['type'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${exercise['duration']} นาที · ${exercise['calories']} kcal',
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
                            exercise['date'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
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
                );
              },
            ),
          if (_exerciseHistory.length > 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // นำไปหน้าประวัติทั้งหมด
                  },
                  child: Text(
                    'ดูทั้งหมด (${_exerciseHistory.length} รายการ)',
                    style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmartWatchStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isSmartWatchConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isSmartWatchConnected ? Icons.watch : Icons.watch_off,
                  color: _isSmartWatchConnected ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สถานะการเชื่อมต่อ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSmartWatchConnected
                          ? 'เชื่อมต่อกับ $_connectedDeviceName'
                          : 'ยังไม่เชื่อมต่ออุปกรณ์',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isSmartWatchConnected ? Colors.green : Colors.grey[600],
                        fontWeight: _isSmartWatchConnected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSmartWatchConnected) ...[
                IconButton(
                  onPressed: _syncSmartWatchData,
                  icon: Icon(
                    Icons.sync,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                  tooltip: 'ซิงค์ข้อมูล',
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'disconnect') {
                      _disconnectSmartWatch();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'disconnect',
                      child: Row(
                        children: [
                          Icon(Icons.link_off, size: 16),
                          SizedBox(width: 8),
                          Text('ยกเลิกการเชื่อมต่อ'),
                        ],
                      ),
                    ),
                  ],
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ] else
                TextButton(
                  onPressed: _showDeviceConnectionDialog,
                  child: Text(
                    'เชื่อมต่อ',
                    style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (_isSmartWatchConnected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Auto Recording Status
                  if (_isAutoRecording) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseAnimationController.value * 0.1),
                                child: Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'กำลังบันทึก: $_autoDetectedExercise',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                          if (_exerciseStartTime != null)
                            Text(
                              '${DateTime.now().difference(_exerciseStartTime!).inMinutes} นาที',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWatchDataItem(
                        'แบตเตอรี่',
                        _deviceBatteryLevel,
                        Icons.battery_full,
                        Colors.green,
                      ),
                      _buildWatchDataItem(
                        'หัวใจ',
                        '$_currentHeartRate bpm',
                        Icons.favorite,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWatchDataItem(
                        'ก้าว',
                        '${_todaySteps.toString()} ก้าว',
                        Icons.directions_walk,
                        Colors.blue,
                      ),
                      _buildWatchDataItem(
                        'ระยะทาง',
                        '${_todayDistance.toStringAsFixed(1)} กม.',
                        Icons.straighten,
                        Colors.orange,
                      ),
                    ],
                  ),
                  if (_lastSyncTime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'ซิงค์ล่าสุด: ${_formatTime(_lastSyncTime!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWatchDataItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'เมื่อสักครู่';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} นาทีที่แล้ว';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} ชั่วโมงที่แล้ว';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _syncSmartWatchData() async {
    if (!_isSmartWatchConnected) return;

    // Show loading state
    setState(() {
      _lastSyncTime = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('กำลังซิงค์ข้อมูล...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    // Simulate data sync with more realistic changes
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      // Simulate more realistic heart rate changes
      if (_isAutoRecording) {
        _currentHeartRate = 110 + (DateTime.now().millisecond % 30); // Active range
      } else {
        _currentHeartRate = 75 + (DateTime.now().millisecond % 20); // Resting range
      }

      // Add some steps
      final stepIncrement = 50 + (DateTime.now().millisecond % 100);
      _todaySteps += stepIncrement;
      _todayDistance += stepIncrement * 0.0008;

      // Update battery level occasionally
      if (DateTime.now().millisecond % 5 == 0) {
        final currentBattery = int.tryParse(_deviceBatteryLevel.replaceAll('%', '')) ?? 85;
        if (currentBattery > 10) {
          _deviceBatteryLevel = '${currentBattery - 1}%';
        }
      }

      _lastSyncTime = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'ซิงค์ข้อมูลสำเร็จ!\nหัวใจ: $_currentHeartRate bpm, ก้าว: $_todaySteps',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeviceConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: !_isConnecting,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.bluetooth,
                  color: AppTheme.primaryPurple,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'เชื่อมต่ออุปกรณ์',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: _isConnecting ? 120 : 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isConnecting) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text(
                      'กำลังเชื่อมต่อ...',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'กรุณารอสักครู่',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'เลือกอุปกรณ์ที่ต้องการเชื่อมต่อ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableDevices.length,
                        itemBuilder: (context, index) {
                          final device = _availableDevices[index];
                          final isConnected = device['isConnected'] as bool;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: isConnected ? 2 : 1,
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isConnected
                                      ? AppTheme.primaryPurple.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  device['icon'] as IconData,
                                  color: isConnected ? AppTheme.primaryPurple : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                device['name'],
                                style: TextStyle(
                                  fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${device['type']}'),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.battery_full,
                                        size: 12,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'แบตเตอรี่ ${device['battery']}',
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: isConnected
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'เชื่อมต่อแล้ว',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _connectToSmartWatch(device);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: AppTheme.primaryPurple,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'เชื่อมต่อ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (!_isConnecting) ...[
                TextButton(
                  onPressed: () {
                    // Refresh available devices
                    setDialogState(() {
                      // Simulate device discovery
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔍 ค้นหาอุปกรณ์ใหม่...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.refresh, size: 16),
                      const SizedBox(width: 4),
                      const Text('ค้นหาใหม่'),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ปิด'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
