import 'package:flutter/foundation.dart';

class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const requireCloudConfig = bool.fromEnvironment(
    'REQUIRE_CLOUD_CONFIG',
    defaultValue: false,
  );
  static const redirectUrl = 'com.penacode.sisasaku://login-callback';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static bool get shouldFailFast => requireCloudConfig || kReleaseMode;

  static void validateOrThrow() {
    if (isConfigured) return;
    if (!shouldFailFast) return;

    throw StateError(
      'Supabase belum dikonfigurasi. Jalankan app dengan '
      '--dart-define=SUPABASE_URL=... '
      '--dart-define=SUPABASE_ANON_KEY=... '
      'atau nonaktifkan mode strict dengan '
      '--dart-define=REQUIRE_CLOUD_CONFIG=false untuk debug lokal.',
    );
  }
}
