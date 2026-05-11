import 'package:supabase_flutter/supabase_flutter.dart'
    show SupabaseClient, OAuthProvider, User;
import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;
import 'package:sisasaku/core/constants/supabase_config.dart';
import 'package:sisasaku/features/auth/domain/entities/auth_user.dart' as app;
import 'package:sisasaku/features/auth/domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient? _client;

  SupabaseAuthRepository(this._client);

  bool get isAvailable => _client != null;

  app.AuthUser? _mapUser(User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata ?? {};
    final name = metadata['full_name'] ?? metadata['name'] ?? user.email;
    final avatarUrl = metadata['avatar_url'] ?? metadata['picture'];

    return app.AuthUser(
      id: user.id,
      email: user.email,
      name: name is String ? name : user.email,
      avatarUrl: avatarUrl is String ? avatarUrl : null,
    );
  }

  @override
  app.AuthUser? get currentUser => _mapUser(_client?.auth.currentUser);

  @override
  Stream<app.AuthUser?> get onAuthStateChange {
    final client = _client;
    if (client == null) return const Stream<app.AuthUser?>.empty();
    return client.auth.onAuthStateChange.map(
      (event) => _mapUser(event.session?.user),
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase belum dikonfigurasi');
    }
    final response = await client.auth.getOAuthSignInUrl(
      provider: OAuthProvider.google,
      redirectTo: SupabaseConfig.redirectUrl,
    );
    await launchUrl(
      Uri.parse(response.url),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }
}
