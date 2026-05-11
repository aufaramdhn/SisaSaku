class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const redirectUrl = 'com.penacode.sisasaku://login-callback';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
