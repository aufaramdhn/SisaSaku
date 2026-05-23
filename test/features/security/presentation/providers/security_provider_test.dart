import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sisasaku/features/security/data/services/biometric_service.dart';
import 'package:sisasaku/features/security/data/services/pin_hash_service.dart';
import 'package:sisasaku/features/security/data/services/pin_storage_service.dart';
import 'package:sisasaku/features/security/domain/models/security_state.dart';
import 'package:sisasaku/features/security/presentation/providers/security_provider.dart';

/// Property-Based Tests for SecurityNotifier.
///
/// Property 9: Lock screen display is idempotent
///   Calling showLockScreen() when already visible does not change state.
///
/// Property 5: PIN change replaces stored hash
///   After changePin(oldPin, newPin), verifyPin(newPin) returns true and
///   verifyPin(oldPin) returns false.
///
/// Property 6: Disabling PIN clears all security state
///   After disablePin, both pinEnabled and biometricEnabled are false.
///
/// Property 10: Storage failure preserves state
///   If secure storage throws, security state remains unchanged.
///
/// Property 8: Biometric failure falls back to PIN
///   If biometric fails, lock screen remains visible and PIN entry is available.
///
/// Property 4: App resume triggers lock when PIN enabled
///   When pinEnabled is true and lockScreenStatus is hidden,
///   showLockScreen() transitions to visible.

/// Number of random iterations per property test.
const int _kNumIterations = 300;

/// Fixed seed for reproducibility.
const int _kRandomSeed = 0xDEAD01;

/// Generates a random valid PIN (4–6 numeric digits).
String _generateValidPin(Random rng) {
  final length = 4 + rng.nextInt(3); // 4, 5, or 6
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(rng.nextInt(10));
  }
  return buffer.toString();
}

/// Generates a random valid PIN that is guaranteed to be different from [other].
String _generateDifferentPin(Random rng, String other) {
  String pin;
  var attempts = 0;
  do {
    pin = _generateValidPin(rng);
    attempts++;
    if (attempts > 100) {
      final lastDigit = int.parse(other[other.length - 1]);
      final newDigit = (lastDigit + 1) % 10;
      pin = other.substring(0, other.length - 1) + newDigit.toString();
      break;
    }
  } while (pin == other);
  return pin;
}

// =============================================================================
// Fake Services
// =============================================================================

/// A fake PinStorageService that stores the hash in memory.
/// Can be configured to throw on operations.
class FakePinStorageService implements PinStorageService {
  String? _storedHash;
  bool shouldThrow = false;

  @override
  Future<void> storePinHash(String hash) async {
    if (shouldThrow) throw Exception('Storage write failed');
    _storedHash = hash;
  }

  @override
  Future<String?> readPinHash() async {
    if (shouldThrow) throw Exception('Storage read failed');
    return _storedHash;
  }

  @override
  Future<void> deletePinHash() async {
    if (shouldThrow) throw Exception('Storage delete failed');
    _storedHash = null;
  }

  @override
  Future<bool> hasPinHash() async {
    if (shouldThrow) throw Exception('Storage read failed');
    return _storedHash != null && _storedHash!.isNotEmpty;
  }
}

/// A fake BiometricService that can be configured to succeed or fail.
class FakeBiometricService implements BiometricService {
  bool _shouldAuthenticate = false;
  bool _isSupported = true;

  set shouldAuthenticate(bool value) => _shouldAuthenticate = value;
  set isSupported(bool value) => _isSupported = value;

  @override
  Future<bool> isDeviceSupported() async => _isSupported;

  @override
  Future<bool> canCheckBiometrics() async => _isSupported;

  @override
  Future<bool> authenticate({String reason = ''}) async =>
      _shouldAuthenticate;
}

// =============================================================================
// Helper to create a SecurityNotifier with fakes
// =============================================================================

