import 'package:market_app/features/auth/domain/entities/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.metadata,
  });

  factory AuthUserModel.fromSupabase(supabase.User user) {
    final metadata = user.userMetadata;
    final mappedMetadata = metadata is Map<String, dynamic> ? metadata : null;
    final displayName = mappedMetadata?['full_name'] as String? ??
        mappedMetadata?['name'] as String? ??
        user.userMetadata?['name'] as String?;
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: displayName,
      metadata: mappedMetadata,
    );
  }

  AuthUserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    Map<String, dynamic>? metadata,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      metadata: metadata ?? this.metadata,
    );
  }
}
