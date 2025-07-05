import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';
import '../models/macro_data.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class MacroTrackingCard extends StatelessWidget {
  final MacroData data;

  const MacroTrackingCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMacroCard(
            context: context,
            label: 'โปรตีน',
            value: data.protein,
            goal: data.proteinGoal,
            color: const Color(0xFF10B981), // Green
            icon: Icons.egg_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMacroCard(
            context: context,
            label: 'คาร์บ',
            value: data.carbs,
            goal: data.carbsGoal,
            color: const Color(0xFFF59E0B), // Orange
            icon: Icons.breakfast_dining,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMacroCard(
            context: context,
            label: 'ไขมัน',
            value: data.fat,
            goal: data.fatGoal,
            color: const Color(0xFF7C3AED), // Purple
            icon: Icons.water_drop,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard({
    required BuildContext context,
    required String label,
    required double value,
    required double goal,
    required Color color,
    required IconData icon,
  }) {
    final percentage = (value / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 32.0,
            lineWidth: 8.0,
            animation: true,
            animationDuration: 1000,
            percent: percentage,
            center: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            progressColor: color,
            backgroundColor: color.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyle.titleSmall(context).copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toInt()}/${goal.toInt()}g',
            style: AppTextStyle.titleSmall(context).copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${(percentage * 100).toInt()}%',
            style: AppTextStyle.labelMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
