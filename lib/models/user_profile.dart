class UserProfile {
  String name;
  double weight;
  double height;
  int age;
  String gender;
  double targetWeight;
  String activityLevel;
  String goal;

  UserProfile({
    required this.name,
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.targetWeight,
    required this.activityLevel,
    required this.goal,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'targetWeight': targetWeight,
      'activityLevel': activityLevel,
      'goal': goal,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      weight: json['weight'],
      height: json['height'],
      age: json['age'],
      gender: json['gender'],
      targetWeight: json['targetWeight'],
      activityLevel: json['activityLevel'],
      goal: json['goal'],
    );
  }
}
