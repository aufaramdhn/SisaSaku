import 'package:shared_preferences/shared_preferences.dart';

/// Stores non-sensitive boolean security flags in SharedPreferences.
class SecurityPreferencesService {
  static const _pinEnabledKey = 'pin_lock_enabled';
  static const _biometricEnabledKey = 'biometric_auth_enabled';

  /// Returns whether PIN lock is enabled.
  static Future<bool> isPinLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pinEnabledKey) ?? false;
  }

  /// Sets the PIN lock enabled state.
  static Future<void> setPinLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinEnabledKey, enabled);
  }

  /// Returns whether biometric authentication is enabled.
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Sets the biometric authentication enabled state.
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }
}
