import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles secure PIN hash storage via flutter_secure_storage.
/// Delegates to the OS-level secure enclave (Android Keystore / iOS Keychain).
class PinStorageService {
  static const _pinHashKey = 'pin_hash';
  final FlutterSecureStorage _storage;

  PinStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Stores the PIN hash in secure storage.
  Future<void> storePinHash(String hash) async {
    await _storage.write(key: _pinHashKey, value: hash);
  }

  /// Reads the PIN hash from secure storage. Returns null if not set.
  Future<String?> readPinHash() async {
    return _storage.read(key: _pinHashKey);
  }

  /// Deletes the PIN hash from secure storage.
  Future<void> deletePinHash() async {
    await _storage.delete(key: _pinHashKey);
  }

  /// Returns true if a PIN hash exists in secure storage.
  Future<bool> hasPinHash() async {
    final hash = await readPinHash();
    return hash != null && hash.isNotEmpty;
  }
}
