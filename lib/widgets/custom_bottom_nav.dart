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
    const navBarHeight = 70.0; // Increased height to accommodate content
    const fabSize = 56.0;
    const fabTopOffset = fabSize / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bottom Navigation Bar with Container for proper height
        Container(
          height: navBarHeight + bottomPadding,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.primaryPurple,
              unselectedItemColor: AppTheme.textSecondary,
              showUnselectedLabels: true,
              selectedLabelStyle: AppTextStyle.labelSmall(context).copyWith(
                fontSize: 9, // Slightly reduced font size
                height: 1.0, // Reduced line height
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: AppTextStyle.labelSmall(context).copyWith(
                fontSize: 9, // Slightly reduced font size
                height: 1.0, // Reduced line height
              ),
              items: [
                _buildNavItem(Icons.home_outlined, Icons.home, 'หน้าหลัก'),
                _buildNavItem(Icons.chat_outlined, Icons.chat, 'Chat AI'),
                // ช่องว่างสำหรับปุ่มกล้อง
                const BottomNavigationBarItem(
                  icon: SizedBox(width: fabSize, height: 24), // Reduced height
                  label: '',
                ),
                _buildNavItem(Icons.add_circle_outline, Icons.add_circle, 'เพิ่มรายการ'),
                _buildNavItem(Icons.group_outlined, Icons.group, 'ชุมชน'),
              ],
            ),
          ),
        ),
        // Camera FAB
        Positioned(
          left: 0,
          right: 0,
          top: -fabTopOffset,
          child: GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: fabSize,
              height: fabSize,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 2), // Reduced padding
        child: Icon(icon, size: 22), // Slightly smaller icon
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 2), // Reduced padding
        child: Icon(activeIcon, size: 22), // Slightly smaller icon
      ),
      label: label,
    );
  }
}