import 'dart:async';

import 'package:calori_wise_app/services/google_fit_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/text_style.dart';


class ExerciseCalculatorScreen extends StatefulWidget {
  const ExerciseCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseCalculatorScreen> createState() => _ExerciseCalculatorScreenState();
}

class _ExerciseCalculatorScreenState extends State<ExerciseCalculatorScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final PageController _pageController = PageController();

  // Google Fit Service
  final GoogleFitService _googleFitService = GoogleFitService();
  Map<String, dynamic> _googleFitData = {};
  bool _isGoogleFitConnected = false;
  bool _isConnectingToGoogleFit = false;

  // Tab Controller
  late TabController _tabController;

  String _selectedExercise = 'วิ่งเหยาะ';
  int _selectedDuration = 30; // นาที

  // Smart Watch Connection Status
  bool _isSmartWatchConnected = true; // เปลี่ยนเป็น true เพื่อ mock
  String _connectedDeviceName = 'Apple Watch Series 9';
  String _deviceBatteryLevel = '78%';
  bool _isConnecting = false;
  DateTime? _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 5));
  int _currentHeartRate = 98;
  int _todaySteps = 12847;
  double _todayDistance = 9.2;

  // Auto Exercise Detection
  bool _isAutoRecording = false;
  DateTime? _exerciseStartTime;
  String _autoDetectedExercise = '';
  int _previousSteps = 0;
  Timer? _autoRecordingTimer;
  Timer? _heartRateMonitorTimer;

  // Animation Controller
  late AnimationController _pulseAnimationController;
  late AnimationController _slideAnimationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _checkGoogleFitConnection();
    _initializeMockData();
  }

  void _initializeMockData() {
    // Initialize with some realistic mock data
    _googleFitData = {
      'steps': 8247,
      'calories': 420,
      'distance': 6.8,
      'heartRate': 85,
      'activeMinutes': 67,
    };
    _isGoogleFitConnected = true;

    // Start monitoring simulation
    _startAutoExerciseMonitoring();
  }

  Future<void> _checkGoogleFitConnection() async {
    final isConnected = await _googleFitService.getConnectionStatus();
    if (isConnected) {
      await _connectToGoogleFit();
    }
  }

  Future<void> _connectToGoogleFit() async {
    setState(() {
      _isConnectingToGoogleFit = true;
    });

    try {
      final isConnected = await _googleFitService.initialize();
      setState(() {
        _isGoogleFitConnected = isConnected;
      });

      if (isConnected) {
        _fetchGoogleFitData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('เชื่อมต่อ Google Fit สำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ Google Fit: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnectingToGoogleFit = false;
        });
      }
    }
  }

  Future<void> _fetchGoogleFitData() async {
    if (!_isGoogleFitConnected) return;
    final data = await _googleFitService.getTodayHealthData();
    if (mounted) {
      setState(() {
        _googleFitData = data;
        _todaySteps = data['steps'] ?? _todaySteps;
        _currentHeartRate = data['heartRate'] ?? _currentHeartRate;
        _todayDistance = data['distance'] ?? _todayDistance;
      });
    }
  }

  // Available smart watch devices
  final List<Map<String, dynamic>> _availableDevices = [
    {
      'name': 'Apple Watch Series 9',
      'type': 'Apple Watch',
      'battery': '78%',
      'isConnected': true,
      'icon': Icons.watch,
    },
    {
      'name': 'Samsung Galaxy Watch 6',
      'type': 'Samsung Watch',
      'battery': '65%',
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
  ];

  // Exercise History Data - เพิ่ม mock data มากขึ้น
  final List<Map<String, dynamic>> _exerciseHistory = [
    {'date': '11/7', 'type': 'วิ่งเหยาะ', 'duration': 45, 'calories': 380, 'time': '06:30', 'heartRate': 145},
    {'date': '10/7', 'type': 'ยิม', 'duration': 60, 'calories': 420, 'time': '18:00', 'heartRate': 135},
    {'date': '9/7', 'type': 'โยคะ', 'duration': 50, 'calories': 180, 'time': '07:00', 'heartRate': 90},
    {'date': '8/7', 'type': 'ว่ายน้ำ', 'duration': 40, 'calories': 320, 'time': '17:30', 'heartRate': 130},
    {'date': '7/7', 'type': 'ปั่นจักรยาน', 'duration': 55, 'calories': 280, 'time': '06:00', 'heartRate': 125},
    {'date': '6/7', 'type': 'เดินเร็ว', 'duration': 35, 'calories': 150, 'time': '19:00', 'heartRate': 110},
    {'date': '5/7', 'type': 'เต้นซุมบ้า', 'duration': 45, 'calories': 250, 'time': '18:30', 'heartRate': 140},
    {'date': '4/7', 'type': 'ไต่ป่าย', 'duration': 90, 'calories': 450, 'time': '08:00', 'heartRate': 155},
  ];

  // Weekly Exercise Summary - เพิ่มข้อมูลที่สมจริงขึ้น
  final Map<String, dynamic> _weeklyStats = {
    'totalCalories': 2430,
    'totalDuration': 420,
    'averagePerDay': 60,
    'mostPopularExercise': 'วิ่งเหยาะ',
    'streakDays': 7,
    'weeklyGoal': 300, // นาทีต่อสัปดาห์
    'workoutCount': 8,
  };

  // Exercise categories with updated data
  final Map<String, List<Map<String, dynamic>>> exerciseCategories = {
    'ยอดนิยม': [
      {'name': 'วิ่งเหยาะ', 'icon': Icons.directions_run, 'calories': 12, 'description': 'เผาผลาญสูง เหมาะสำหรับทุกระดับ'},
      {'name': 'เดินเร็ว', 'icon': Icons.directions_walk, 'calories': 6, 'description': 'เริ่มต้นง่าย เหมาะสำหรับมือใหม่'},
      {'name': 'ปั่นจักรยาน', 'icon': Icons.directions_bike, 'calories': 9, 'description': 'สนุก และเผาผลาญดี'},
      {'name': 'ว่ายน้ำ', 'icon': Icons.pool, 'calories': 11, 'description': 'ออกกำลังกายแบบ Low Impact'},
    ],
    'คาร์ดิโอ': [
      {'name': 'วิ่งบันได', 'icon': Icons.stairs, 'calories': 15, 'description': 'เผาผลาญสูงมาก'},
      {'name': 'กระโดดเชือก', 'icon': Icons.sports_volleyball, 'calories': 13, 'description': 'เผาผลาญเร็ว ใช้เวลาสั้น'},
      {'name': 'แอโรบิก', 'icon': Icons.accessibility_new, 'calories': 8, 'description': 'สนุก เต้นไปเผาผลาญไป'},
      {'name': 'เต้นซุมบ้า', 'icon': Icons.music_note, 'calories': 7, 'description': 'สนุกสนาน ลืมความเหนื่อย'},
    ],
    'กีฬา': [
      {'name': 'บาสเกตบอล', 'icon': Icons.sports_basketball, 'calories': 8, 'description': 'กีฬาทีม สร้างมิตรภาพ'},
      {'name': 'เทนนิส', 'icon': Icons.sports_tennis, 'calories': 7, 'description': 'ฝึกสมาธิ และความแม่นยำ'},
      {'name': 'แบดมินตัน', 'icon': Icons.sports_handball, 'calories': 7, 'description': 'กีฬายอดนิยมคนไทย'},
      {'name': 'ฟุตบอล', 'icon': Icons.sports_soccer, 'calories': 9, 'description': 'กีฬาโลก เผาผลาญดี'},
    ],
    'ออกกำลังกาย': [
      {'name': 'โยคะ', 'icon': Icons.self_improvement, 'calories': 4, 'description': 'ผ่อนคลาย ยืดหยุ่น'},
      {'name': 'ยิม', 'icon': Icons.fitness_center, 'calories': 6, 'description': 'สร้างกล้ามเนื้อ เผาผลาญต่อเนื่อง'},
      {'name': 'พิลาทิส', 'icon': Icons.sports_gymnastics, 'calories': 5, 'description': 'แกนกายแข็งแรง ท่าทางดี'},
      {'name': 'ไต่ป่าย', 'icon': Icons.terrain, 'calories': 12, 'description': 'ผจญภัย เผาผลาญสูง'},
    ],
  };

  // Daily calorie goal and remaining
  final double _dailyCalorieGoal = 2200;
  double _burnedCalories = 540; // Mock burned calories

  // Today's exercises - เพิ่ม mock data
  final List<Map<String, dynamic>> _todayExercises = [
    {'exercise': 'วิ่งเหยาะ', 'duration': '30 นาที', 'calories': 360.0, 'time': '06:30', 'isAutoDetected': false},
    {'exercise': 'เดินเร็ว (อัตโนมัติ)', 'duration': '15 นาที', 'calories': 90.0, 'time': '12:15', 'isAutoDetected': true},
    {'exercise': 'ยิม', 'duration': '25 นาที', 'calories': 150.0, 'time': '18:00', 'isAutoDetected': false},
  ];

  // Exercise durations (in minutes)
  final List<int> _durationOptions = [15, 20, 30, 45, 60, 75, 90];

  // MET values for exercises
  final Map<String, double> _exerciseMETs = {
    'เดินเร็ว': 4.5, 'วิ่งเหยาะ': 8.0, 'ปั่นจักรยาน': 6.0, 'ว่ายน้ำ': 7.0,
    'กระโดดเชือก': 10.0, 'บาสเกตบอล': 6.5, 'ฟุตบอล': 7.0,
    'เทนนิส': 5.5, 'แบดมินตัน': 5.5, 'วอลเลย์บอล': 5.0,
    'โยคะ': 3.0, 'ยิม': 4.5, 'แอโรบิก': 5.5, 'วิ่งบันได': 12.0,
    'พิลาทิส': 3.5, 'เต้นซุมบ้า': 6.0, 'ไต่ป่าย': 8.5,
  };

  void _calculateCalories() {
    FocusScope.of(context).unfocus();

    const weight = 68.0; // kg
    final met = _exerciseMETs[_selectedExercise] ?? 4.0;
    final calories = (met * weight * (_selectedDuration / 60));

    setState(() {
      _burnedCalories += calories;

      _todayExercises.add({
        'exercise': _selectedExercise,
        'duration': '$_selectedDuration นาที',
        'calories': calories,
        'time': TimeOfDay.now().format(context),
        'isAutoDetected': false,
      });
    });

    // Show success animation and feedback
    _showSuccessDialog(calories.toInt());
  }

  void _showSuccessDialog(int calories) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'บันทึกสำเร็จ!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เผาผลาญ $calories แคลอรี่',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAchievementCard(
                    'วันนี้',
                    '${_todayExercises.length}',
                    'ครั้ง',
                    Icons.today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAchievementCard(
                    'รวม',
                    '${_burnedCalories.toInt()}',
                    'kcal',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('ดูสรุป'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('เยี่ยม!'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Smart Watch Methods
  Future<void> _connectToSmartWatch(Map<String, dynamic> device) async {
    setState(() {
      _isConnecting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isConnecting = false;
        _isSmartWatchConnected = true;
        _connectedDeviceName = device['name'];
        _deviceBatteryLevel = device['battery'];
        _lastSyncTime = DateTime.now();

        for (var d in _availableDevices) {
          d['isConnected'] = d['name'] == device['name'];
        }
      });

      _startAutoExerciseMonitoring();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เชื่อมต่อกับ ${device['name']} สำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _disconnectSmartWatch() async {
    _stopAutoExerciseMonitoring();

    setState(() {
      _isSmartWatchConnected = false;
      _connectedDeviceName = '';
      _deviceBatteryLevel = '';
      _lastSyncTime = null;

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

    _heartRateMonitorTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
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
    if (!_isSmartWatchConnected || !mounted) return;

    final random = DateTime.now().millisecond;
    final heartRateVariation = (random % 20) - 10;
    final stepIncrement = 15 + (random % 25);

    setState(() {
      _currentHeartRate = (85 + heartRateVariation).clamp(70, 160);
      _todaySteps += stepIncrement;
      _todayDistance += stepIncrement * 0.0008;
      _lastSyncTime = DateTime.now();
    });

    // Simulate exercise detection
    if (!_isAutoRecording && _currentHeartRate > 110) {
      final shouldDetect = random % 10 == 0; // 10% chance
      if (shouldDetect) {
        _startAutoRecording();
      }
    }
  }

  void _startAutoRecording() {
    if (_isAutoRecording || !mounted) return;

    setState(() {
      _isAutoRecording = true;
      _exerciseStartTime = DateTime.now();
      _autoDetectedExercise = _detectExerciseType();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🏃 ตรวจพบการออกกำลังกาย: $_autoDetectedExercise'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'หยุด',
          textColor: Colors.white,
          onPressed: _stopAutoRecording,
        ),
      ),
    );

    // Auto stop after random duration
    _autoRecordingTimer = Timer(Duration(minutes: 5 + (DateTime.now().millisecond % 15)), () {
      _stopAutoRecording();
    });
  }

  void _stopAutoRecording() {
    if (!_isAutoRecording || _exerciseStartTime == null) return;

    final exerciseDuration = DateTime.now().difference(_exerciseStartTime!);
    final durationMinutes = exerciseDuration.inMinutes;

    if (durationMinutes >= 3) {
      _saveAutoDetectedExercise(durationMinutes);
    }

    if (mounted) {
      setState(() {
        _isAutoRecording = false;
        _exerciseStartTime = null;
        _autoDetectedExercise = '';
      });
    }

    _autoRecordingTimer?.cancel();
  }

  String _detectExerciseType() {
    if (_currentHeartRate >= 140) {
      return 'วิ่งเหยาะ';
    } else if (_currentHeartRate >= 120) {
      return 'เดินเร็ว';
    } else {
      return 'เดิน';
    }
  }

  void _saveAutoDetectedExercise(int durationMinutes) {
    const weight = 68.0;
    final met = _exerciseMETs[_autoDetectedExercise] ?? 4.0;
    final calories = (met * weight * (durationMinutes / 60));

    setState(() {
      _burnedCalories += calories;

      _todayExercises.add({
        'exercise': '$_autoDetectedExercise (อัตโนมัติ)',
        'duration': '$durationMinutes นาที',
        'calories': calories,
        'time': TimeOfDay.now().format(context),
        'isAutoDetected': true,
      });
    });

    _showAutoExerciseDialog(durationMinutes, calories.toInt());
  }

  void _showAutoExerciseDialog(int duration, int calories) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.blue,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ตรวจจับอัตโนมัติ!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_autoDetectedExercise เป็นเวลา $duration นาที\nเผาผลาญ $calories แคลอรี่',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('เยี่ยม!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseAnimationController.dispose();
    _slideAnimationController.dispose();
    _searchController.dispose();
    _pageController.dispose();
    _heartRateMonitorTimer?.cancel();
    _autoRecordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('ออกกำลังกาย'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: AppTextStyle.labelMedium(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTextStyle.labelMedium(context).copyWith(
            color: Colors.white70,
          ),
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          tabs: const [
            Tab(icon: Icon(Icons.dashboard, size: 20), text: 'สรุป'),
            Tab(icon: Icon(Icons.add_circle_outline, size: 20), text: 'เพิ่ม'),
            Tab(icon: Icon(Icons.history, size: 20), text: 'ประวัติ'),
            Tab(icon: Icon(Icons.devices, size: 20), text: 'อุปกรณ์'),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        children: [
          _buildDashboardPage(),
          _buildExerciseSelectionPage(),
          _buildHistoryPage(),
          _buildDevicesPage(),
        ],
      ),
    );
  }

  // Page 1: Dashboard
  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalorieProgressCard(),
          const SizedBox(height: 16),
          _buildQuickStatsRow(),
          const SizedBox(height: 16),
          _buildSmartWatchCard(),
          const SizedBox(height: 16),
          _buildTodayActivitiesCard(),
          const SizedBox(height: 16),
          _buildWeeklyProgressCard(),
          const SizedBox(height: 20), // ลด padding เพราะไม่มี bottom nav แล้ว
        ],
      ),
    );
  }

  // Page 2: Exercise Selection
  Widget _buildExerciseSelectionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickAddSection(),
          const SizedBox(height: 20),
          _buildExerciseCategoriesSection(),
          const SizedBox(height: 20), // ลด padding
        ],
      ),
    );
  }

  // Page 3: History
  Widget _buildHistoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHistoryStatsCard(),
          const SizedBox(height: 16),
          _buildHistoryList(),
          const SizedBox(height: 20), // ลด padding
        ],
      ),
    );
  }

  // Page 4: Devices
  Widget _buildDevicesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceConnectionCard(),
          const SizedBox(height: 16),
          _buildGoogleFitCard(),
          const SizedBox(height: 16),
          _buildAvailableDevicesList(),
          const SizedBox(height: 20), // ลด padding
        ],
      ),
    );
  }

  Widget _buildCalorieProgressCard() {
    final progress = _burnedCalories / _dailyCalorieGoal;
    final percentage = (progress * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เป้าหมายแคลอรี่วันนี้',
                    style: AppTextStyle.titleMedium(context).copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_burnedCalories.toInt()} / ${_dailyCalorieGoal.toInt()} kcal',
                    style: AppTextStyle.headlineSmall(context).copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$percentage% ของเป้าหมาย',
                  style: AppTextStyle.labelLarge(context),
                ),
                const Spacer(),
                Text(
                  'เหลืออีก ${(_dailyCalorieGoal - _burnedCalories).toInt()} kcal',
                  style: AppTextStyle.bodySmall(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickStatCard(
            'ก้าววันนี้',
            '${_todaySteps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            Icons.directions_walk,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            'ระยะทาง',
            '${_todayDistance.toStringAsFixed(1)} กม.',
            Icons.straighten,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickStatCard(
            'หัวใจ',
            '$_currentHeartRate bpm',
            Icons.favorite,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildSmartWatchCard() {
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
                      _isSmartWatchConnected ? _connectedDeviceName : 'ไม่ได้เชื่อมต่อ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _isSmartWatchConnected
                          ? 'เชื่อมต่อแล้ว • แบต $_deviceBatteryLevel'
                          : 'แตะเพื่อเชื่อมต่ออุปกรณ์',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isSmartWatchConnected ? Colors.green : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSmartWatchConnected)
                Icon(
                  Icons.sync,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
            ],
          ),
          if (_isAutoRecording) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_pulseAnimationController.value * 0.2),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child:                     Text(
                      'กำลังตรวจจับ: $_autoDetectedExercise',
                      style: AppTextStyle.labelLarge(context).copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  if (_exerciseStartTime != null)
                    Text(
                      '${DateTime.now().difference(_exerciseStartTime!).inMinutes}m',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodayActivitiesCard() {
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
                Text(
                  'กิจกรรมวันนี้',
                  style: AppTextStyle.titleLarge(context),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:                   Text(
                    '${_todayExercises.length}',
                    style: AppTextStyle.labelMedium(context).copyWith(
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
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.fitness_center, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text(
                      'ยังไม่มีกิจกรรมวันนี้',
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      },
                      child: const Text('เริ่มออกกำลังกาย'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _todayExercises.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey[200],
                indent: 20,
                endIndent: 20,
              ),
              itemBuilder: (context, index) {
                final exercise = _todayExercises[index];
                final isAutoDetected = exercise['isAutoDetected'] ?? false;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isAutoDetected
                              ? Colors.blue.withOpacity(0.1)
                              : AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isAutoDetected ? Icons.auto_awesome : Icons.fitness_center,
                          color: isAutoDetected ? Colors.blue : AppTheme.primaryPurple,
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
                              style: AppTextStyle.labelLarge(context),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              exercise['duration'],
                              style: AppTextStyle.bodySmall(context),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '-${exercise['calories'].toInt()} kcal',
                            style: AppTextStyle.labelLarge(context).copyWith(
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exercise['time'],
                            style: AppTextStyle.labelSmall(context).copyWith(
                              color: AppTheme.textSecondary,
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

  Widget _buildWeeklyProgressCard() {
    final weeklyProgress = _weeklyStats['totalDuration'] / _weeklyStats['weeklyGoal'];

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
            'ความคืบหน้าสัปดาห์นี้',
            style: AppTextStyle.titleLarge(context),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_weeklyStats['totalDuration']} / ${_weeklyStats['weeklyGoal']} นาที',
                      style: AppTextStyle.titleMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'เป้าหมายรายสัปดาห์',
                      style: AppTextStyle.bodySmall(context),
                    ),
                  ],
                ),
              ),
              Text(
                '${(weeklyProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: weeklyProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeekStatItem('ครั้ง', '${_weeklyStats['workoutCount']}'),
              _buildWeekStatItem('แคลอรี่', '${_weeklyStats['totalCalories']}'),
              _buildWeekStatItem('ต่อเนื่อง', '${_weeklyStats['streakDays']} วัน'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.titleMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyle.bodySmall(context),
        ),
      ],
    );
  }

  Widget _buildQuickAddSection() {
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
            'เพิ่มการออกกำลังกายด่วน',
            style: AppTextStyle.titleLarge(context),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: AppTheme.primaryPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedExercise,
                      style: AppTextStyle.titleMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _showExerciseSelector,
                      child: const Text('เปลี่ยน'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'เวลา: ',
                      style: AppTextStyle.bodyLarge(context),
                    ),
                    Text(
                      '$_selectedDuration นาที',
                      style: AppTextStyle.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _showDurationSelector,
                      child: const Text('เปลี่ยน'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculateCalories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'บันทึก ${_getEstimatedCalories()} แคลอรี่',
                          style: AppTextStyle.titleMedium(context).copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getEstimatedCalories() {
    const weight = 68.0;
    final met = _exerciseMETs[_selectedExercise] ?? 4.0;
    final calories = (met * weight * (_selectedDuration / 60));
    return calories.toInt();
  }

  void _showExerciseSelector() {
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'เลือกการออกกำลังกาย',
                    style: AppTextStyle.titleLarge(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: exerciseCategories.entries.map((category) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child:                         Text(
                          category.key,
                          style: AppTextStyle.titleMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                      ...category.value.map((exercise) {
                        final isSelected = exercise['name'] == _selectedExercise;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryPurple.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected ? Border.all(color: AppTheme.primaryPurple) : null,
                          ),
                          child: ListTile(
                            leading: Icon(
                              exercise['icon'],
                              color: isSelected ? AppTheme.primaryPurple : Colors.grey,
                            ),
                            title: Text(exercise['name']),
                            subtitle: Text(exercise['description'] ?? ''),
                            trailing: Text(
                              '${exercise['calories']} kcal/นาที',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedExercise = exercise['name'];
                              });
                              Navigator.pop(context);
                            },
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'เลือกระยะเวลา',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _durationOptions.length,
                itemBuilder: (context, index) {
                  final duration = _durationOptions[index];
                  final isSelected = duration == _selectedDuration;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDuration = duration;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryPurple : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$duration นาที',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'หมวดหมู่การออกกำลังกาย',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...exerciseCategories.entries.map((category) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
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
            child: ExpansionTile(
              title: Text(
                category.key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category.key),
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: category.value.length,
                    itemBuilder: (context, index) {
                      final exercise = category.value[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedExercise = exercise['name'];
                          });
                          _showQuickAddDialog(exercise);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedExercise == exercise['name']
                                  ? AppTheme.primaryPurple
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                exercise['icon'],
                                size: 16,
                                color: AppTheme.primaryPurple,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      exercise['name'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${exercise['calories']} kcal/นาที',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'ยอดนิยม':
        return Icons.star;
      case 'คาร์ดิโอ':
        return Icons.favorite;
      case 'กีฬา':
        return Icons.sports_soccer;
      case 'ออกกำลังกาย':
        return Icons.fitness_center;
      default:
        return Icons.sports_gymnastics;
    }
  }

  void _showQuickAddDialog(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              exercise['icon'],
              size: 48,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(height: 16),
            Text(
              exercise['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exercise['description'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'เผาผลาญ ${exercise['calories']} แคลอรี่ต่อนาที',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedExercise = exercise['name'];
              });
              _showDurationSelector();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('เลือก'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStatsCard() {
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
          Row(
            children: [
              Expanded(
                child: _buildHistoryStatItem(
                  'สัปดาห์นี้',
                  '${_weeklyStats['workoutCount']}',
                  'ครั้ง',
                  Icons.calendar_today,
                  AppTheme.primaryPurple,
                ),
              ),
              Expanded(
                child: _buildHistoryStatItem(
                  'รวมแคลอรี่',
                  '${_weeklyStats['totalCalories']}',
                  'kcal',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHistoryStatItem(
                  'เฉลี่ย/วัน',
                  '${_weeklyStats['averagePerDay']}',
                  'นาที',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildHistoryStatItem(
                  'ต่อเนื่อง',
                  '${_weeklyStats['streakDays']}',
                  'วัน',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryStatItem(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'ประวัติล่าสุด',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exerciseHistory.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final exercise = _exerciseHistory[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            exercise['date'].split('/')[0],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                          Text(
                            '/${exercise['date'].split('/')[1]}',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['type'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${exercise['duration']} นาที',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.favorite, size: 14, color: Colors.red[300]),
                              const SizedBox(width: 4),
                              Text(
                                '${exercise['heartRate']} bpm',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${exercise['calories']} kcal',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDeviceConnectionCard() {
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSmartWatchConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isSmartWatchConnected ? Icons.watch : Icons.watch_off,
                  color: _isSmartWatchConnected ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSmartWatchConnected ? 'เชื่อมต่อแล้ว' : 'ไม่ได้เชื่อมต่อ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isSmartWatchConnected ? Colors.green : Colors.grey[600],
                      ),
                    ),
                    if (_isSmartWatchConnected) ...[
                      Text(
                        _connectedDeviceName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ] else ...[
                      const Text(
                        'เชื่อมต่อเพื่อตรวจจับกิจกรรมอัตโนมัติ',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              if (_isSmartWatchConnected)
                IconButton(
                  onPressed: _disconnectSmartWatch,
                  icon: const Icon(Icons.settings),
                  color: AppTheme.primaryPurple,
                ),
            ],
          ),
          if (_isSmartWatchConnected) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDeviceStatItem(
                          'แบตเตอรี่',
                          _deviceBatteryLevel,
                          Icons.battery_full,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildDeviceStatItem(
                          'การซิงค์',
                          _lastSyncTime != null ? _formatTime(_lastSyncTime!) : 'ไม่ได้ซิงค์',
                          Icons.sync,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _syncSmartWatchData,
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('ซิงค์ข้อมูลใหม่'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
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

  Widget _buildGoogleFitCard() {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isGoogleFitConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isGoogleFitConnected ? Icons.fitness_center : Icons.fitness_center_outlined,
                  color: _isGoogleFitConnected ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Fit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isGoogleFitConnected ? Colors.green : Colors.grey[600],
                      ),
                    ),
                    Text(
                      _isGoogleFitConnected ? 'เชื่อมต่อและซิงค์แล้ว' : 'ยังไม่ได้เชื่อมต่อ',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (_isConnectingToGoogleFit)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (!_isGoogleFitConnected)
                TextButton(
                  onPressed: _connectToGoogleFit,
                  child: const Text('เชื่อมต่อ'),
                ),
            ],
          ),
          if (_isGoogleFitConnected) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildGoogleFitDataItem(
                      'ก้าว',
                      '${_googleFitData['steps'] ?? 0}',
                      Icons.directions_walk,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildGoogleFitDataItem(
                      'แคลอรี่',
                      '${_googleFitData['calories'] ?? 0}',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildGoogleFitDataItem(
                      'นาทีที่เคลื่อนไหว',
                      '${_googleFitData['activeMinutes'] ?? 0}',
                      Icons.timer,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleFitDataItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAvailableDevicesList() {
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
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'อุปกรณ์ที่พร้อมใช้งาน',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _availableDevices.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
              indent: 20,
              endIndent: 20,
            ),
            itemBuilder: (context, index) {
              final device = _availableDevices[index];
              final isConnected = device['isConnected'] as bool;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            device['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isConnected ? AppTheme.primaryPurple : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                device['type'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.battery_full,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                device['battery'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isConnected)
                      Container(
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
                    else
                      TextButton(
                        onPressed: () => _connectToSmartWatch(device),
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
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'เมื่อกี้นี้';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }

  Future<void> _syncSmartWatchData() async {
    if (!_isSmartWatchConnected) return;

    // Show loading state
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

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        // Update mock data
        final random = DateTime.now().millisecond;
        _currentHeartRate = 80 + (random % 25);
        _todaySteps += 50 + (random % 100);
        _todayDistance += 0.1 + (random % 5) * 0.01;
        _lastSyncTime = DateTime.now();

        // Update battery (decrease slightly)
        final currentBattery = int.tryParse(_deviceBatteryLevel.replaceAll('%', '')) ?? 78;
        if (currentBattery > 15) {
          _deviceBatteryLevel = '${currentBattery - 1}%';
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('ซิงค์ข้อมูลสำเร็จ!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}