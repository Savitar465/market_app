import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:market_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:market_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:market_app/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:market_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:market_app/features/auth/presentation/pages/login_page.dart';
import 'package:market_app/features/market/presentation/pages/market_home_page.dart';

class App extends StatelessWidget {
  App({
    super.key,
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        _loginUseCase = LoginUseCase(authRepository),
        _logoutUseCase = LogoutUseCase(authRepository),
        _restoreSessionUseCase = RestoreSessionUseCase(authRepository);

  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: _authRepository,
      child: BlocProvider(
        create: (context) => AuthBloc(
          loginUseCase: _loginUseCase,
          logoutUseCase: _logoutUseCase,
          restoreSessionUseCase: _restoreSessionUseCase,
        )..add(const AuthStarted()),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Market App',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              ),
              home: switch (state) {
                AuthAuthenticated() => const MarketHomePage(),
                AuthLoading() => const _LoadingScreen(),
                _ => const LoginPage(),
              },
              routes: {
                LoginPage.routeName: (_) => const LoginPage(),
                MarketHomePage.routeName: (_) => const MarketHomePage(),
              },
            );
          },
        ),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
