import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'เริ่มต้นดี!',
      'description': 'บันทึกอาหาร 7 วันติดต่อกัน',
      'icon': '🎯',
      'isUnlocked': true,
      'progress': 7,
      'maxProgress': 7,
      'reward': '50 XP',
      'category': 'บันทึกอาหาร',
    },
    {
      'title': 'นักวิ่งมือใหม่',
      'description': 'วิ่งสะสม 10 กิโลเมตร',
      'icon': '🏃‍♂️',
      'isUnlocked': true,
      'progress': 10,
      'maxProgress': 10,
      'reward': '100 XP',
      'category': 'ออกกำลังกาย',
    },
    {
      'title': 'ผู้เชี่ยวชาญแคลอรี่',
      'description': 'ควบคุมแคลอรี่ตามเป้าหมาย 30 วัน',
      'icon': '📊',
      'isUnlocked': false,
      'progress': 15,
      'maxProgress': 30,
      'reward': '200 XP',
      'category': 'เป้าหมาย',
    },
    {
      'title': 'นักดื่มน้ำ',
      'description': 'ดื่มน้ำครบ 2 ลิตร 14 วันติดต่อกัน',
      'icon': '💧',
      'isUnlocked': false,
      'progress': 8,
      'maxProgress': 14,
      'reward': '75 XP',
      'category': 'สุขภาพ',
    },
    {
      'title': 'ชาเลนจ์เจอร์',
      'description': 'เข้าร่วมชาเลนจ์ 5 ครั้ง',
      'icon': '🏆',
      'isUnlocked': false,
      'progress': 2,
      'maxProgress': 5,
      'reward': '150 XP',
      'category': 'ชุมชน',
    },
    {
      'title': 'ผู้ช่วยเหลือ',
      'description': 'ช่วยเหลือสมาชิกใน Community 20 ครั้ง',
      'icon': '🤝',
      'isUnlocked': false,
      'progress': 12,
      'maxProgress': 20,
      'reward': '180 XP',
      'category': 'ชุมชน',
    },
  ];

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'ลดน้ำหนัก 5 กิโลกรัม',
      'current': 2.5,
      'target': 5.0,
      'unit': 'กก.',
      'deadline': '2024-03-01',
      'status': 'กำลังดำเนินการ',
      'color': Colors.blue,
    },
    {
      'title': 'วิ่งสะสม 50 กิโลเมตร',
      'current': 28.5,
      'target': 50.0,
      'unit': 'กม.',
      'deadline': '2024-02-15',
      'status': 'กำลังดำเนินการ',
      'color': Colors.green,
    },
    {
      'title': 'ดื่มน้ำครบเป้า 30 วัน',
      'current': 18.0,
      'target': 30.0,
      'unit': 'วัน',
      'deadline': '2024-02-28',
      'status': 'กำลังดำเนินการ',
      'color': Colors.orange,
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
        title: const Text('เป้าหมายและรางวัล'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'เป้าหมาย'),
            Tab(text: 'รางวัล'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGoalsTab(),
          _buildAchievementsTab(),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOverallProgressCard(),
        const SizedBox(height: 16),
        ..._goals.map((goal) => _buildGoalCard(goal)).toList(),
      ],
    );
  }

  Widget _buildOverallProgressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withOpacity(0.1),
              AppTheme.primaryPurple.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ความคืบหน้าโดยรวม',
              style: AppTextStyle.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressStat('เป้าหมายที่บรรลุ', '2', '6', Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressStat('กำลังดำเนินการ', '3', '6', Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.67,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            ),
            const SizedBox(height: 8),
            Text(
              'ความสำเร็จ 67%',
              style: AppTextStyle.bodySmall(context).copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String current, String total, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.bodySmall(context).copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: AppTextStyle.titleLarge(context).copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            children: [
              TextSpan(text: current),
              TextSpan(
                text: '/$total',
                style: AppTextStyle.titleMedium(context).copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final progress = goal['current'] / goal['target'];
    final daysLeft = DateTime.parse(goal['deadline']).difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: goal['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flag,
                    color: goal['color'],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['title'],
                        style: AppTextStyle.titleMedium(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'เหลือ $daysLeft วัน',
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: goal['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal['status'],
                    style: TextStyle(
                      color: goal['color'],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal['current']} ${goal['unit']}',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal['color'],
                  ),
                ),
                Text(
                  'เป้าหมาย ${goal['target']} ${goal['unit']}',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(goal['color']),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}% สำเร็จ',
              style: AppTextStyle.bodySmall(context).copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsTab() {
    final unlockedAchievements = _achievements.where((a) => a['isUnlocked']).toList();
    final lockedAchievements = _achievements.where((a) => !a['isUnlocked']).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAchievementStats(),
        const SizedBox(height: 16),
        if (unlockedAchievements.isNotEmpty) ...[
          Text(
            'รางวัลที่ได้รับแล้ว',
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...unlockedAchievements.map((achievement) => _buildAchievementCard(achievement)).toList(),
          const SizedBox(height: 16),
        ],
        if (lockedAchievements.isNotEmpty) ...[
          Text(
            'รางวัลที่ยังไม่ได้รับ',
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...lockedAchievements.map((achievement) => _buildAchievementCard(achievement)).toList(),
        ],
      ],
    );
  }

  Widget _buildAchievementStats() {
    final totalAchievements = _achievements.length;
    final unlockedCount = _achievements.where((a) => a['isUnlocked']).length;
    final totalXP = _achievements.where((a) => a['isUnlocked']).fold(0, (sum, a) => sum + int.parse(a['reward'].split(' ')[0]));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$unlockedCount/$totalAchievements',
                    style: AppTextStyle.titleLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'รางวัลที่ได้รับ',
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$totalXP XP',
                    style: AppTextStyle.titleLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'คะแนนสะสม',
                    style: AppTextStyle.bodySmall(context).copyWith(
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
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['isUnlocked'];
    final progress = achievement['progress'] / achievement['maxProgress'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isUnlocked ? Colors.green.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  achievement['icon'],
                  style: TextStyle(
                    fontSize: 24,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'],
                    style: AppTextStyle.titleSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement['description'],
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: isUnlocked ? Colors.grey[600] : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isUnlocked) ...[
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement['progress']}/${achievement['maxProgress']}',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                achievement['reward'],
                style: TextStyle(
                  color: isUnlocked ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
