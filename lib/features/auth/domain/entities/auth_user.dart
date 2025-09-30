class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.metadata,
  });

  final String id;
  final String email;
  final String? displayName;
  final Map<String, dynamic>? metadata;
}
