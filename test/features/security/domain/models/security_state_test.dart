import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sisasaku/features/security/domain/models/security_state.dart';

/// Property-Based Tests for PinValidator and SecurityState.
///
/// Property 2: PIN validation accepts only valid input
///   PinValidator.isValid returns true if and only if the string consists of
///   exactly 4 to 6 characters where each character is a digit (0–9).
///
/// Property 7: Biometric requires PIN enabled (invariant)
///   For any SecurityState, if biometricEnabled is true then pinEnabled must
///   also be true. Equivalently, SecurityState with biometricEnabled=true and
///   pinEnabled=false has isValid=false.
///
/// Approach: Manual property-based testing using dart:math Random with a fixed
/// seed for reproducibility.

/// Number of random iterations per property test.
const int _kNumIterations = 300;

/// Fixed seed for reproducibility.
const int _kRandomSeed = 0xCAFE01;

/// All printable ASCII characters for generating random strings.
const String _kAllChars =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    '0123456789!@#\$%^&*()-_=+[]{}|;:,.<>?/~`\' "';

/// Generates a random string of given length from the character set.
String _generateRandomString(Random rng, int length, String charset) {
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(charset[rng.nextInt(charset.length)]);
  }
  return buffer.toString();
}

/// Reference implementation: a PIN is valid iff it's 4–6 chars, all digits.
bool _isValidPinOracle(String pin) {
  if (pin.length < 4 || pin.length > 6) return false;
  for (var i = 0; i < pin.length; i++) {
    final code = pin.codeUnitAt(i);
    if (code < 48 || code > 57) return false; // '0' = 48, '9' = 57
  }
  return true;
}

void main() {
  group('PinValidator - Property 2: PIN validation accepts only valid input',
      () {
    /// **Validates: Requirements 1.5**
    test(
      'PinValidator.isValid matches oracle for random valid PINs '
      '($_kNumIterations iterations)',
      () {
        final rng = Random(_kRandomSeed);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          // Generate a valid PIN (4–6 digits)
          final length = 4 + rng.nextInt(3);
          final buffer = StringBuffer();
          for (var j = 0; j < length; j++) {
            buffer.write(rng.nextInt(10));
          }
          final pin = buffer.toString();

          final actual = PinValidator.isValid(pin);
          final expected = _isValidPinOracle(pin);

          if (actual != expected) {
            failures.add(
              'iteration=$i, pin="$pin", expected=$expected, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 2 violated for valid PINs: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );

    test(
      'PinValidator.isValid matches oracle for random strings '
      '(alphanumeric, special chars, various lengths) '
      '($_kNumIterations iterations)',
      () {
        final rng = Random(_kRandomSeed + 1);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          // Generate random length 0–10
          final length = rng.nextInt(11);
          final str = _generateRandomString(rng, length, _kAllChars);

          final actual = PinValidator.isValid(str);
          final expected = _isValidPinOracle(str);

          if (actual != expected) {
            failures.add(
              'iteration=$i, str="$str" (len=${str.length}), '
              'expected=$expected, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 2 violated for random strings: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );

    test(
      'PinValidator.isValid rejects strings with non-digit characters '
      '($_kNumIterations iterations)',
      () {
        final rng = Random(_kRandomSeed + 2);
        const nonDigitChars = 'abcdefghijklmnopqrstuvwxyz!@#\$%^&*()-_=+';
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          // Generate a string of valid length (4–6) but with at least one
          // non-digit character
          final length = 4 + rng.nextInt(3);
          final buffer = StringBuffer();
          final nonDigitPos = rng.nextInt(length);
          for (var j = 0; j < length; j++) {
            if (j == nonDigitPos) {
              buffer.write(
                  nonDigitChars[rng.nextInt(nonDigitChars.length)]);
            } else {
              buffer.write(rng.nextInt(10));
            }
          }
          final str = buffer.toString();

          final actual = PinValidator.isValid(str);
          if (actual != false) {
            failures.add(
              'iteration=$i, str="$str", expected=false, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 2 violated for non-digit strings: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );

    test(
      'PinValidator.isValid rejects strings with invalid length '
      '($_kNumIterations iterations)',
      () {
        final rng = Random(_kRandomSeed + 3);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          // Generate all-digit string with length outside 4–6
          int length;
          if (rng.nextBool()) {
            length = rng.nextInt(4); // 0–3
          } else {
            length = 7 + rng.nextInt(10); // 7–16
          }
          final buffer = StringBuffer();
          for (var j = 0; j < length; j++) {
            buffer.write(rng.nextInt(10));
          }
          final str = buffer.toString();

          final actual = PinValidator.isValid(str);
          if (actual != false) {
            failures.add(
              'iteration=$i, str="$str" (len=${str.length}), '
              'expected=false, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 2 violated for invalid-length strings: '
              '${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });

  group(
      'SecurityState - Property 7: Biometric requires PIN enabled (invariant)',
      () {
    /// **Validates: Requirements 5.5**
    test(
      'SecurityState with biometricEnabled=true and pinEnabled=false '
      'has isValid=false',
      () {
        const state = SecurityState(
          pinEnabled: false,
          biometricEnabled: true,
        );
        expect(state.isValid, isFalse,
            reason: 'biometricEnabled=true with pinEnabled=false must be invalid');
      },
    );

    test(
      'SecurityState isValid invariant holds for all boolean combinations '
      '(exhaustive)',
      () {
        final boolValues = [true, false];
        final lockStatuses = LockScreenStatus.values;
        final failures = <String>[];

        for (final pinEnabled in boolValues) {
          for (final bioEnabled in boolValues) {
            for (final lockStatus in lockStatuses) {
              final state = SecurityState(
                pinEnabled: pinEnabled,
                biometricEnabled: bioEnabled,
                lockScreenStatus: lockStatus,
              );

              // The invariant: biometric cannot be enabled if PIN is disabled
              final expected = !bioEnabled || pinEnabled;
              final actual = state.isValid;

              if (actual != expected) {
                failures.add(
                  'pinEnabled=$pinEnabled, bioEnabled=$bioEnabled, '
                  'lockStatus=$lockStatus, expected=$expected, actual=$actual',
                );
              }
            }
          }
        }

        expect(
          failures,
          isEmpty,
          reason: 'isValid invariant violated: $failures',
        );
      },
    );

    test(
      'Property 7 holds for random SecurityState configurations '
      '($_kNumIterations iterations)',
      () {
        final rng = Random(_kRandomSeed + 4);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final pinEnabled = rng.nextBool();
          final bioEnabled = rng.nextBool();
          final lockStatus = LockScreenStatus.values[
              rng.nextInt(LockScreenStatus.values.length)];

          final state = SecurityState(
            pinEnabled: pinEnabled,
            biometricEnabled: bioEnabled,
            lockScreenStatus: lockStatus,
          );

          final expected = !bioEnabled || pinEnabled;
          final actual = state.isValid;

          if (actual != expected) {
            failures.add(
              'iteration=$i, pinEnabled=$pinEnabled, bioEnabled=$bioEnabled, '
              'lockStatus=$lockStatus, expected=$expected, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property 7 violated: ${failures.length}/$_kNumIterations. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );
  });
}
