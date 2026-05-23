import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PendingDeleteRecord {
  final String id;
  final DateTime deletedAt;

  const PendingDeleteRecord({required this.id, required this.deletedAt});

  Map<String, dynamic> toJson() => {
    'id': id,
    'deleted_at': deletedAt.toIso8601String(),
  };

  factory PendingDeleteRecord.fromJson(Map<String, dynamic> json) {
    return PendingDeleteRecord(
      id: json['id'] as String,
      deletedAt: DateTime.parse(json['deleted_at'] as String),
    );
  }
}

class SyncConflictRecord {
  final String table;
  final String recordId;
  final String reason;
  final DateTime detectedAt;
  final DateTime? localUpdatedAt;
  final DateTime? remoteUpdatedAt;

  const SyncConflictRecord({
    required this.table,
    required this.recordId,
    required this.reason,
    required this.detectedAt,
    this.localUpdatedAt,
    this.remoteUpdatedAt,
  });

  Map<String, dynamic> toJson() => {
    'table': table,
    'record_id': recordId,
    'reason': reason,
    'detected_at': detectedAt.toIso8601String(),
    'local_updated_at': localUpdatedAt?.toIso8601String(),
    'remote_updated_at': remoteUpdatedAt?.toIso8601String(),
  };

  factory SyncConflictRecord.fromJson(Map<String, dynamic> json) {
    return SyncConflictRecord(
      table: json['table'] as String,
      recordId: json['record_id'] as String,
      reason: json['reason'] as String? ?? 'remote_newer_than_local_unsynced',
      detectedAt: DateTime.parse(json['detected_at'] as String),
      localUpdatedAt: json['local_updated_at'] == null
          ? null
          : DateTime.tryParse(json['local_updated_at'] as String),
      remoteUpdatedAt: json['remote_updated_at'] == null
          ? null
          : DateTime.tryParse(json['remote_updated_at'] as String),
    );
  }
}

class LocalPreferencesService {
  static const _lastSyncAtKey = 'last_sync_at';
  static const _lastSyncErrorKey = 'last_sync_error';
  static const _readNotificationIdsKey = 'notification_read_ids';
  static const _profileNamePrefix = 'profile_name_';
  static const _profileEmailPrefix = 'profile_email_';
  static const _profileAvatarPathPrefix = 'profile_avatar_path_';
  static const _profileCloudAvatarUrlPrefix = 'profile_cloud_avatar_url_';
  static const _profileCloudNamePrefix = 'profile_cloud_name_';
  static const _profileCloudUpdatedAtPrefix = 'profile_cloud_updated_at_';
  static const _profileLocalUpdatedAtPrefix = 'profile_local_updated_at_';
  static const _remotePushTokenKey = 'remote_push_token';
  static const _remotePushErrorKey = 'remote_push_error';
  static const _syncConflictsKey = 'sync_conflicts';
  static const _themeModeKey = 'theme_mode';
  static const _pendingDeletesPrefix = 'pending_deletes_';
  static const guestProfileScope = 'guest';

  static Future<SharedPreferences> _prefs() {
    return SharedPreferences.getInstance();
  }

