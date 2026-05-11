import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/providers/supabase_provider.dart';
import 'package:sisasaku/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:sisasaku/features/auth/domain/entities/auth_user.dart';
import 'package:sisasaku/features/auth/domain/repositories/auth_repository.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;

  const AuthState._(this.status, this.user);

  const AuthState.unauthenticated() : this._(AuthStatus.unauthenticated, null);

  const AuthState.authenticated(AuthUser user)
      : this._(AuthStatus.authenticated, user);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(client);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

final isGuestProvider = Provider<bool>((ref) {
  final state = ref.watch(authStateProvider);
  return state.status == AuthStatus.unauthenticated;
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<AuthUser?>? _subscription;

  AuthNotifier(this._repo) : super(const AuthState.unauthenticated()) {
    _bootstrap();
  }

  void _bootstrap() {
    final current = _repo.currentUser;
    if (current != null) {
      state = AuthState.authenticated(current);
    }

    _subscription = _repo.onAuthStateChange.listen((user) {
      state = user == null
          ? const AuthState.unauthenticated()
          : AuthState.authenticated(user);
    });
  }

  Future<void> signInWithGoogle() async {
    await _repo.signInWithGoogle();
  }

  Future<void> signOut() async {
    await _repo.signOut();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
