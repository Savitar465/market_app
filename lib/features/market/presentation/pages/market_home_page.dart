import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_app/features/auth/presentation/bloc/auth_bloc.dart';

class MarketHomePage extends StatelessWidget {
  const MarketHomePage({super.key});
  static const routeName = '/market';

  @override
  Widget build(BuildContext context) {
    final products = const [
      'Apples',
      'Bananas',
      'Carrots',
      'Detergent',
      'Eggs',
      'Flour',
      'Grapes',
    ];
    final authState = context.watch<AuthBloc>().state;
    final bool isOfflineSession =
        authState is AuthAuthenticated && authState.isOffline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          if (isOfflineSession)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.orange.shade100,
              child: const Row(
                children: [
                  Icon(Icons.offline_bolt, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are using cached credentials. Some actions may be limited until you reconnect.',
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final name = products[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(name[0])),
                  title: Text(name),
                  subtitle: const Text('Tap to view details (placeholder)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
