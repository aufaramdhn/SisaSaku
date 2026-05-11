class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    this.email,
    this.name,
    this.avatarUrl,
  });
}
