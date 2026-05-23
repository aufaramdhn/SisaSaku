import 'package:local_auth/local_auth.dart';

/// Wraps the local_auth package for biometric capability check and authentication.
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  /// Returns true if the device supports biometric authentication.
  Future<bool> isDeviceSupported() async {
    return _auth.isDeviceSupported();
  }

  /// Returns true if the device can check biometrics (has enrolled biometrics).
  Future<bool> canCheckBiometrics() async {
    return _auth.canCheckBiometrics;
  }

  /// Attempts biometric authentication. Returns true on success.
  Future<bool> authenticate({
    String reason = 'Autentikasi untuk membuka aplikasi',
  }) async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
