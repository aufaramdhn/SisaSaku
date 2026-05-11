import 'package:sisasaku/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;
  Stream<AuthUser?> get onAuthStateChange;
  Future<void> signInWithGoogle();
  Future<void> signOut();
}
