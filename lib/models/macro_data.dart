class MacroData {
  final double protein;
  final double carbs;
  final double fat;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  MacroData({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
  });

  double get proteinPercentage => (protein / proteinGoal) * 100;
  double get carbsPercentage => (carbs / carbsGoal) * 100;
  double get fatPercentage => (fat / fatGoal) * 100;
}
