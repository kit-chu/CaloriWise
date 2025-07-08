import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _foodHistory = [
    {
      'date': '2024-01-15',
      'meal': 'เช้า',
      'food': 'ข้าวต้มไข่',
      'calories': 250,
      'time': '08:30',
      'image': 'https://picsum.photos/60/60?random=1'
    },
    {
      'date': '2024-01-15',
      'meal': 'กลางวัน',
      'food': 'ข้าวผัดกะเพรา',
      'calories': 450,
      'time': '12:15',
      'image': 'https://picsum.photos/60/60?random=2'
    },
    {
      'date': '2024-01-15',
      'meal': 'เย็น',
      'food': 'ส้มตำ + ข้าวเหนียว',
      'calories': 380,
      'time': '18:45',
      'image': 'https://picsum.photos/60/60?random=3'
    },
    {
      'date': '2024-01-14',
      'meal': 'เช้า',
      'food': 'โจ๊กหมู',
      'calories': 200,
      'time': '08:00',
      'image': 'https://picsum.photos/60/60?random=4'
    },
  ];

  final List<Map<String, dynamic>> _exerciseHistory = [
    {
      'date': '2024-01-15',
      'exercise': 'วิ่งเหยาะๆ',
      'duration': 30,
      'calories': 280,
      'time': '06:30',
      'icon': Icons.directions_run
    },
    {
      'date': '2024-01-15',
      'exercise': 'ยืดเหยียด',
      'duration': 15,
      'calories': 50,
      'time': '19:30',
      'icon': Icons.self_improvement
    },
    {
      'date': '2024-01-14',
      'exercise': 'ปั่นจักรยาน',
      'duration': 45,
      'calories': 350,
      'time': '17:00',
      'icon': Icons.pedal_bike
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการบันทึก'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'อาหาร'),
            Tab(text: 'ออกกำลังกาย'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodHistoryTab(),
          _buildExerciseHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildFoodHistoryTab() {
    final groupedData = _groupFoodByDate();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedData.length,
      itemBuilder: (context, index) {
        final date = groupedData.keys.elementAt(index);
        final items = groupedData[date]!;

        return _buildDateSection(date, items, true);
      },
    );
  }

  Widget _buildExerciseHistoryTab() {
    final groupedData = _groupExerciseByDate();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedData.length,
      itemBuilder: (context, index) {
        final date = groupedData.keys.elementAt(index);
        final items = groupedData[date]!;

        return _buildDateSection(date, items, false);
      },
    );
  }

  Widget _buildDateSection(String date, List<Map<String, dynamic>> items, bool isFood) {
    final totalCalories = items.fold<int>(0, (sum, item) => sum + (item['calories'] as int));

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date),
                  style: AppTextStyle.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalCalories ${isFood ? 'kcal กิน' : 'kcal เผาผลาญ'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...items.map((item) => _buildHistoryItem(item, isFood)).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item, bool isFood) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          if (isFood) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood),
                  );
                },
              ),
            ),
          ] else ...[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item['icon'],
                color: AppTheme.primaryPurple,
                size: 24,
              ),
            ),
          ],
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFood ? item['food'] : item['exercise'],
                  style: AppTextStyle.titleSmall(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (isFood) ...[
                  Text(
                    'มื้อ${item['meal']} • ${item['time']}',
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ] else ...[
                  Text(
                    '${item['duration']} นาที • ${item['time']}',
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['calories']}',
                style: AppTextStyle.titleMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: isFood ? Colors.orange : Colors.green,
                ),
              ),
              Text(
                'kcal',
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupFoodByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in _foodHistory) {
      final date = item['date'];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }

    return grouped;
  }

  Map<String, List<Map<String, dynamic>>> _groupExerciseByDate() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in _exerciseHistory) {
      final date = item['date'];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(item);
    }

    return grouped;
  }

  String _formatDate(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;

    if (difference == 0) {
      return 'วันนี้';
    } else if (difference == 1) {
      return 'เมื่อวาน';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
