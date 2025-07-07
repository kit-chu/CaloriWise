import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          _QuickActionChip(
            label: 'แคลอรี่วันนี้',
            onTap: () {
              // TODO: Implement calorie check
            },
          ),
          _QuickActionChip(
            label: 'เมนูแนะนำ',
            onTap: () {
              // TODO: Implement meal suggestions
            },
          ),
          _QuickActionChip(
            label: 'วิเคราะห์อาหาร',
            onTap: () {
              // TODO: Implement food analysis
            },
          ),
          _QuickActionChip(
            label: 'แนะนำการกิน',
            onTap: () {
              // TODO: Implement diet recommendations
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyle.labelMedium(context).copyWith(
              color: AppTheme.primaryPurple,
            ),
          ),
        ),
      ),
    );
  }
}
