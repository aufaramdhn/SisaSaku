/// Represents the lock screen visibility status.
enum LockScreenStatus { hidden, visible }

/// Immutable state class representing the current security configuration.
class SecurityState {
  final bool pinEnabled;
  final bool biometricEnabled;
  final LockScreenStatus lockScreenStatus;

  const SecurityState({
    this.pinEnabled = false,
    this.biometricEnabled = false,
    this.lockScreenStatus = LockScreenStatus.hidden,
  });

  SecurityState copyWith({
    bool? pinEnabled,
    bool? biometricEnabled,
    LockScreenStatus? lockScreenStatus,
  }) {
    return SecurityState(
      pinEnabled: pinEnabled ?? this.pinEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      lockScreenStatus: lockScreenStatus ?? this.lockScreenStatus,
    );
  }

  /// Invariant: biometric cannot be enabled if PIN is disabled.
  bool get isValid => !biometricEnabled || pinEnabled;
}

/// Validates PIN input format.
class PinValidator {
  /// Returns true if the PIN is exactly 4–6 numeric digits (0–9).
  static bool isValid(String pin) {
    if (pin.length < 4 || pin.length > 6) return false;
    return RegExp(r'^[0-9]+$').hasMatch(pin);
  }
}
