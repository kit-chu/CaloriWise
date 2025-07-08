import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _ageController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedGender = 'ชาย';
  String _selectedActivityLevel = 'ปานกลาง';
  String _selectedGoal = 'ลดน้ำหนัก';
  bool _isLoading = false;

  // Activity levels with descriptions
  final Map<String, Map<String, dynamic>> _activityLevels = {
    'น้อยมาก': {
      'title': 'น้อยมาก',
      'description': 'นั่งทำงาน ไม่ค่อยเคลื่อนไหว',
      'icon': Icons.event_seat,
      'multiplier': 1.2,
    },
    'น้อย': {
      'title': 'น้อย',
      'description': 'ออกกำลังกาย 1-3 วัน/สัปดาห์',
      'icon': Icons.directions_walk,
      'multiplier': 1.375,
    },
    'ปานกลาง': {
      'title': 'ปานกลาง',
      'description': 'ออกกำลังกาย 3-5 วัน/สัปดาห์',
      'icon': Icons.directions_run,
      'multiplier': 1.55,
    },
    'มาก': {
      'title': 'มาก',
      'description': 'ออกกำลังกาย 6-7 วัน/สัปดาห์',
      'icon': Icons.fitness_center,
      'multiplier': 1.725,
    },
    'มากมาย': {
      'title': 'มากมาย',
      'description': 'ออกกำลังกายหนัก 2 ครั้ง/วัน',
      'icon': Icons.sports_gymnastics,
      'multiplier': 1.9,
    },
  };

  final Map<String, Map<String, dynamic>> _goals = {
    'ลดน้ำหนัก': {
      'title': 'ลดน้ำหนัก',
      'description': 'เผาผลาญไขมันและควบคุมน้ำหนัก',
      'icon': Icons.trending_down,
      'color': Colors.green,
    },
    'เพิ่มน้ำหนัก': {
      'title': 'เพิ่มน้ำหนัก',
      'description': 'เพิ่มมวลกล้ามเนื้อและน้ำหนัก',
      'icon': Icons.trending_up,
      'color': Colors.blue,
    },
    'รักษาน้ำหนัก': {
      'title': 'รักษาน้ำหนัก',
      'description': 'คงน้ำหนักและสร้างกล้ามเนื้อ',
      'icon': Icons.timeline,
      'color': Colors.orange,
    },
    'เพิ่มกล้ามเนื้อ': {
      'title': 'เพิ่มกล้ามเนื้อ',
      'description': 'สร้างมวลกล้ามเนื้อแบบลีน',
      'icon': Icons.fitness_center,
      'color': Colors.purple,
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadUserData();
    _animationController.forward();
  }

  void _loadUserData() {
    // Load existing user data
    _nameController.text = 'คุณกิตติคุณ';
    _heightController.text = '175';
    _weightController.text = '67.5';
    _targetWeightController.text = '65';
    _ageController.text = '30';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  double get _calculatedBMI {
    if (_heightController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      final height = double.tryParse(_heightController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0;
      if (height > 0 && weight > 0) {
        return weight / ((height / 100) * (height / 100));
      }
    }
    return 0;
  }

  double get _calculatedBMR {
    if (_heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty) {
      final height = double.tryParse(_heightController.text) ?? 0;
      final weight = double.tryParse(_weightController.text) ?? 0;
      final age = double.tryParse(_ageController.text) ?? 0;

      if (height > 0 && weight > 0 && age > 0) {
        if (_selectedGender == 'ชาย') {
          return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
        } else {
          return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
        }
      }
    }
    return 0;
  }

  double get _calculatedTDEE {
    final bmr = _calculatedBMR;
    final multiplier = _activityLevels[_selectedActivityLevel]?['multiplier'] ?? 1.2;
    return bmr * multiplier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 32),
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              _buildGoalSelectionSection(),
              const SizedBox(height: 20),
              _buildWeightSection(),
              const SizedBox(height: 20),
              _buildActivitySelectionSection(),
              const SizedBox(height: 20),
              _buildCalculationsCard(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('แก้ไขโปรไฟล์'),
      backgroundColor: AppTheme.primaryPurple,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isLoading ? null : _saveProfile,
          icon: _isLoading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Icon(Icons.check, color: Colors.white),
          label: const Text(
            'บันทึก',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.8),
                  AppTheme.primaryPurple.withValues(alpha: 0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryPurple,
                  size: 20,
                ),
                onPressed: () {
                  _showImagePicker();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ข้อมูลพื้นฐาน',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStyledTextField(
              controller: _nameController,
              label: 'ชื่อ-นามสกุล',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกชื่อ-นามสกุล';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStyledTextField(
                    controller: _ageController,
                    label: 'อายุ',
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    suffix: 'ปี',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอายุ';
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 10 || age > 100) {
                        return 'อายุไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildGenderSelector(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildStyledTextField(
              controller: _heightController,
              label: 'ส่วนสูง',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              suffix: 'ซม.',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกส่วนสูง';
                }
                final height = double.tryParse(value);
                if (height == null || height < 100 || height > 250) {
                  return 'ส่วนสูงไม่ถูกต้อง';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เพศ',
          style: AppTextStyle.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption('ชาย', Icons.male),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGenderOption('หญิง', Icons.female),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              gender,
              style: AppTextStyle.bodySmall(context).copyWith(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelectionSection() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'เป้าหมายหลัก',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals.entries.elementAt(index);
                return _buildGoalOption(goal.key, goal.value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String goalKey, Map<String, dynamic> goalData) {
    final isSelected = _selectedGoal == goalKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = goalKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? goalData['color'] : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? goalData['color'] : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: goalData['color'].withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              goalData['icon'],
              color: isSelected ? Colors.white : goalData['color'],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              goalData['title'],
              style: AppTextStyle.bodyMedium(context).copyWith(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              goalData['description'],
              style: AppTextStyle.bodySmall(context).copyWith(
                color: isSelected ? Colors.white.withValues(alpha: 0.9) : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSection() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.monitor_weight,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ข้อมูลน้ำหนัก',
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
                  child: _buildStyledTextField(
                    controller: _weightController,
                    label: 'น้ำหนักปัจจุบัน',
                    icon: Icons.monitor_weight,
                    keyboardType: TextInputType.number,
                    suffix: 'กก.',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกน้ำหนัก';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null || weight < 20 || weight > 300) {
                        return 'น้ำหนักไม่ถูกต้อง';
                      }
                      return null;
                    },
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStyledTextField(
                    controller: _targetWeightController,
                    label: 'น้ำหนักเป้าหมาย',
                    icon: Icons.track_changes,
                    keyboardType: TextInputType.number,
                    suffix: 'กก.',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกเป้าหมาย';
                      }
                      final targetWeight = double.tryParse(value);
                      if (targetWeight == null || targetWeight < 20 || targetWeight > 300) {
                        return 'น้ำหนักไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySelectionSection() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ระดับกิจกรรม',
                  style: AppTextStyle.titleLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: _activityLevels.entries.map((entry) {
                return _buildActivityOption(entry.key, entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOption(String activityKey, Map<String, dynamic> activityData) {
    final isSelected = _selectedActivityLevel == activityKey;
    return GestureDetector(
      onTap: () => setState(() => _selectedActivityLevel = activityKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryPurple : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryPurple : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                activityData['icon'],
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activityData['title'],
                    style: AppTextStyle.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryPurple : Colors.grey[800],
                    ),
                  ),
                  Text(
                    activityData['description'],
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationsCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
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
              AppTheme.primaryPurple.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calculate,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ข้อมูลที่คำนวณได้',
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
                  child: _buildCalculationItem(
                    'BMI',
                    _calculatedBMI > 0 ? _calculatedBMI.toStringAsFixed(1) : '--',
                    _getBMICategory(_calculatedBMI),
                    Icons.health_and_safety,
                    _getBMIColor(_calculatedBMI),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCalculationItem(
                    'BMR',
                    _calculatedBMR > 0 ? '${_calculatedBMR.toStringAsFixed(0)} kcal' : '--',
                    'พลังงานพื้นฐาน/วัน',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCalculationItem(
              'TDEE',
              _calculatedTDEE > 0 ? '${_calculatedTDEE.toStringAsFixed(0)} kcal/วัน' : '--',
              'พลังงานที่ใช้ทั้งหมดต่อวัน',
              Icons.insights,
              AppTheme.primaryPurple,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationItem(
      String title,
      String value,
      String description,
      IconData icon,
      Color color, {
        bool isFullWidth = false,
      }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: isFullWidth
          ? Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title: $value',
                  style: AppTextStyle.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : Column(
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
            style: AppTextStyle.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            description,
            style: AppTextStyle.bodySmall(context).copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? suffix,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryPurple),
            suffixText: suffix,
            suffixStyle: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryPurple, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple,
            AppTheme.primaryPurple.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'กำลังบันทึก...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'บันทึกการเปลี่ยนแปลง',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'เลือกรูปโปรไฟล์',
              style: AppTextStyle.titleLarge(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImagePickerOption(
                    'กล้อง',
                    Icons.camera_alt,
                        () {
                      Navigator.pop(context);
                      // TODO: Implement camera picker
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImagePickerOption(
                    'แกลเลอรี่',
                    Icons.photo_library,
                        () {
                      Navigator.pop(context);
                      // TODO: Implement gallery picker
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryPurple, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyle.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'น้ำหนักน้อย';
    if (bmi < 25) return 'ปกติ';
    if (bmi < 30) return 'เกินมาตรฐาน';
    return 'อ้วน';
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulate saving delay
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _isLoading = false);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    }
  }
}