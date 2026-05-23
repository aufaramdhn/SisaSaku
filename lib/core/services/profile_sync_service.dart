import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'local_preferences_service.dart';

class ProfileSyncSnapshot {
  final String? displayName;
  final String? avatarUrl;
  final DateTime? updatedAt;

  const ProfileSyncSnapshot({
    required this.displayName,
    required this.avatarUrl,
    required this.updatedAt,
  });
}

class ProfileSyncService {
  static const profileTable = 'profiles';
  static const avatarBucket = 'profile-avatars';

  final SupabaseClient? _client;

  const ProfileSyncService({required SupabaseClient? client})
    : _client = client;

  bool get isAvailable => _client != null;

  Future<ProfileSyncSnapshot?> fetchProfile(String scope) async {
    final client = _client;
    if (client == null || scope == LocalPreferencesService.guestProfileScope) {
      return null;
    }

    final row = await client
        .from(profileTable)
        .select()
        .eq('user_id', scope)
        .maybeSingle();
    if (row == null) return null;

    return ProfileSyncSnapshot(
      displayName: row['display_name'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      updatedAt: _parseDate(row['updated_at']),
    );
  }

  Future<void> pullProfileToLocal(String scope) async {
    final snapshot = await fetchProfile(scope);
    if (snapshot == null) return;

    final currentEmail =
        _client?.auth.currentUser?.email ??
        await LocalPreferencesService.getProfileEmail(scope: scope) ??
        '';

    if ((snapshot.displayName ?? '').trim().isNotEmpty) {
      await LocalPreferencesService.cacheProfileFromCloud(
        scope: scope,
        name: snapshot.displayName!,
        email: currentEmail,
        updatedAt: snapshot.updatedAt ?? DateTime.now(),
      );
      await LocalPreferencesService.setProfileCloudName(
        scope: scope,
        name: snapshot.displayName,
      );
    }
    await LocalPreferencesService.setProfileCloudAvatarUrl(
      scope: scope,
      url: snapshot.avatarUrl,
    );
    await LocalPreferencesService.setProfileCloudUpdatedAt(
      scope: scope,
      updatedAt: snapshot.updatedAt,
    );
  }

  Future<void> syncProfileForCurrentUser(String scope) async {
    final client = _client;
    if (client == null || scope == LocalPreferencesService.guestProfileScope) {
      return;
    }

    final remote = await fetchProfile(scope);
    if (remote != null) {
      await LocalPreferencesService.setProfileCloudName(
        scope: scope,
        name: remote.displayName,
      );
      await LocalPreferencesService.setProfileCloudAvatarUrl(
        scope: scope,
        url: remote.avatarUrl,
      );
      await LocalPreferencesService.setProfileCloudUpdatedAt(
        scope: scope,
        updatedAt: remote.updatedAt,
      );
    }

    final localUpdatedAt =
        await LocalPreferencesService.getProfileLocalUpdatedAt(scope: scope);
    final cloudUpdatedAt =
        remote?.updatedAt ??
        await LocalPreferencesService.getProfileCloudUpdatedAt(scope: scope);
    final localName = await LocalPreferencesService.getProfileName(
      scope: scope,
    );
    final localEmail = await LocalPreferencesService.getProfileEmail(
      scope: scope,
    );
    final avatarPath = await LocalPreferencesService.getProfileAvatarPath(
      scope: scope,
    );
    final hasLocalProfile =
        (localName?.trim().isNotEmpty ?? false) ||
        (avatarPath?.trim().isNotEmpty ?? false);

    if (hasLocalProfile &&
        localUpdatedAt != null &&
        (cloudUpdatedAt == null || localUpdatedAt.isAfter(cloudUpdatedAt))) {
      await syncLocalProfileToCloud(
        scope: scope,
        displayName: localName?.trim().isNotEmpty == true
            ? localName!.trim()
            : (client.auth.currentUser?.email ?? 'Pengguna'),
        email: client.auth.currentUser?.email ?? localEmail ?? '',
        avatarPath: avatarPath,
      );
      return;
    }

    if (remote != null) {
      await pullProfileToLocal(scope);
    }
  }

  Future<void> syncLocalProfileToCloud({
    required String scope,
    required String displayName,
    required String email,
    String? avatarPath,
  }) async {
    final client = _client;
    if (client == null || scope == LocalPreferencesService.guestProfileScope) {
      return;
    }

    String? avatarUrl = await LocalPreferencesService.getProfileCloudAvatarUrl(
      scope: scope,
    );
    if (avatarPath != null &&
        avatarPath.isNotEmpty &&
        await File(avatarPath).exists()) {
      avatarUrl = await _uploadAvatar(scope, avatarPath);
      await LocalPreferencesService.setProfileCloudAvatarUrl(
        scope: scope,
        url: avatarUrl,
      );
    }

    final now = DateTime.now();
    await client.from(profileTable).upsert({
      'user_id': scope,
      'display_name': displayName,
      'email': email,
      'avatar_url': avatarUrl,
      'updated_at': now.toIso8601String(),
    }, onConflict: 'user_id');

    try {
      await client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': displayName,
            'name': displayName,
            'avatar_url': avatarUrl,
          },
        ),
      );
    } catch (_) {
      // Best effort only; profile table remains source of truth.
    }

    await LocalPreferencesService.setProfileCloudName(
      scope: scope,
      name: displayName,
    );
    await LocalPreferencesService.setProfileCloudUpdatedAt(
      scope: scope,
      updatedAt: now,
    );
  }

  Future<String> _uploadAvatar(String scope, String avatarPath) async {
    final client = _client!;
    final file = File(avatarPath);
    final ext = _fileExtension(avatarPath);
    final objectPath = '$scope/avatar$ext';

    await client.storage
        .from(avatarBucket)
        .upload(objectPath, file, fileOptions: const FileOptions(upsert: true));

    return client.storage.from(avatarBucket).getPublicUrl(objectPath);
  }

  DateTime? _parseDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '.jpg';
    }
    return path.substring(dotIndex).toLowerCase();
  }
}
