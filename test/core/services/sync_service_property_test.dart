import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'sync_service_test.dart' show hasRemotePriority;

/// Property-Based Tests for the sync conflict resolution logic in SyncService.
///
/// These tests validate the universal correctness property:
///
///   For any pair of timestamps (localUpdatedAt, remoteUpdatedAt):
///     hasRemotePriority(localUpdatedAt, remoteRow) == true
///       <==> remoteUpdatedAt != null
///         && remoteUpdatedAt.isAfter(localUpdatedAt ?? epoch)
///
///   When remoteUpdatedAt is null, OR equal to, OR before localUpdatedAt,
///   local should retain priority (i.e., hasRemotePriority returns false).
///
/// Approach: We use `dart:math.Random` with a fixed seed for reproducibility,
/// generating arbitrary timestamp pairs across a wide range and asserting the
/// property holds for every pair. This is a manual property-based test in the
/// spirit of QuickCheck/Hypothesis, using deterministic randomization so any
/// failing case can be reproduced from the seed and iteration count.
///
/// Validates: Requirements 5.3

/// Number of random timestamp pairs to generate per property test.
/// 1000 iterations provides strong coverage while keeping test runtime fast.
const int _kNumIterations = 1000;

/// Fixed seed for reproducibility. Any failing case can be reproduced by
/// re-running with the same seed.
const int _kRandomSeed = 0xC0FFEE;

/// Maximum value accepted by [Random.nextInt] is 2^32. We use a 32-bit second
/// range (~136 years) so any single nextInt call stays well within bounds.
const int _kMaxSecondsRange = 1 << 31; // ~68 years in seconds

/// Earliest timestamp the generator will produce: 1970-01-02 (just after
/// epoch — keeps a non-zero gap so tests with null local (treated as epoch)
/// always see a remote that is strictly after the epoch).
final DateTime _kMinTimestamp = DateTime.utc(1970, 1, 2);

/// Generates a uniformly distributed random DateTime in the range
/// [1970-01-02, 1970-01-02 + 2^31 seconds] (~2038-01-19).
///
/// This range is more than wide enough to cover realistic sync scenarios
/// while staying within [Random.nextInt]'s 32-bit bound.
DateTime _arbitraryDateTime(Random rng) {
  final offsetSeconds = rng.nextInt(_kMaxSecondsRange);
  final offsetMillis = rng.nextInt(1000); // sub-second precision
  return _kMinTimestamp.add(
    Duration(seconds: offsetSeconds, milliseconds: offsetMillis),
  );
}

/// Builds a remoteRow map exactly the way SyncService receives it from
/// Supabase: `{'id': ..., 'updated_at': <ISO 8601 string>}`.
Map<String, dynamic> _buildRemoteRow(DateTime updatedAt) {
  return <String, dynamic>{
    'id': 'test-id',
    'updated_at': updatedAt.toIso8601String(),
  };
}

/// The reference (oracle) implementation of the property: remote has priority
/// iff remoteUpdatedAt is strictly after localUpdatedAt (with null local
/// treated as the epoch and null remote always yielding false).
bool _expectedRemotePriority(
  DateTime? localUpdatedAt,
  DateTime? remoteUpdatedAt,
) {
  if (remoteUpdatedAt == null) return false;
  final local =
      localUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  return remoteUpdatedAt.isAfter(local);
}

