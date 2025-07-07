import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 70 + bottomPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding,
          top: 3,
          left: 6,
          right: 6,
        ),
        child: Row(
          children: [
            _buildNavItem(context, Icons.home_outlined, Icons.home, 'หน้าหลัก', 0),
            _buildNavItem(context, Icons.add_circle_outline, Icons.add_circle, 'เพิ่มอาหาร', 1),
            _buildNavItem(context, Icons.local_fire_department_outlined, Icons.local_fire_department, 'คำนวณแคลอรี่', 2),
            _buildNavItem(context, Icons.chat_bubble_outline, Icons.chat_bubble, 'แชท', 3),
            _buildNavItem(context, Icons.person_outline, Icons.person, 'โปรไฟล์', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, IconData activeIcon, String label, int index) {
    final bool isSelected = currentIndex == index;

    return Flexible(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: isSelected
                      ? BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  )
                      : null,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    size: 19,
                    color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyle.labelSmall(context).copyWith(
                      fontSize: 8,
                      height: 1.0,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryPurple : AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}