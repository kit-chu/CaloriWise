import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsTap;
  final int? streakDays;
  final int? heartRate; // เพิ่มพารามิเตอร์สำหรับอัตราการเต้นหัวใจ

  const AppTopBar({
    super.key,
    required this.title,
    this.onSettingsTap,
    this.streakDays,
    this.heartRate, // เพิ่มพารามิเตอร์ในคอนสตรัคเตอร์
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundLight,
      elevation: 0,
      title: Row(
        children: [
          // Logo
          Image.asset(
            'assets/images/app_logo.png',
            height: 32,
            width: 32,
          ),
          const SizedBox(width: 8),
          // App name
          Text(
            title,
            style: AppTextStyle.titleLarge(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      actions: [
        // Heart rate capsule
        if (heartRate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(30),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.red[400],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$heartRate bpm',
                  style: AppTextStyle.labelMedium(context).copyWith(
                    color: Colors.red[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        // Streak capsule
        if (streakDays != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryCoral.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: AppTheme.primaryCoral,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streakDays day',
                  style: AppTextStyle.labelMedium(context).copyWith(
                    color: AppTheme.primaryCoral,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
