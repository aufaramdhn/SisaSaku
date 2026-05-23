/// Model untuk Onboarding state (wraps SharedPreferences data)
class OnboardingModel {
  final bool isCompleted;
  final DateTime? completedAt;

  OnboardingModel({
    this.isCompleted = false,
    this.completedAt,
  });

  OnboardingModel copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return OnboardingModel(
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'is_completed': isCompleted,
        'completed_at': completedAt?.toIso8601String(),
      };

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }
}
