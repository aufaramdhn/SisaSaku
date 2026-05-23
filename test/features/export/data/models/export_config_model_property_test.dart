import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sisasaku/features/export/data/models/export_config_model.dart';

/// Property-based test for ExportConfigModel JSON serialization round-trip.
///
/// **Property 5: Export entity serialization round-trip**
///
/// For any valid ExportConfigModel, calling toJson() and then fromJson() on
/// the result should produce a model with identical field values.
///
/// **Validates: Requirements 4.7**
void main() {
  // Fixed seed for reproducibility - any failing example can be reproduced.
  const seed = 0xE7C0;
  // Number of random instances to test (within 100-500 range from task spec).
  const iterations = 300;

  /// Smart generator: produces an arbitrary valid ExportConfigModel.
  ///
  /// Constrained to the input space described by the model contract:
  ///   - id: non-empty string (UUID-like)
  ///   - format: 'pdf' or 'csv' (the only valid values per design.md)
  ///   - startDate / endDate: arbitrary local DateTimes within a wide,
  ///     realistic range (1970..2100); millisecond precision because
  ///     ISO-8601 round-trips at millisecond resolution reliably across
  ///     platforms (web limits DateTime to ms precision).
  ///   - filePath: null ~50% of the time, otherwise a non-empty string
  ///     possibly containing path separators and unicode characters.
  ///   - createdAt: arbitrary local DateTime, same range as above.
  ExportConfigModel generateModel(Random rng, int index) {
    // id - varied length alphanumeric strings, mimicking UUIDs in shape.
    final id = _randomString(rng, minLen: 8, maxLen: 40);

    // format - exactly one of the two valid values, roughly 50/50.
    final format = rng.nextBool() ? 'pdf' : 'csv';

    // Dates - millisecond precision, year range 1970..2100.
    final startDate = _randomDateTime(rng);
    // endDate independent of startDate (the model does not enforce ordering;
    // it is just metadata stored verbatim, so we test the full input space).
    final endDate = _randomDateTime(rng);
    final createdAt = _randomDateTime(rng);

    // filePath - null about half the time, otherwise a varied string.
    final String? filePath = rng.nextBool()
        ? null
        : _randomString(rng, minLen: 1, maxLen: 80, includePathChars: true);

    return ExportConfigModel(
      id: id,
      format: format,
      startDate: startDate,
      endDate: endDate,
      filePath: filePath,
      createdAt: createdAt,
    );
  }

  test(
    'toJson/fromJson round-trip preserves all fields for arbitrary ExportConfigModel',
    () {
      final rng = Random(seed);

      for (var i = 0; i < iterations; i++) {
        final original = generateModel(rng, i);

        // Round-trip: serialize then deserialize.
        final json = original.toJson();
        final restored = ExportConfigModel.fromJson(json);

        // Build a descriptive reason so any failing example is easy to read.
        final reason =
            'Round-trip mismatch on iteration $i (seed=$seed). '
            'Original: id=${original.id}, format=${original.format}, '
            'startDate=${original.startDate.toIso8601String()}, '
            'endDate=${original.endDate.toIso8601String()}, '
            'filePath=${original.filePath}, '
            'createdAt=${original.createdAt.toIso8601String()}';

        expect(restored.id, original.id, reason: reason);
        expect(restored.format, original.format, reason: reason);
        expect(restored.startDate, original.startDate, reason: reason);
        expect(restored.endDate, original.endDate, reason: reason);
        expect(restored.filePath, original.filePath, reason: reason);
        expect(restored.createdAt, original.createdAt, reason: reason);
      }
    },
  );
}

/// Generates a random non-empty string of length [minLen]..[maxLen].
///
/// When [includePathChars] is true, the alphabet also contains characters that
/// commonly appear in file paths (slashes, dots, dashes, spaces, unicode) so
/// the generator covers realistic filePath inputs.
String _randomString(
  Random rng, {
  required int minLen,
  required int maxLen,
  bool includePathChars = false,
}) {
  const base =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  // Path-friendly extras: separators, dots, dashes, underscores, spaces, and
  // a couple of unicode codepoints to ensure non-ASCII content survives JSON.
  const extras = '/\\._- éñ漢';

  final alphabet = includePathChars ? base + extras : base;
  final len = minLen + rng.nextInt(maxLen - minLen + 1);
  final buf = StringBuffer();
  for (var i = 0; i < len; i++) {
    buf.write(alphabet[rng.nextInt(alphabet.length)]);
  }
  return buf.toString();
}

/// Generates a random local DateTime in the year range 1970..2100,
/// at millisecond precision (the precision preserved by ISO-8601
/// serialization across all Dart platforms).
DateTime _randomDateTime(Random rng) {
  // 1970-01-01 00:00:00 .. 2100-01-01 00:00:00 UTC, in milliseconds.
  const minMs = 0; // 1970-01-01T00:00:00Z
  const maxMs = 4102444800000; // 2100-01-01T00:00:00Z

  // Random.nextInt accepts up to 2^32-1; pick the high and low parts
  // separately so the full 64-bit range we need is covered.
  final span = maxMs - minMs;
  final highChunk = 1 << 30; // 2^30 - safely within nextInt bounds
  final high = rng.nextInt(highChunk);
  final low = rng.nextInt(highChunk);
  final raw = (high * highChunk + low) % span;
  final ms = minMs + raw;

  // Local DateTime so the ISO-8601 string produced by toIso8601String() does
  // not carry a 'Z' suffix; DateTime.parse() then returns a local DateTime
  // and equality (which checks isUtc) holds.
  return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: false);
}