/// Creates a SecurityNotifier with fake services and an optional initial PIN.
Future<({SecurityNotifier notifier, FakePinStorageService storage, FakeBiometricService biometric})>
    _createNotifier({String? initialPin, bool biometricEnabled = false}) async {
  SharedPreferences.setMockInitialValues({
    'pin_lock_enabled': initialPin != null,
    'biometric_auth_enabled': biometricEnabled,
  });

  final storage = FakePinStorageService();
  final biometric = FakeBiometricService();

  if (initialPin != null) {
    final hash = PinHashService.hashPin(initialPin);
    await storage.storePinHash(hash);
  }

  final notifier = SecurityNotifier(
    pinStorage: storage,
    biometric: biometric,
  );

  // Wait for _loadInitialState to complete
  await Future<void>.delayed(Duration.zero);

  return (notifier: notifier, storage: storage, biometric: biometric);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
      'SecurityNotifier - Property 9: Lock screen display is idempotent', () {
    /// **Validates: Requirements 8.4**
    test(
      'Calling showLockScreen() when already visible does not change state '
      '($_kNumIterations iterations)',
      () async {
        final result = await _createNotifier(initialPin: '1234');
        final notifier = result.notifier;
        final rng = Random(_kRandomSeed);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          // Ensure lock screen is visible
          notifier.showLockScreen();
          final stateBeforeSecondCall = notifier.state;

          // Call showLockScreen again (should be idempotent)
          notifier.showLockScreen();
          final stateAfterSecondCall = notifier.state;

          if (stateBeforeSecondCall.pinEnabled !=
                  stateAfterSecondCall.pinEnabled ||
              stateBeforeSecondCall.biometricEnabled !=
                  stateAfterSecondCall.biometricEnabled ||
              stateBeforeSecondCall.lockScreenStatus !=
                  stateAfterSecondCall.lockScreenStatus) {
            failures.add(
              'iteration=$i, stateBefore=$stateBeforeSecondCall, '
              'stateAfter=$stateAfterSecondCall',
            );
          }

          // Reset for next iteration
          notifier.hideLockScreen();

          // Randomly toggle some state to add variety
          if (rng.nextBool()) {
            notifier.showLockScreen();
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 9 violated: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );

        notifier.dispose();
      },
    );
  });

  group('SecurityNotifier - Property 5: PIN change replaces stored hash', () {
    /// **Validates: Requirements 3.3**
    test(
      'After changePin(oldPin, newPin), verifyPin(newPin) returns true '
      'and verifyPin(oldPin) returns false ($_kNumIterations iterations)',
      () async {
        final rng = Random(_kRandomSeed + 1);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final oldPin = _generateValidPin(rng);
          final newPin = _generateDifferentPin(rng, oldPin);

          final result = await _createNotifier(initialPin: oldPin);
          final notifier = result.notifier;

          final changeResult = await notifier.changePin(oldPin, newPin);
          if (!changeResult) {
            failures.add(
              'iteration=$i, changePin failed, oldPin="$oldPin", newPin="$newPin"',
            );
            notifier.dispose();
            continue;
          }

          final newPinVerifies = await notifier.verifyPin(newPin);
          final oldPinVerifies = await notifier.verifyPin(oldPin);

          if (!newPinVerifies || oldPinVerifies) {
            failures.add(
              'iteration=$i, oldPin="$oldPin", newPin="$newPin", '
              'newPinVerifies=$newPinVerifies, oldPinVerifies=$oldPinVerifies',
            );
          }

          notifier.dispose();
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 5 violated: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });

  group('SecurityNotifier - Property 6: Disabling PIN clears all security state',
      () {
    /// **Validates: Requirements 4.2, 4.3**
    test(
      'After disablePin, both pinEnabled and biometricEnabled are false '
      '($_kNumIterations iterations)',
      () async {
        final rng = Random(_kRandomSeed + 2);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final pin = _generateValidPin(rng);
          final withBiometric = rng.nextBool();

          final result = await _createNotifier(
            initialPin: pin,
            biometricEnabled: withBiometric,
          );
          final notifier = result.notifier;

          final disableResult = await notifier.disablePin(pin);
          if (!disableResult) {
            failures.add('iteration=$i, disablePin failed, pin="$pin"');
            notifier.dispose();
            continue;
          }

          final state = notifier.state;
          if (state.pinEnabled || state.biometricEnabled) {
            failures.add(
              'iteration=$i, pin="$pin", withBiometric=$withBiometric, '
              'pinEnabled=${state.pinEnabled}, '
              'biometricEnabled=${state.biometricEnabled}',
            );
          }

          notifier.dispose();
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 6 violated: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });

  group('SecurityNotifier - Property 10: Storage failure preserves state', () {
    /// **Validates: Requirements 7.4**
    test(
      'If secure storage throws, security state remains unchanged '
      '($_kNumIterations iterations)',
      () async {
        final rng = Random(_kRandomSeed + 3);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final pin = _generateValidPin(rng);
          final result = await _createNotifier(initialPin: pin);
          final notifier = result.notifier;
          final storage = result.storage;

          final stateBefore = notifier.state;

          // Enable storage failures
          storage.shouldThrow = true;

          // Try setupPin — should fail gracefully
          final newPin = _generateValidPin(rng);
          await notifier.setupPin(newPin);

          final stateAfter = notifier.state;

          if (stateBefore.pinEnabled != stateAfter.pinEnabled ||
              stateBefore.biometricEnabled != stateAfter.biometricEnabled ||
              stateBefore.lockScreenStatus != stateAfter.lockScreenStatus) {
            failures.add(
              'iteration=$i, pin="$pin", '
              'stateBefore=(pin=${stateBefore.pinEnabled}, '
              'bio=${stateBefore.biometricEnabled}, '
              'lock=${stateBefore.lockScreenStatus}), '
              'stateAfter=(pin=${stateAfter.pinEnabled}, '
              'bio=${stateAfter.biometricEnabled}, '
              'lock=${stateAfter.lockScreenStatus})',
            );
          }

          notifier.dispose();
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 10 violated: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });

  group(
      'SecurityNotifier - Property 8: Biometric failure falls back to PIN',
      () {
    /// **Validates: Requirements 5.4**
    test(
      'If biometric fails, lock screen remains visible and PIN entry is '
      'available ($_kNumIterations iterations)',
      () async {
        final rng = Random(_kRandomSeed + 4);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final pin = _generateValidPin(rng);
          final result = await _createNotifier(
            initialPin: pin,
            biometricEnabled: true,
          );
          final notifier = result.notifier;
          final biometric = result.biometric;

          // Configure biometric to fail
          biometric.shouldAuthenticate = false;

          // Show lock screen
          notifier.showLockScreen();

          // Attempt biometric authentication (should fail)
          final bioResult = await notifier.authenticateWithBiometric();

          // Lock screen should still be visible
          final lockVisible =
              notifier.state.lockScreenStatus == LockScreenStatus.visible;

          // PIN verification should still work (fallback available)
          final pinWorks = await notifier.verifyPin(pin);

          if (bioResult || !lockVisible || !pinWorks) {
            failures.add(
              'iteration=$i, pin="$pin", bioResult=$bioResult, '
              'lockVisible=$lockVisible, pinWorks=$pinWorks',
            );
          }

          notifier.dispose();
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 8 violated: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });

  group(
      'SecurityNotifier - Property 4: App resume triggers lock when PIN enabled',
      () {
    /// **Validates: Requirements 2.1, 8.2**
    test(
      'When pinEnabled is true and lockScreenStatus is hidden, '
      'showLockScreen() transitions to visible ($_kNumIterations iterations)',
      () async {
        final rng = Random(_kRandomSeed + 5);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final pin = _generateValidPin(rng);
          final withBiometric = rng.nextBool();

          final result = await _createNotifier(
            initialPin: pin,
            biometricEnabled: withBiometric,
          );
          final notifier = result.notifier;

          // Ensure lock screen is hidden
          notifier.hideLockScreen();
          expect(notifier.state.pinEnabled, isTrue);
          expect(notifier.state.lockScreenStatus, LockScreenStatus.hidden);

          // Simulate app resume triggering lock
          notifier.showLockScreen();

          if (notifier.state.lockScreenStatus != LockScreenStatus.visible) {
            failures.add(
              'iteration=$i, pin="$pin", biometric=$withBiometric, '
              'lockStatus=${notifier.state.lockScreenStatus}',
            );
          }

          notifier.dispose();
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 4 violated: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });
}
