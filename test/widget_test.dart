import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/app/app.dart';
import 'package:market_app/features/auth/domain/entities/auth_session.dart';
import 'package:market_app/features/auth/domain/entities/auth_user.dart';
import 'package:market_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:market_app/features/auth/presentation/pages/login_page.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({required String email, required String password}) {
    final user = AuthUser(id: '1', email: email);
    return Future.value(AuthSession(user: user, accessToken: 'token'));
  }

  @override
  Future<void> logout() async {}

  @override
  Future<AuthSession?> restoreSession() async => null;
}

void main() {
  testWidgets('Shows Login screen initially', (WidgetTester tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(App(authRepository: repository));
    await tester.pump();

    expect(find.byType(LoginPage), findsOneWidget);
  });
}
