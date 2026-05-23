import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisasaku/features/onboarding/data/models/onboarding_model.dart';

/// Local datasource untuk Onboarding (SharedPreferences)
class OnboardingLocalDatasource {
  static const _isCompletedKey = 'onboarding_is_completed';
  static const _completedAtKey = 'onboarding_completed_at';

  final SharedPreferences _prefs;

  OnboardingLocalDatasource(this._prefs);

  /// Get onboarding status
  OnboardingModel getOnboardingStatus() {
    final isCompleted = _prefs.getBool(_isCompletedKey) ?? false;
    final completedAtStr = _prefs.getString(_completedAtKey);
    final completedAt =
        completedAtStr != null ? DateTime.tryParse(completedAtStr) : null;

    return OnboardingModel(
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  /// Check apakah onboarding sudah selesai
  bool isOnboardingCompleted() {
    return _prefs.getBool(_isCompletedKey) ?? false;
  }

  /// Tandai onboarding sebagai selesai
  Future<void> setOnboardingCompleted() async {
    final now = DateTime.now();
    await _prefs.setBool(_isCompletedKey, true);
    await _prefs.setString(_completedAtKey, now.toIso8601String());
  }

  /// Reset status onboarding
  Future<void> resetOnboarding() async {
    await _prefs.remove(_isCompletedKey);
    await _prefs.remove(_completedAtKey);
  }
}
