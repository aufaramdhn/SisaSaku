import 'package:sisasaku/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case untuk menyelesaikan onboarding
class CompleteOnboardingUsecase {
  final OnboardingRepository _repository;

  CompleteOnboardingUsecase(this._repository);

  /// Tandai onboarding sebagai selesai
  Future<void> call() async {
    await _repository.completeOnboarding();
  }
}
