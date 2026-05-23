/// Abstract repository untuk Onboarding
abstract class OnboardingRepository {
  /// Check apakah onboarding sudah selesai
  Future<bool> isOnboardingCompleted();

  /// Tandai onboarding sebagai selesai
  Future<void> completeOnboarding();

  /// Reset status onboarding
  Future<void> resetOnboarding();
}
