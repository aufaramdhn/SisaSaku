/// Onboarding entity - pure domain object
class OnboardingEntity {
  final String id;
  final bool isCompleted;
  final DateTime? completedAt;

  OnboardingEntity({
    required this.id,
    required this.isCompleted,
    this.completedAt,
  });

  OnboardingEntity copyWith({
    String? id,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return OnboardingEntity(
      id: id ?? this.id,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => id.hashCode ^ isCompleted.hashCode;
}
