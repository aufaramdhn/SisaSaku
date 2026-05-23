import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/features/security/data/services/biometric_service.dart';
import 'package:sisasaku/features/security/data/services/pin_hash_service.dart';
import 'package:sisasaku/features/security/data/services/pin_storage_service.dart';
import 'package:sisasaku/features/security/data/services/security_preferences_service.dart';
import 'package:sisasaku/features/security/domain/models/security_state.dart';

/// Central state notifier managing all security state transitions.
class SecurityNotifier extends StateNotifier<SecurityState> {
  final PinStorageService _pinStorage;
  final BiometricService _biometric;

  SecurityNotifier({
    required PinStorageService pinStorage,
    required BiometricService biometric,
  })  : _pinStorage = pinStorage,
        _biometric = biometric,
        super(const SecurityState()) {
    _loadInitialState();
  }

  /// Loads initial security state from persistent storage.
  Future<void> _loadInitialState() async {
    final pinEnabled = await SecurityPreferencesService.isPinLockEnabled();
    final bioEnabled = await SecurityPreferencesService.isBiometricEnabled();
    state = SecurityState(
      pinEnabled: pinEnabled,
      biometricEnabled: bioEnabled,
    );
  }

  /// Sets up a new PIN. Returns true on success.
  Future<bool> setupPin(String pin) async {
    try {
      final hash = PinHashService.hashPin(pin);
      await _pinStorage.storePinHash(hash);
      await SecurityPreferencesService.setPinLockEnabled(true);
      state = state.copyWith(pinEnabled: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Verifies a PIN against stored hash. Returns true if correct.
  Future<bool> verifyPin(String pin) async {
    try {
      final storedHash = await _pinStorage.readPinHash();
      if (storedHash == null) return false;
      return PinHashService.verifyPin(pin, storedHash);
    } catch (_) {
      return false;
    }
  }

  /// Changes PIN after verifying old PIN. Returns true on success.
  Future<bool> changePin(String oldPin, String newPin) async {
    final verified = await verifyPin(oldPin);
    if (!verified) return false;
    final hash = PinHashService.hashPin(newPin);
    await _pinStorage.storePinHash(hash);
    return true;
  }

  /// Disables PIN lock after verification. Also disables biometric.
  Future<bool> disablePin(String pin) async {
    final verified = await verifyPin(pin);
    if (!verified) return false;
    await _clearPinState();
    return true;
  }

  /// Clears all PIN state without verification.
  /// Should only be called after PIN has already been verified externally.
  Future<void> clearPinStateAfterVerification() async {
    await _clearPinState();
  }

  Future<void> _clearPinState() async {
    await _pinStorage.deletePinHash();
    await SecurityPreferencesService.setPinLockEnabled(false);
    await SecurityPreferencesService.setBiometricEnabled(false);
    state = state.copyWith(pinEnabled: false, biometricEnabled: false);
  }

  /// Enables biometric auth. Returns false if device doesn't support it.
  Future<bool> enableBiometric() async {
    if (!state.pinEnabled) return false;
    final supported = await _biometric.isDeviceSupported();
    if (!supported) return false;
    await SecurityPreferencesService.setBiometricEnabled(true);
    state = state.copyWith(biometricEnabled: true);
    return true;
  }

  /// Disables biometric auth.
  Future<void> disableBiometric() async {
    await SecurityPreferencesService.setBiometricEnabled(false);
    state = state.copyWith(biometricEnabled: false);
  }

  /// Shows the lock screen overlay. Idempotent — no-op if already visible.
  void showLockScreen() {
    if (state.lockScreenStatus == LockScreenStatus.visible) return;
    state = state.copyWith(lockScreenStatus: LockScreenStatus.visible);
  }

  /// Hides the lock screen overlay after successful authentication.
  void hideLockScreen() {
    state = state.copyWith(lockScreenStatus: LockScreenStatus.hidden);
  }

  /// Attempts biometric unlock. Returns true on success.
  Future<bool> authenticateWithBiometric() async {
    if (!state.biometricEnabled) return false;
    return _biometric.authenticate();
  }
}

/// Global security state provider.
final securityProvider =
    StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier(
    pinStorage: PinStorageService(),
    biometric: BiometricService(),
  );
});