  static Future<DateTime?> getLastSyncAt() async {
    final prefs = await _prefs();
    final value = prefs.getString(_lastSyncAtKey);
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static Future<void> setLastSyncAt(DateTime dateTime) async {
    final prefs = await _prefs();
    await prefs.setString(_lastSyncAtKey, dateTime.toIso8601String());
  }

  static Future<String?> getLastSyncError() async {
    final prefs = await _prefs();
    final value = prefs.getString(_lastSyncErrorKey);
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static Future<void> setLastSyncError(String? message) async {
    final prefs = await _prefs();
    if (message == null || message.isEmpty) {
      await prefs.remove(_lastSyncErrorKey);
      return;
    }
    await prefs.setString(_lastSyncErrorKey, message);
  }

  static Future<List<PendingDeleteRecord>> getPendingDeletes(
    String table,
  ) async {
    final prefs = await _prefs();
    final rawList = prefs.getStringList('$_pendingDeletesPrefix$table') ?? [];
    return rawList
        .map((item) => PendingDeleteRecord.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<Set<String>> getPendingDeleteIds(String table) async {
    final records = await getPendingDeletes(table);
    return records.map((record) => record.id).toSet();
  }

  static Future<void> queuePendingDelete(
    String table,
    String id, {
    DateTime? deletedAt,
  }) async {
    final prefs = await _prefs();
    final key = '$_pendingDeletesPrefix$table';
    final existing = await getPendingDeletes(table);
    final filtered = existing.where((record) => record.id != id).toList()
      ..add(
        PendingDeleteRecord(id: id, deletedAt: deletedAt ?? DateTime.now()),
      );
    await prefs.setStringList(
      key,
      filtered.map((record) => jsonEncode(record.toJson())).toList(),
    );
  }

  static Future<void> removePendingDelete(String table, String id) async {
    final prefs = await _prefs();
    final key = '$_pendingDeletesPrefix$table';
    final existing = await getPendingDeletes(table);
    final filtered = existing.where((record) => record.id != id).toList();
    await prefs.setStringList(
      key,
      filtered.map((record) => jsonEncode(record.toJson())).toList(),
    );
  }

  static Future<Set<String>> getReadNotificationIds() async {
    final prefs = await _prefs();
    return (prefs.getStringList(_readNotificationIdsKey) ?? []).toSet();
  }

  static Future<void> markNotificationRead(String notificationId) async {
    final prefs = await _prefs();
    final current = await getReadNotificationIds()
      ..add(notificationId);
    await prefs.setStringList(_readNotificationIdsKey, current.toList());
  }

  static Future<void> saveProfile({
    required String name,
    required String email,
    String scope = guestProfileScope,
  }) async {
    final prefs = await _prefs();
    await prefs.setString('$_profileNamePrefix$scope', name);
    await prefs.setString('$_profileEmailPrefix$scope', email);
    await prefs.setString(
      '$_profileLocalUpdatedAtPrefix$scope',
      DateTime.now().toIso8601String(),
    );
  }

  static Future<void> cacheProfileFromCloud({
    required String scope,
    required String name,
    required String email,
    required DateTime updatedAt,
  }) async {
    final prefs = await _prefs();
    await prefs.setString('$_profileNamePrefix$scope', name);
    await prefs.setString('$_profileEmailPrefix$scope', email);
    await prefs.setString(
      '$_profileLocalUpdatedAtPrefix$scope',
      updatedAt.toIso8601String(),
    );
  }

  static Future<String?> getProfileName({
    String scope = guestProfileScope,
  }) async {
    final prefs = await _prefs();
    return prefs.getString('$_profileNamePrefix$scope');
  }

  static Future<String?> getProfileEmail({
    String scope = guestProfileScope,
  }) async {
    final prefs = await _prefs();
    return prefs.getString('$_profileEmailPrefix$scope');
  }

  static Future<void> setProfileAvatarPath({
    required String scope,
    String? path,
  }) async {
    final prefs = await _prefs();
    final key = '$_profileAvatarPathPrefix$scope';
    if (path == null || path.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, path);
  }

  static Future<String?> getProfileAvatarPath({required String scope}) async {
    final prefs = await _prefs();
    return prefs.getString('$_profileAvatarPathPrefix$scope');
  }

  static Future<void> setProfileCloudAvatarUrl({
    required String scope,
    String? url,
  }) async {
    final prefs = await _prefs();
    final key = '$_profileCloudAvatarUrlPrefix$scope';
    if (url == null || url.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, url);
  }

  static Future<String?> getProfileCloudAvatarUrl({
    required String scope,
  }) async {
    final prefs = await _prefs();
    return prefs.getString('$_profileCloudAvatarUrlPrefix$scope');
  }

  static Future<void> setProfileCloudName({
    required String scope,
    String? name,
  }) async {
    final prefs = await _prefs();
    final key = '$_profileCloudNamePrefix$scope';
    if (name == null || name.isEmpty) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, name);
  }

  static Future<String?> getProfileCloudName({required String scope}) async {
    final prefs = await _prefs();
    return prefs.getString('$_profileCloudNamePrefix$scope');
  }

  static Future<void> setProfileCloudUpdatedAt({
    required String scope,
    DateTime? updatedAt,
  }) async {
    final prefs = await _prefs();
    final key = '$_profileCloudUpdatedAtPrefix$scope';
    if (updatedAt == null) {
      await prefs.remove(key);
      return;
    }
    await prefs.setString(key, updatedAt.toIso8601String());
  }

  static Future<DateTime?> getProfileCloudUpdatedAt({
    required String scope,
  }) async {
    final prefs = await _prefs();
    final value = prefs.getString('$_profileCloudUpdatedAtPrefix$scope');
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static Future<DateTime?> getProfileLocalUpdatedAt({
    required String scope,
  }) async {
    final prefs = await _prefs();
    final value = prefs.getString('$_profileLocalUpdatedAtPrefix$scope');
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static Future<void> setRemotePushToken(String? token) async {
    final prefs = await _prefs();
    if (token == null || token.isEmpty) {
      await prefs.remove(_remotePushTokenKey);
      return;
    }
    await prefs.setString(_remotePushTokenKey, token);
  }

  static Future<String?> getRemotePushToken() async {
    final prefs = await _prefs();
    return prefs.getString(_remotePushTokenKey);
  }

  static Future<void> setRemotePushError(String? message) async {
    final prefs = await _prefs();
    if (message == null || message.isEmpty) {
      await prefs.remove(_remotePushErrorKey);
      return;
    }
    await prefs.setString(_remotePushErrorKey, message);
  }

  static Future<String?> getRemotePushError() async {
    final prefs = await _prefs();
    return prefs.getString(_remotePushErrorKey);
  }

  static Future<List<SyncConflictRecord>> getSyncConflicts() async {
    final prefs = await _prefs();
    final rawList = prefs.getStringList(_syncConflictsKey) ?? [];
    return rawList
        .map((item) => SyncConflictRecord.fromJson(jsonDecode(item)))
        .toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  static Future<void> addSyncConflict(SyncConflictRecord record) async {
    final prefs = await _prefs();
    final current = await getSyncConflicts();
    final filtered =
        current
            .where(
              (item) =>
                  !(item.table == record.table &&
                      item.recordId == record.recordId),
            )
            .toList()
          ..add(record);
    await prefs.setStringList(
      _syncConflictsKey,
      filtered.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  static Future<void> clearSyncConflict(String table, String recordId) async {
    final prefs = await _prefs();
    final current = await getSyncConflicts();
    final filtered = current
        .where((item) => !(item.table == table && item.recordId == recordId))
        .toList();
    await prefs.setStringList(
      _syncConflictsKey,
      filtered.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  static Future<void> clearAllSyncConflicts() async {
    final prefs = await _prefs();
    await prefs.remove(_syncConflictsKey);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs();
    final value = prefs.getString(_themeModeKey);
    return switch (value) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _prefs();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
    };
    await prefs.setString(_themeModeKey, value);
  }
}
