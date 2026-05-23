import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const storageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const requireFirebaseConfig = bool.fromEnvironment(
    'REQUIRE_FIREBASE_CONFIG',
    defaultValue: false,
  );

  static bool get isConfigured =>
      apiKey.isNotEmpty && appId.isNotEmpty && projectId.isNotEmpty;

  static bool get shouldFailFast => requireFirebaseConfig || kReleaseMode;

  static void validateOrThrow() {
    if (isConfigured) return;
    if (!shouldFailFast) return;

    throw StateError(
      'Firebase belum dikonfigurasi. Jalankan app dengan '
      '--dart-define=FIREBASE_API_KEY=... '
      '--dart-define=FIREBASE_APP_ID=... '
      '--dart-define=FIREBASE_PROJECT_ID=... '
      'atau nonaktifkan mode strict dengan '
      '--dart-define=REQUIRE_FIREBASE_CONFIG=false untuk debug lokal.',
    );
  }
}
