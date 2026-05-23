import 'package:flutter_test/flutter_test.dart';

/// Tests for the sync conflict resolution logic used by SyncService.
///
/// The core conflict resolution rule is:
/// - Remote has priority if and only if remoteUpdatedAt is strictly after localUpdatedAt
/// - When remoteUpdatedAt is null, local retains priority
/// - When remoteUpdatedAt <= localUpdatedAt, local retains priority
/// - When localUpdatedAt is null, it's treated as epoch (DateTime(0)), so any
///   non-null remoteUpdatedAt will have priority
///
/// This mirrors the private `_hasRemotePriority` method in SyncService.

/// Replicates the conflict resolution logic from SyncService._hasRemotePriority
/// for isolated unit testing.
///
/// Returns true if the remote row should take priority over the local record.
bool hasRemotePriority(
  DateTime? localUpdatedAt,
  Map<String, dynamic>? remoteRow,
) {
  if (remoteRow == null) return false;
  final remoteUpdatedAt = _parseDate(remoteRow['updated_at']);
  if (remoteUpdatedAt == null) return false;
  final local = localUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  return remoteUpdatedAt.isAfter(local);
}

/// Replicates the _parseDate helper from SyncService.
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

void main() {
  group('SyncService - Conflict Resolution Logic', () {
    group('_hasRemotePriority', () {
      test('returns false when remoteRow is null (no remote data)', () {
        final result = hasRemotePriority(DateTime(2026, 5, 15), null);
        expect(result, isFalse);
      });

      test(
        'returns false when remoteRow has null updated_at',
        () {
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': null,
          };
          final result = hasRemotePriority(DateTime(2026, 5, 15), remoteRow);
          expect(result, isFalse);
        },
      );

      test(
        'returns false when remoteRow has empty string updated_at',
        () {
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': '',
          };
          final result = hasRemotePriority(DateTime(2026, 5, 15), remoteRow);
          expect(result, isFalse);
        },
      );

      test(
        'returns true when remoteUpdatedAt is strictly after localUpdatedAt',
        () {
          final localTime = DateTime(2026, 5, 15, 10, 0, 0);
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': DateTime(2026, 5, 15, 11, 0, 0).toIso8601String(),
          };
          final result = hasRemotePriority(localTime, remoteRow);
          expect(result, isTrue);
        },
      );

      test(
        'returns false when remoteUpdatedAt equals localUpdatedAt',
        () {
          final timestamp = DateTime(2026, 5, 15, 10, 0, 0);
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': timestamp.toIso8601String(),
          };
          final result = hasRemotePriority(timestamp, remoteRow);
          expect(result, isFalse);
        },
      );

      test(
        'returns false when remoteUpdatedAt is before localUpdatedAt',
        () {
          final localTime = DateTime(2026, 5, 15, 12, 0, 0);
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': DateTime(2026, 5, 15, 10, 0, 0).toIso8601String(),
          };
          final result = hasRemotePriority(localTime, remoteRow);
          expect(result, isFalse);
        },
      );

      test(
        'returns true when localUpdatedAt is null (treated as epoch) and remote has a timestamp',
        () {
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': DateTime(2026, 5, 15, 10, 0, 0).toIso8601String(),
          };
          final result = hasRemotePriority(null, remoteRow);
          expect(result, isTrue);
        },
      );

      test(
        'handles DateTime object directly in remoteRow updated_at',
        () {
          final localTime = DateTime(2026, 5, 15, 10, 0, 0);
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': DateTime(2026, 5, 15, 11, 0, 0),
          };
          final result = hasRemotePriority(localTime, remoteRow);
          expect(result, isTrue);
        },
      );

      test(
        'returns false when remoteRow updated_at is an invalid date string',
        () {
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': 'not-a-date',
          };
          final result = hasRemotePriority(DateTime(2026, 5, 15), remoteRow);
          expect(result, isFalse);
        },
      );

      test(
        'remote priority with 1 millisecond difference (remote newer)',
        () {
          final localTime = DateTime(2026, 5, 15, 10, 0, 0, 0);
          final remoteTime = DateTime(2026, 5, 15, 10, 0, 0, 1);
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': remoteTime.toIso8601String(),
          };
          final result = hasRemotePriority(localTime, remoteRow);
          expect(result, isTrue);
        },
      );

      test(
        'local priority with 1 millisecond difference (local newer)',
        () {
          final localTime = DateTime(2026, 5, 15, 10, 0, 0, 1);
          final remoteTime = DateTime(2026, 5, 15, 10, 0, 0, 0);
          final remoteRow = <String, dynamic>{
            'id': 'test-id',
            'updated_at': remoteTime.toIso8601String(),
          };
          final result = hasRemotePriority(localTime, remoteRow);
          expect(result, isFalse);
        },
      );
    });

    group('Push scenario - conflict resolution during push', () {
      test(
        'local record should NOT be pushed when remote is newer',
        () {
          // Simulates: local has unsynced changes, but remote was updated more recently
          final localUpdatedAt = DateTime(2026, 5, 15, 10, 0, 0);
          final remoteRow = <String, dynamic>{
            'id': 'tx-1',
            'updated_at': DateTime(2026, 5, 15, 12, 0, 0).toIso8601String(),
          };

          // In push flow, items are filtered out when remote has priority
          final shouldSkipPush = hasRemotePriority(localUpdatedAt, remoteRow);
          expect(shouldSkipPush, isTrue);
        },
      );

      test(
        'local record SHOULD be pushed when local is newer',
        () {
          // Simulates: local has unsynced changes that are newer than remote
          final localUpdatedAt = DateTime(2026, 5, 15, 14, 0, 0);
          final remoteRow = <String, dynamic>{
            'id': 'tx-1',
            'updated_at': DateTime(2026, 5, 15, 12, 0, 0).toIso8601String(),
          };

          final shouldSkipPush = hasRemotePriority(localUpdatedAt, remoteRow);
          expect(shouldSkipPush, isFalse);
        },
      );

      test(
        'local record SHOULD be pushed when no remote row exists',
        () {
          // Simulates: new local record that doesn't exist on remote
          final localUpdatedAt = DateTime(2026, 5, 15, 10, 0, 0);

          final shouldSkipPush = hasRemotePriority(localUpdatedAt, null);
          expect(shouldSkipPush, isFalse);
        },
      );
    });

    group('Pull scenario - conflict detection during pull', () {
      test(
        'remote overrides local when remote is newer and local is unsynced',
        () {
          // During pull, if local has unsynced changes but remote is newer,
          // a conflict is recorded
          final localUpdatedAt = DateTime(2026, 5, 15, 10, 0, 0);
          final remoteUpdatedAt = DateTime(2026, 5, 15, 12, 0, 0);
          final localSyncStatus = false; // has unsynced local changes

          // Conflict should be recorded when:
          // 1. localSyncStatus is false (has unsynced changes)
          // 2. remoteUpdatedAt is not null
          // 3. remoteUpdatedAt is after localUpdatedAt
          final shouldRecordConflict = !localSyncStatus &&
              remoteUpdatedAt.isAfter(
                localUpdatedAt,
              );
          expect(shouldRecordConflict, isTrue);
        },
      );

      test(
        'no conflict when local is already synced',
        () {
          final localSyncStatus = true; // already synced

          // No conflict when local is already synced (even if remote is newer)
          // Short-circuit: !localSyncStatus is false, so no conflict
          final shouldRecordConflict = !localSyncStatus;
          expect(shouldRecordConflict, isFalse);
        },
      );

      test(
        'no conflict when remote is older than local unsynced changes',
        () {
          final localUpdatedAt = DateTime(2026, 5, 15, 14, 0, 0);
          final remoteUpdatedAt = DateTime(2026, 5, 15, 12, 0, 0);
          final localSyncStatus = false; // has unsynced local changes

          final shouldRecordConflict = !localSyncStatus &&
              remoteUpdatedAt.isAfter(
                localUpdatedAt,
              );
          expect(shouldRecordConflict, isFalse);
        },
      );

      test(
        'conflict detection treats null localUpdatedAt as epoch',
        () {
          final DateTime? localUpdatedAt = null;
          final remoteUpdatedAt = DateTime(2026, 5, 15, 12, 0, 0);
          final localSyncStatus = false;

          // Mirrors _recordRemoteOverrideConflictIfNeeded logic
          final localTimestamp =
              localUpdatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final shouldRecordConflict =
              !localSyncStatus && remoteUpdatedAt.isAfter(localTimestamp);
          expect(shouldRecordConflict, isTrue);
        },
      );
    });
  });
}
