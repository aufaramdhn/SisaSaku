import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sisasaku/features/security/data/services/pin_hash_service.dart';

/// Property-Based Tests for PinHashService.
///
/// These tests validate two correctness properties:
///
/// Property 1: PIN verification round-trip
///   For any valid PIN (4–6 numeric digits), hashing the PIN and then
///   verifying the same PIN against the stored hash shall return true.
///
/// Property 3: Incorrect PIN always rejected
///   For any valid PIN stored as a hash and any different PIN entered for
///   verification, the verification shall return false.
///
/// Approach: Manual property-based testing using dart:math Random with a fixed
/// seed for reproducibility. Generates random valid PINs and asserts properties
/// hold across 300+ iterations.

/// Number of random iterations per property test.
const int _kNumIterations = 300;

/// Fixed seed for reproducibility.
const int _kRandomSeed = 0xBEEF42;

/// Generates a random valid PIN (4–6 numeric digits).
String _generateValidPin(Random rng) {
  final length = 4 + rng.nextInt(3); // 4, 5, or 6
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(rng.nextInt(10)); // digit 0–9
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
    // Safety valve: if by extreme coincidence we keep generating the same PIN,
    // just flip the last digit.
    if (attempts > 100) {
      final lastDigit = int.parse(other[other.length - 1]);
      final newDigit = (lastDigit + 1) % 10;
      pin = other.substring(0, other.length - 1) + newDigit.toString();
      break;
    }
  } while (pin == other);
  return pin;
}

void main() {
  group('PinHashService - Property 1: PIN verification round-trip', () {
    /// **Validates: Requirements 1.3, 2.2, 7.2**
    test(
      'For any valid PIN (4–6 digits), hashing and verifying returns true '
      '($_kNumIterations random PINs)',
      () {
        final rng = Random(_kRandomSeed);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final pin = _generateValidPin(rng);
          final hash = PinHashService.hashPin(pin);
          final verified = PinHashService.verifyPin(pin, hash);

          if (!verified) {
            failures.add(
              'iteration=$i, pin="$pin", hash="$hash", verified=$verified',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 1 violated for ${failures.length}/$_kNumIterations cases. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );

    test(
      'Hash output is deterministic — same PIN always produces same hash '
      '($_kNumIterations random PINs)',
      () {
        final rng = Random(_kRandomSeed + 1);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final pin = _generateValidPin(rng);
          final hash1 = PinHashService.hashPin(pin);
          final hash2 = PinHashService.hashPin(pin);

          if (hash1 != hash2) {
            failures.add(
              'iteration=$i, pin="$pin", hash1="$hash1", hash2="$hash2"',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Hash determinism violated for ${failures.length}/$_kNumIterations cases. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });

  group('PinHashService - Property 3: Incorrect PIN always rejected', () {
    /// **Validates: Requirements 1.4, 2.3, 3.4, 4.4**
    test(
      'For any valid PIN stored as hash and any DIFFERENT PIN, '
      'verification returns false ($_kNumIterations random pairs)',
      () {
        final rng = Random(_kRandomSeed + 2);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final originalPin = _generateValidPin(rng);
          final differentPin = _generateDifferentPin(rng, originalPin);
          final storedHash = PinHashService.hashPin(originalPin);
          final verified = PinHashService.verifyPin(differentPin, storedHash);

          if (verified) {
            failures.add(
              'iteration=$i, originalPin="$originalPin", '
              'differentPin="$differentPin", storedHash="$storedHash"',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 3 violated for ${failures.length}/$_kNumIterations cases. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });
}
