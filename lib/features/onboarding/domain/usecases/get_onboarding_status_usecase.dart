import 'package:sisasaku/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case untuk mendapatkan status onboarding
class GetOnboardingStatusUsecase {
  final OnboardingRepository _repository;

  GetOnboardingStatusUsecase(this._repository);

  /// Mengembalikan true jika onboarding sudah selesai
  Future<bool> call() async {
    return await _repository.isOnboardingCompleted();
  }
}
