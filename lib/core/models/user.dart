class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final double height; // cm
  final double weight; // kg
  final String fitnessGoal;
  final String activityLevel;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.height,
    required this.weight,
    required this.fitnessGoal,
    required this.activityLevel,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? activityLevel,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
