import 'package:sisasaku/features/onboarding/data/datasources/onboarding_local_datasource.dart';
import 'package:sisasaku/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Repository implementation untuk Onboarding
class OnboardingRepositoryImpl extends OnboardingRepository {
  final OnboardingLocalDatasource localDatasource;

  OnboardingRepositoryImpl(this.localDatasource);

  @override
  Future<bool> isOnboardingCompleted() async {
    return localDatasource.isOnboardingCompleted();
  }

  @override
  Future<void> completeOnboarding() async {
    await localDatasource.setOnboardingCompleted();
  }

  @override
  Future<void> resetOnboarding() async {
    await localDatasource.resetOnboarding();
  }
}
