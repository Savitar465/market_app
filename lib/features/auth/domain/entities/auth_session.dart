import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.fromCache = false,
  });

  final AuthUser user;
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final bool fromCache;
}
