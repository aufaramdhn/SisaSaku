import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Handles PIN hashing using SHA-256 with a static app salt.
/// The salt prevents rainbow table attacks while remaining
/// deterministic for verification.
class PinHashService {
  static const _salt = 'sisasaku_pin_salt_v1';

  /// Hashes a PIN using SHA-256 with a static salt.
  static String hashPin(String pin) {
    final bytes = utf8.encode('$_salt:$pin');
    return sha256.convert(bytes).toString();
  }

  /// Verifies a PIN against a stored hash by comparing hashes.
  static bool verifyPin(String pin, String storedHash) {
    return hashPin(pin) == storedHash;
  }
}
