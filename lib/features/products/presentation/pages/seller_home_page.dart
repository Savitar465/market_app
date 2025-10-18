import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:market_app/features/auth/domain/entities/auth_session.dart';
import 'package:market_app/features/products/domain/entities/seller.dart';
import 'package:market_app/features/products/domain/entities/product_failure.dart';
import 'package:market_app/features/products/domain/repositories/product_repository.dart';
import 'package:market_app/features/products/presentation/bloc/product_catalog_cubit.dart';
import 'package:market_app/features/products/presentation/bloc/product_editor_cubit.dart';
import 'package:market_app/features/products/presentation/pages/market_home_page.dart';
import 'package:market_app/features/products/presentation/pages/seller_products_page.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key, required this.session});

  final AuthSession session;

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  Seller? _seller;
  bool _isLoadingSeller = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveSeller();
    });
  }

  Future<void> _resolveSeller() async {
    final repository = context.read<ProductRepository>();
    final user = widget.session.user;

    setState(() {
      _isLoadingSeller = true;
      _loadError = null;
    });

    try {
      Seller? seller = await repository.loadSellerForUser(user.id);
      seller ??= await repository.refreshSellerForUser(user.id);
      if (seller == null && user.sellerId != null) {
        seller = Seller(
          id: user.sellerId!,
          userId: user.id,
          storeName: user.displayName ?? user.email,
        );
      }
      if (!mounted) {
        return;
      }
      if (seller == null) {
        setState(() {
          _seller = null;
          _isLoadingSeller = false;
          _loadError =
              'No seller profile found. Ask an administrator to create one.';
        });
        return;
      }
      setState(() {
        _seller = seller;
        _isLoadingSeller = false;
      });
    } on ProductFailure catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _seller = null;
        _isLoadingSeller = false;
        _loadError = error.message;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _seller = null;
        _isLoadingSeller = false;
        _loadError = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSeller) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_seller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Seller workspace')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.store_mall_directory_outlined, size: 64),
                const SizedBox(height: 16),
                Text(
                  _loadError ?? 'Seller profile unavailable.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _resolveSeller,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final seller = _seller!;
    final repository = context.read<ProductRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCatalogCubit>(
          create: (_) =>
              ProductCatalogCubit(repository: repository, sellerId: seller.id)
                ..refresh(),
        ),
        BlocProvider<ProductEditorCubit>(
          create: (_) =>
              ProductEditorCubit(repository: repository, sellerId: seller.id),
        ),
      ],
      child: _SellerHomeShell(
        session: widget.session,
        seller: seller,
        onReloadSeller: _resolveSeller,
      ),
    );
  }
}

class _SellerHomeShell extends StatefulWidget {
  const _SellerHomeShell({
    required this.session,
    required this.seller,
    required this.onReloadSeller,
  });

  final AuthSession session;
  final Seller seller;
  final VoidCallback onReloadSeller;

  @override
  State<_SellerHomeShell> createState() => _SellerHomeShellState();
}

class _SellerHomeShellState extends State<_SellerHomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      SellerProductsPage(
        session: widget.session,
        seller: widget.seller,
        onReloadSeller: widget.onReloadSeller,
      ),
      const MarketHomePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            label: 'My catalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Marketplace',
          ),
        ],
        onDestinationSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
      ),
    );
  }
}