void main() {
  group('SyncService - Property: remote priority correctness', () {
    test(
      'Property 3: hasRemotePriority is true iff remoteUpdatedAt > localUpdatedAt '
      '(non-null timestamps, $_kNumIterations random pairs)',
      () {
        final rng = Random(_kRandomSeed);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final localTs = _arbitraryDateTime(rng);
          final remoteTs = _arbitraryDateTime(rng);
          final remoteRow = _buildRemoteRow(remoteTs);

          final actual = hasRemotePriority(localTs, remoteRow);
          final expected = _expectedRemotePriority(localTs, remoteTs);

          if (actual != expected) {
            failures.add(
              'iteration=$i, localTs=$localTs, remoteTs=$remoteTs, '
              'expected=$expected, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Property violated for ${failures.length}/$_kNumIterations cases. '
              'First failure: ${failures.isEmpty ? "none" : failures.first}',
        );
      },
    );

    test(
      'Property 3 (edge case): null remote always yields local priority '
      '($_kNumIterations random local timestamps)',
      () {
        final rng = Random(_kRandomSeed + 1);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final localTs = _arbitraryDateTime(rng);
          final actual = hasRemotePriority(localTs, null);
          if (actual != false) {
            failures.add(
              'iteration=$i, localTs=$localTs, expected=false, actual=$actual',
            );
          }
        }

        expect(failures, isEmpty,
            reason:
                'Null remote must always yield false. Failures: $failures');
      },
    );

    test(
      'Property 3 (edge case): remoteRow with null updated_at always yields '
      'local priority ($_kNumIterations random local timestamps)',
      () {
        final rng = Random(_kRandomSeed + 2);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final localTs = _arbitraryDateTime(rng);
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': null,
          };
          final actual = hasRemotePriority(localTs, remoteRow);
          if (actual != false) {
            failures.add(
              'iteration=$i, localTs=$localTs, expected=false, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Null remote updated_at must always yield false. Failures: $failures',
        );
      },
    );

    test(
      'Property 3 (edge case): null local with non-null remote always yields '
      'remote priority ($_kNumIterations random remote timestamps)',
      () {
        // When localUpdatedAt is null, it's treated as epoch (1970-01-01).
        // Our generator produces timestamps from 1970-01-02 onward, so every
        // remote timestamp is strictly after the epoch.
        final rng = Random(_kRandomSeed + 3);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final remoteTs = _arbitraryDateTime(rng);
          final remoteRow = _buildRemoteRow(remoteTs);
          final actual = hasRemotePriority(null, remoteRow);
          if (actual != true) {
            failures.add(
              'iteration=$i, remoteTs=$remoteTs, expected=true, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Null local with post-epoch remote must always yield true. '
              'Failures: $failures',
        );
      },
    );

    test(
      'Property 3 (edge case): equal timestamps always yield local priority '
      '($_kNumIterations random timestamps)',
      () {
        final rng = Random(_kRandomSeed + 4);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          final ts = _arbitraryDateTime(rng);
          final remoteRow = _buildRemoteRow(ts);
          final actual = hasRemotePriority(ts, remoteRow);
          if (actual != false) {
            failures.add(
              'iteration=$i, ts=$ts, expected=false, actual=$actual',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason: 'Equal timestamps must yield false (local retains priority). '
              'Failures: $failures',
        );
      },
    );

    test(
      'Property 3 (symmetry): swapping local/remote inverts priority for '
      'distinct timestamps ($_kNumIterations random pairs)',
      () {
        final rng = Random(_kRandomSeed + 5);
        final failures = <String>[];

        for (var i = 0; i < _kNumIterations; i++) {
          var ts1 = _arbitraryDateTime(rng);
          var ts2 = _arbitraryDateTime(rng);
          // Skip equal timestamps; symmetry only applies to distinct ones.
          if (ts1.isAtSameMomentAs(ts2)) {
            continue;
          }

          final priorityAB = hasRemotePriority(ts1, _buildRemoteRow(ts2));
          final priorityBA = hasRemotePriority(ts2, _buildRemoteRow(ts1));

          // For distinct timestamps, exactly one direction must report remote
          // priority.
          if (priorityAB == priorityBA) {
            failures.add(
              'iteration=$i, ts1=$ts1, ts2=$ts2, '
              'priority(ts1,ts2)=$priorityAB, priority(ts2,ts1)=$priorityBA',
            );
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Distinct timestamps must produce inverted priorities when swapped. '
              'Failures: $failures',
        );
      },
    );
  });
}
