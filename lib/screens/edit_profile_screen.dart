import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile? initialProfile;

  const EditProfileScreen({Key? key, this.initialProfile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _targetWeightController = TextEditingController();
  String _selectedGender = 'ชาย';
  String _selectedActivityLevel = 'ปานกลาง (ออกกำลังกาย 3-5 วัน/สัปดาห์)';
  String _selectedGoal = 'ลดน้ำหนัก';

  final List<String> _genders = ['ชาย', 'หญิง'];
  final List<String> _activityLevels = [
    'น้อยมาก (ไม่ออกกำลังกาย)',
    'น้อย (ออกกำลังกาย 1-3 วัน/สัปดาห์)',
    'ปานกลาง (ออกกำลังกาย 3-5 วัน/สัปดาห์)',
    'มาก (ออกกำลังกาย 6-7 วัน/สัปดาห์)',
    'มากที่สุด (ออกกำลังกายหนักทุกวัน)',
  ];
  final List<String> _goals = ['ลดน้ำหนัก', 'เพิ่มน้ำหนัก', 'รักษาน้ำหนัก'];

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      _nameController.text = widget.initialProfile!.name;
      _weightController.text = widget.initialProfile!.weight.toString();
      _heightController.text = widget.initialProfile!.height.toString();
      _ageController.text = widget.initialProfile!.age.toString();
      _targetWeightController.text = widget.initialProfile!.targetWeight.toString();
      _selectedGender = widget.initialProfile!.gender;
      _selectedActivityLevel = widget.initialProfile!.activityLevel;
      _selectedGoal = widget.initialProfile!.goal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('ข้อมูลส่วนตัว'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'ชื่อ',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildGenderSelector(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageController,
                  label: 'อายุ',
                  keyboardType: TextInputType.number,
                  suffix: 'ปี',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอายุ';
                    }
                    if (int.tryParse(value) == null) {
                      return 'กรุณากรอกตัวเลข';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('ข้อมูลร่างกาย'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _weightController,
                  label: 'น้ำหนักปัจจุบัน',
                  keyboardType: TextInputType.number,
                  suffix: 'กก.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกน้ำหนัก';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณากรอกตัวเลข';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _heightController,
                  label: 'ส่วนสูง',
                  keyboardType: TextInputType.number,
                  suffix: 'ซม.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกส่วนสูง';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณากรอกตัวเลข';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('เป้าหมาย'),
                const SizedBox(height: 16),
                _buildDropdownField(
                  value: _selectedGoal,
                  items: _goals,
                  label: 'เป้าหมาย',
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGoal = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _targetWeightController,
                  label: 'น้ำหนักเป้าหมาย',
                  keyboardType: TextInputType.number,
                  suffix: 'กก.',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกน้ำหนักเป้าหมาย';
                    }
                    if (double.tryParse(value) == null) {
                      return 'กรุณากรอกตัวเลข';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  value: _selectedActivityLevel,
                  items: _activityLevels,
                  label: 'ระดับการออกกำลังกาย',
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedActivityLevel = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'บันทึก',
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
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.titleMedium(context).copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'เพศ',
          style: AppTextStyle.bodyMedium(context),
        ),
        const SizedBox(height: 8),
        Row(
          children: _genders.map((gender) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = gender;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedGender == gender
                        ? AppTheme.primaryPurple
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      gender,
                      style: TextStyle(
                        color: _selectedGender == gender
                            ? Colors.white
                            : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = UserProfile(
        name: _nameController.text,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        targetWeight: double.parse(_targetWeightController.text),
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
      );

      Navigator.pop(context, profile);
    }
  }
}
