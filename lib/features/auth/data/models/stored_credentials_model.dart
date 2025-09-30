import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:market_app/core/database/app_database.dart';
import 'package:market_app/core/security/credential_cipher.dart';
import 'package:market_app/features/auth/data/models/auth_session_model.dart';
import 'package:market_app/features/auth/data/models/auth_user_model.dart';

class StoredCredentialsModel {
  const StoredCredentialsModel({
    required this.userId,
    required this.email,
    required this.hashedPassword,
    required this.passwordSalt,
    required this.encryptedAccessToken,
    required this.updatedAt,
    this.displayName,
    this.encryptedRefreshToken,
    this.expiresAt,
    this.metadata,
  });

  final String userId;
  final String email;
  final String? displayName;
  final String hashedPassword;
  final String passwordSalt;
  final String encryptedAccessToken;
  final String? encryptedRefreshToken;
  final int? expiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime updatedAt;

  factory StoredCredentialsModel.fromTable(AuthCredentialsTableData data) {
    return StoredCredentialsModel(
      userId: data.userId,
      email: data.email,
      displayName: data.displayName,
      hashedPassword: data.hashedPassword,
      passwordSalt: data.passwordSalt,
      encryptedAccessToken: data.encryptedAccessToken,
      encryptedRefreshToken: data.encryptedRefreshToken,
      expiresAt: data.expiresAt,
      metadata: data.jsonUserMetadata != null
          ? jsonDecode(data.jsonUserMetadata!) as Map<String, dynamic>
          : null,
      updatedAt: data.updatedAt,
    );
  }

  AuthCredentialsTableCompanion toCompanion({
    required String hashedPassword,
    required String passwordSalt,
    required String encryptedAccessToken,
    String? encryptedRefreshToken,
    int? expiresAt,
    DateTime? updatedAt,
  }) {
    return AuthCredentialsTableCompanion(
      userId: Value(userId),
      email: Value(email),
      displayName: Value(displayName),
      hashedPassword: Value(hashedPassword),
      passwordSalt: Value(passwordSalt),
      encryptedAccessToken: Value(encryptedAccessToken),
      encryptedRefreshToken: Value(encryptedRefreshToken),
      expiresAt: Value(expiresAt),
      jsonUserMetadata: Value(
        metadata != null ? jsonEncode(metadata) : null,
      ),
      updatedAt: Value(updatedAt ?? DateTime.now()),
    );
  }

  Future<AuthSessionModel> toSession(CredentialCipher cipher) async {
    final accessToken = await cipher.decrypt(encryptedAccessToken);
    final refreshToken = encryptedRefreshToken != null
        ? await cipher.decrypt(encryptedRefreshToken!)
        : null;
    final user = AuthUserModel(
      id: userId,
      email: email,
      displayName: displayName,
      metadata: metadata,
    );
    return AuthSessionModel(
      fromCache: true,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(expiresAt!, isUtc: true).toLocal()
          : null,
    );
  }
}
