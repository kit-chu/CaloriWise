import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import 'chat_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'สัปดาห์';

  // Sample data for analytics
  final Map<String, dynamic> _analyticsData = {
    'overallScore': 82,
    'aiInsights': {
      'mainInsight': 'ระบบ AI วิเคราะห์พบว่าคุณมีแนวโน้มลดน้ำหนักได้สำเร็จ โดยมีโอกาส 87% ที่จะบรรลุเป้าหมายภายใน 6 สัปดาห์',
      'riskLevel': 'ต่ำ',
      'confidence': 87,
      'recommendations': [
        'เพิ่มการดื่มน้ำในวันเสาร์-อาทิตย์',
        'รักษาจังหวะการออกกำลังกายในวันจันทร์และศุกร์',
        'ปรับลดแคลอรี่ 50 kcal/วัน สำหรับสัปดาห์หน้า'
      ]
    },
    'predictions': {
      'weightIn7Days': 67.2,
      'weightIn30Days': 66.1,
      'goalAchievementDate': '15 ส.ค. 2567',
      'metabolismTrend': 'เพิ่มขึ้น',
      'plateauRisk': 15
    },
    'behaviorAnalysis': {
      'patterns': [
        {
          'pattern': 'คุณมักจะออกกำลังกายดีในวันจันทร์ (90%)',
          'insight': 'ใช้ momentum ตัวนี้เป็นแรงบันดาลใจสำหรับวันอื่นๆ',
          'type': 'positive'
        },
        {
          'pattern': 'การดื่มน้ำลดลงในวันหยุด (-40%)',
          'insight': 'ตั้งแจ้งเตือนทุก 2 ชั่วโมงในวันเสาร์-อาทิตย์',
          'type': 'warning'
        },
        {
          'pattern': 'การนอนหลับไม่สม่ำเสมอส่งผลต่อการควบคุมน้ำหนัก',
          'insight': 'นอนก่อน 23:00 น. จะช่วยเพิ่มประสิทธิภาพการเผาผลาญ 12%',
          'type': 'critical'
        }
      ]
    },
    'weeklyProgress': {
      'weightLoss': 0.8,
      'exerciseGoal': 5,
      'exerciseCompleted': 4,
      'calorieAverage': 1850,
      'calorieTarget': 2000,
      'waterGoal': 7,
      'waterCompleted': 5,
    },
    'monthlyTrends': {
      'weightStart': 70.0,
      'weightCurrent': 67.5,
      'weightTarget': 65.0,
      'muscleGain': 2.3,
      'fatLoss': 3.8,
      'metabolismIncrease': 8.5,
    },
    'aiRecommendations': [
      {
        'title': 'การปรับเปลี่ยนแคลอรี่',
        'description': 'AI แนะนำให้ลดแคลอรี่ 50 kcal/วัน เพื่อเร่งการลดน้ำหนัก',
        'impact': 'สูง',
        'confidence': 92,
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
      },
      {
        'title': 'รูปแบบการออกกำลังกาย',
        'description': 'เพิ่ม HIIT 15 นาที ในวันพุธ จะช่วยเพิ่มการเผาผลาญ',
        'impact': 'กลาง',
        'confidence': 78,
        'icon': Icons.fitness_center,
        'color': Colors.blue,
      },
      {
        'title': 'การจัดการการนอนหลับ',
        'description': 'นอนให้ครบ 7-8 ชั่วโมง จะช่วยควบคุมฮอร์โมนความหิว',
        'impact': 'สูง',
        'confidence': 85,
        'icon': Icons.bedtime,
        'color': Colors.purple,
      },
      {
        'title': 'ไฮเดรชันในวันหยุด',
        'description': 'ดื่มน้ำเพิ่ม 500ml ในวันเสาร์-อาทิตย์ เพื่อรักษาเมตาบอลิซึม',
        'impact': 'กลาง',
        'confidence': 71,
        'icon': Icons.water_drop,
        'color': Colors.cyan,
      },
    ],
    'weeklyPattern': [
      {'day': 'จ', 'score': 0.9},
      {'day': 'อ', 'score': 0.7},
      {'day': 'พ', 'score': 0.8},
      {'day': 'พฤ', 'score': 0.6},
      {'day': 'ศ', 'score': 0.9},
      {'day': 'ส', 'score': 0.5},
      {'day': 'อา', 'score': 0.4},
    ],
    'healthMetrics': {
      'nutrition': 85,
      'exercise': 75,
      'sleep': 70,
      'hydration': 88,
    },
  };

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
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAnalyticsTab(),
                const ChatScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // HEADER SECTION
  // =================================================================

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 20,
          20,
          20
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryPurple.withValues(alpha: 0.8)
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
                Icons.analytics,
                color: Colors.white,
                size: 28
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'วิเคราะห์ & AI',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ข้อมูลเชิงลึกและคำปรึกษา AI',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: AppTheme.primaryPurple,
                style: AppTextStyle.bodyMedium(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                items: ['สัปดาห์', 'เดือน', '3 เดือน']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPeriod = newValue!;
                  });
                },
              ),
            ),
          ),
        ],
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
        labelStyle: AppTextStyle.titleSmall(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.bar_chart, size: 24),
            text: 'วิเคราะห์',
          ),
          Tab(
            icon: Icon(Icons.chat, size: 24),
            text: 'AI Chat',
          ),
        ],
      ),
    );
  }

  // =================================================================
  // MAIN ANALYTICS TAB
  // =================================================================

  Widget _buildAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildAIInsightCard(),
        const SizedBox(height: 20),
        _buildPredictionsCard(),
        const SizedBox(height: 20),
        _buildOverallScoreCard(),
        const SizedBox(height: 20),
        _buildBehaviorAnalysisCard(),
        const SizedBox(height: 20),
        _buildAIRecommendationsCard(),
        const SizedBox(height: 20),
        _buildWeeklyPatternCard(),
        const SizedBox(height: 20),
        _buildProgressSummaryCard(),
        const SizedBox(height: 100),
      ],
    );
  }

  // =================================================================
  // AI INSIGHT CARD
  // =================================================================

  Widget _buildAIInsightCard() {
    final aiData = _analyticsData['aiInsights'];

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea).withValues(alpha: 0.1),
              const Color(0xFF764ba2).withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 24
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Analysis',
                        style: AppTextStyle.titleLarge(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ความเชื่อมั่น ${aiData['confidence']}%',
                        style: AppTextStyle.bodyMedium(context).copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                aiData['mainInsight'],
                style: AppTextStyle.bodyLarge(context).copyWith(
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.security, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ระดับความเสี่ยง: ${aiData['riskLevel']}',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // PREDICTIONS CARD
  // =================================================================

  Widget _buildPredictionsCard() {
    final predictions = _analyticsData['predictions'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  'การพยากรณ์ของ AI',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPredictionItem(
                    'น้ำหนักใน 7 วัน',
                    '${predictions['weightIn7Days']} กก.',
                    Icons.calendar_view_week,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPredictionItem(
                    'น้ำหนักใน 30 วัน',
                    '${predictions['weightIn30Days']} กก.',
                    Icons.calendar_month,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.flag, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'คาดการณ์บรรลุเป้าหมาย',
                          style: AppTextStyle.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          predictions['goalAchievementDate'],
                          style: AppTextStyle.titleMedium(context).copyWith(
                            color: Colors.amber[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildPredictionItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyle.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =================================================================
  // OVERALL SCORE CARD
  // =================================================================

  Widget _buildOverallScoreCard() {
    final score = (_analyticsData['overallScore'] as num).toInt();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryPurple.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              'คะแนนสุขภาพโดยรวม',
              style: AppTextStyle.titleLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: score / 100.0,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getScoreColor(score)
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$score',
                      style: AppTextStyle.headlineLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(score),
                        fontSize: 48,
                      ),
                    ),
                    Text(
                      'คะแนน',
                      style: AppTextStyle.bodyLarge(context).copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _getScoreDescription(score),
              style: AppTextStyle.titleMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: _getScoreColor(score),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // BEHAVIOR ANALYSIS CARD
  // =================================================================

  Widget _buildBehaviorAnalysisCard() {
    final behaviorData = _analyticsData['behaviorAnalysis'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology_alt, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  'การวิเคราะห์พฤติกรรม',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...behaviorData['patterns']
                .map<Widget>((pattern) => _buildPatternItem(pattern))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternItem(Map<String, dynamic> pattern) {
    Color borderColor;
    Color bgColor;
    IconData icon;

    switch (pattern['type']) {
      case 'positive':
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        icon = Icons.check_circle;
        break;
      case 'warning':
        borderColor = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
        icon = Icons.warning;
        break;
      default:
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
        icon = Icons.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: borderColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'รูปแบบที่ AI พบ',
                  style: AppTextStyle.bodyMedium(context).copyWith(
                    color: borderColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pattern['pattern'],
            style: AppTextStyle.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pattern['insight'],
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // AI RECOMMENDATIONS CARD
  // =================================================================

  Widget _buildAIRecommendationsCard() {
    final recommendations = _analyticsData['aiRecommendations']
    as List<Map<String, dynamic>>;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'คำแนะนำจาก AI',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...recommendations
                .map<Widget>((rec) => _buildRecommendationItem(rec))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (recommendation['color'] as Color).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (recommendation['color'] as Color).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                recommendation['icon'] as IconData,
                color: recommendation['color'] as Color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendation['title'] as String,
                  style: AppTextStyle.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getImpactColor(recommendation['impact']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recommendation['impact'],
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation['description'] as String,
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.verified, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'ความเชื่อมั่น ${recommendation['confidence']}%',
                style: AppTextStyle.bodySmall(context).copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =================================================================
  // WEEKLY PATTERN CARD
  // =================================================================

  Widget _buildWeeklyPatternCard() {
    final weeklyData = _analyticsData['weeklyPattern']
    as List<Map<String, dynamic>>;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_week, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  'AI วิเคราะห์รูปแบบรายสัปดาห์',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weeklyData.map<Widget>((data) {
                final score = (data['score'] as num).toDouble();
                final color = _getPatternColor(score);
                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 80 * score,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data['day'] as String,
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(score * 100).toInt()}%',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.1),
                    Colors.purple.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'AI Insights',
                        style: AppTextStyle.titleMedium(context).copyWith(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• วันจันทร์และศุกร์มีประสิทธิภาพสูงสุด (90%)\n• วันเสาร์-อาทิตย์มีการปฏิบัติตามแผนลดลง 50%\n• แนะนำให้เตรียมแผนพิเศษสำหรับวันหยุด',
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      color: Colors.blue[700],
                      height: 1.4,
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

  // =================================================================
  // PROGRESS SUMMARY CARD
  // =================================================================

  Widget _buildProgressSummaryCard() {
    final progress = _analyticsData['weeklyProgress'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'สรุปความคืบหน้า ($_selectedPeriod)',
              style: AppTextStyle.titleLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'น้ำหนัก',
                    '${progress['weightLoss']} กก.',
                    'ลดลง',
                    Icons.trending_down,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressItem(
                    'ออกกำลังกาย',
                    '${progress['exerciseCompleted']}/${progress['exerciseGoal']}',
                    'วัน',
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressItem(
                    'แคลอรี่เฉลี่ย',
                    '${progress['calorieAverage']}',
                    'kcal/วัน',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressItem(
                    'ดื่มน้ำ',
                    '${progress['waterCompleted']}/${progress['waterGoal']}',
                    'วัน',
                    Icons.water_drop,
                    Colors.cyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
      String title,
      String value,
      String unit,
      IconData icon,
      Color color
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyle.titleLarge(context).copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyle.bodyMedium(context).copyWith(
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =================================================================
  // HELPER FUNCTIONS
  // =================================================================

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 80) return 'ยอดเยี่ยม! สุขภาพดีมาก';
    if (score >= 60) return 'ดี แต่ยังปรับปรุงได้';
    return 'ควรปรับปรุงเร่งด่วน';
  }

  Color _getPatternColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'สูง':
        return Colors.red;
      case 'กลาง':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}