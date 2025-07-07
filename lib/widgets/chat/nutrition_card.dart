import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';

class NutritionCard extends StatelessWidget {
  final String foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imageUrl;

  const NutritionCard({
    super.key,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              foodName,
              style: AppTextStyle.titleMedium(context),
            ),
            const SizedBox(height: 8),
            Text(
              '$calories kcal',
              style: AppTextStyle.headlineSmall(context).copyWith(
                color: AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutrientInfo(
                  label: 'Protein',
                  value: '${protein}g',
                  color: Colors.blue,
                ),
                _NutrientInfo(
                  label: 'Carbs',
                  value: '${carbs}g',
                  color: Colors.green,
                ),
                _NutrientInfo(
                  label: 'Fat',
                  value: '${fat}g',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientInfo extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutrientInfo({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyle.titleMedium(context).copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyle.bodySmall(context),
        ),
      ],
    );
  }
}
