import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/services/local_preferences_service.dart';
import 'package:sisasaku/features/auth/presentation/providers/auth_providers.dart';

final profileRefreshProvider = StateProvider<int>((ref) => 0);

final profileViewProvider = FutureProvider<ProfileViewData>((ref) async {
  ref.watch(profileRefreshProvider);
  final authState = ref.watch(authStateProvider);
  final isGuest = authState.status == AuthStatus.unauthenticated;
  final user = authState.user;
  final scope = isGuest
      ? LocalPreferencesService.guestProfileScope
      : (user?.id ?? LocalPreferencesService.guestProfileScope);

  final localName = await LocalPreferencesService.getProfileName(scope: scope);
  final localEmail = await LocalPreferencesService.getProfileEmail(
    scope: scope,
  );
  final cloudName = await LocalPreferencesService.getProfileCloudName(
    scope: scope,
  );
  final localAvatarPath = isGuest
      ? null
      : await LocalPreferencesService.getProfileAvatarPath(scope: scope);
  final cloudAvatarUrl = isGuest
      ? null
      : await LocalPreferencesService.getProfileCloudAvatarUrl(scope: scope);

  final avatarPath = await _resolveExistingPath(localAvatarPath);
  final displayName = _selectDisplayName(
    localName: localName,
    cloudName: cloudName,
    authName: user?.name,
    authEmail: user?.email,
  );
  final email = isGuest
      ? _normalizedValue(localEmail)
      : _normalizedValue(user?.email) ?? _normalizedValue(localEmail);

  return ProfileViewData(
    scope: scope,
    isGuest: isGuest,
    displayName: displayName,
    email: email,
    avatarPath: avatarPath,
    avatarUrl: isGuest
        ? null
        : _normalizedValue(cloudAvatarUrl) ?? _normalizedValue(user?.avatarUrl),
  );
});

class ProfileViewData {
  final String scope;
  final bool isGuest;
  final String displayName;
  final String? email;
  final String? avatarPath;
  final String? avatarUrl;

  const ProfileViewData({
    required this.scope,
    required this.isGuest,
    required this.displayName,
    required this.email,
    required this.avatarPath,
    required this.avatarUrl,
  });

  bool get canChangePhoto => !isGuest;

  String get profileTitle => isGuest ? 'Profil Lokal' : 'Edit Profil';

  String get statusLabel => isGuest ? 'Mode Tamu' : 'Tersinkron';

  String get actionLabel => isGuest ? 'Edit Profil Lokal' : 'Edit Profil';

  String get backupLabel =>
      isGuest ? 'Login & Backup Cloud' : 'Kelola Backup Cloud';

  String get infoMessage => isGuest
      ? 'Profil ini hanya tersimpan di perangkat ini. Login jika nanti ingin memakai sinkronisasi akun dan foto profil.'
      : 'Nama tampilan dan foto profil akan dicoba disinkronkan ke cloud saat akun aktif. Jika koneksi belum siap, perubahan lokal tetap disimpan lebih dulu di perangkat ini.';

  String get initials {
    final cleaned = displayName.trim();
    if (cleaned.isNotEmpty) {
      final parts = cleaned
          .split(' ')
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return cleaned.substring(0, 1).toUpperCase();
    }
    final fallback = _normalizedValue(email);
    if (fallback != null && fallback.isNotEmpty) {
      return fallback.substring(0, 1).toUpperCase();
    }
    return 'SS';
  }
}

String? _normalizedValue(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

Future<String?> _resolveExistingPath(String? value) async {
  final path = _normalizedValue(value);
  if (path == null) return null;
  return await File(path).exists() ? path : null;
}

String _selectDisplayName({
  required String? localName,
  required String? cloudName,
  required String? authName,
  required String? authEmail,
}) {
  return _normalizedValue(localName) ??
      _normalizedValue(cloudName) ??
      _normalizedValue(authName) ??
      _normalizedValue(authEmail) ??
      'Pengguna';
}
