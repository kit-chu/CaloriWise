import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'การตั้งค่า',
          style: AppTextStyle.titleLarge(context).copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildMenuItem('แก้ไขโปรไฟล์', 'เปลี่ยนข้อมูลส่วนตัว เป้าหมาย', Icons.edit, Colors.green, (context) => _navigateToEditProfile(context)),
          const Divider(height: 1),
          _buildMenuItem('การแจ้งเตือน', 'ตั้งค่าการแจ้งเตือนต่างๆ', Icons.notifications, Colors.orange, (context) {}),
          const Divider(height: 1),
          _buildMenuItem('ช่วยเหลือและติดต่อ', 'คำถามที่พบบ่อยและการติดต่อ', Icons.help, Colors.teal, (context) {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, String subtitle, IconData icon, Color color, Function(BuildContext) onTap) {
    return Builder(
      builder: (context) => ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: AppTextStyle.titleSmall(context).copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: AppTextStyle.bodySmall(context).copyWith(color: Colors.grey[600])),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => onTap(context),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
  }
}
