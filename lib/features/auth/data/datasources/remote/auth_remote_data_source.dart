import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:market_app/features/auth/data/models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  Future<AuthSessionModel> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final session = response.session;
    if (session == null) {
      throw const AuthRemoteException('Unable to retrieve session from Supabase response');
    }
    return AuthSessionModel.fromSupabase(session);
  }

  Future<AuthSessionModel?> currentSession() async {
    final session = _client.auth.currentSession;
    if (session == null) {
      return null;
    }
    return AuthSessionModel.fromSupabase(session);
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}

class AuthRemoteException implements Exception {
  const AuthRemoteException(this.message);
  final String message;
  @override
  String toString() => message;
}
