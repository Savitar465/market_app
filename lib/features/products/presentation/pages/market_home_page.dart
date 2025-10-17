import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:market_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketProduct {
  const MarketProduct({
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.description,
    this.isTrending = false,
    this.inStock = true,
    this.rating,
  });

  final String name;
  final String category;
  final double price;
  final String unit;
  final String description;
  final bool isTrending;
  final bool inStock;
  final double? rating;

  factory MarketProduct.fromMap(Map<String, dynamic> map) {
    double? parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    bool parseBool(dynamic value, {bool fallback = false}) {
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.toLowerCase();
        if (normalized == 'true') {
          return true;
        }
        if (normalized == 'false') {
          return false;
        }
      }
      return fallback;
    }

    final name = (map['name'] ?? 'Untitled product').toString().trim();
    final category = (map['category'] ?? 'General').toString().trim();
    final unitValue = (map['unit'] ?? '').toString().trim();
    final descriptionValue = (map['description'] ?? 'Details coming soon.')
        .toString()
        .trim();

    return MarketProduct(
      name: name.isEmpty ? 'Untitled product' : name,
      category: category.isEmpty ? 'General' : category,
      price: parseDouble(map['price']) ?? 0,
      unit: unitValue.isEmpty ? 'unit' : unitValue,
      description: descriptionValue.isEmpty
          ? 'Details coming soon.'
          : descriptionValue,
      isTrending: parseBool(map['is_trending']),
      inStock: parseBool(map['in_stock'], fallback: true),
      rating: parseDouble(map['rating']),
    );
  }

  String get priceLabel => '\$${price.toStringAsFixed(2)} / $unit';
}

class MarketHomePage extends StatefulWidget {
  const MarketHomePage({super.key});
  static const routeName = '/market';

  @override
  State<MarketHomePage> createState() => _MarketHomePageState();
}

class _MarketHomePageState extends State<MarketHomePage> {
  static const String _productsTable = 'products';

  static const List<MarketProduct> _seedProducts = [
    MarketProduct(
      name: 'Honeycrisp Apples',
      category: 'Produce',
      price: 2.49,
      unit: 'lb',
      description: 'Crisp and sweet from nearby orchards.',
      isTrending: true,
      rating: 4.8,
    ),
    MarketProduct(
      name: 'Sourdough Bread',
      category: 'Bakery',
      price: 5.75,
      unit: 'loaf',
      description: 'Naturally leavened and baked fresh daily.',
      rating: 4.6,
    ),
    MarketProduct(
      name: 'Cold Brew Concentrate',
      category: 'Beverages',
      price: 8.99,
      unit: 'bottle',
      description: 'Small-batch roasted beans steeped for 18 hours.',
      isTrending: true,
      rating: 4.9,
    ),
    MarketProduct(
      name: 'Baby Spinach',
      category: 'Produce',
      price: 3.49,
      unit: 'bag',
      description: 'Triple-washed greens ready for tossing.',
      inStock: false,
      rating: 4.4,
    ),
    MarketProduct(
      name: 'Greek Yogurt',
      category: 'Dairy',
      price: 4.59,
      unit: '32 oz',
      description: 'Rich, creamy, and packed with protein.',
      rating: 4.7,
    ),
    MarketProduct(
      name: 'Eco Dish Soap',
      category: 'Household',
      price: 3.29,
      unit: '16 oz',
      description: 'Plant-based formula tough on grease.',
      rating: 4.2,
    ),
    MarketProduct(
      name: 'Free-Range Eggs',
      category: 'Dairy',
      price: 3.99,
      unit: 'dozen',
      description: 'Gathered from pasture-raised hens.',
      isTrending: true,
      rating: 4.9,
    ),
    MarketProduct(
      name: 'Dark Chocolate Almonds',
      category: 'Snacks',
      price: 6.25,
      unit: 'bag',
      description: 'Roasted almonds coated in 70% cacao.',
      rating: 4.5,
    ),
  ];

  final TextEditingController _searchController = TextEditingController();

  List<MarketProduct> _products = const [];
  String _searchQuery = '';
  String? _selectedCategory;
  DateTime? _lastRefresh;
  bool _isLoading = true;
  String? _loadError;
  bool _usingFallbackProducts = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _searchQuery) {
      return;
    }
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _refreshProducts() {
    return _loadProducts(showPrimarySpinner: false);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = null;
      } else {
        _selectedCategory = category;
      }
    });
  }

  void _clearSearchAndFilters() {
    setState(() {
      _selectedCategory = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  List<MarketProduct> get _filteredProducts {
    final query = _searchQuery.toLowerCase();
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == null || product.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.unit.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get _availableCategories {
    final categories = _products
        .map((product) => product.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return categories;
  }

  String get _refreshLabel {
    if (_usingFallbackProducts) {
      return 'Showing fallback catalog while we reconnect to Supabase.';
    }
    if (_lastRefresh == null) {
      return 'Pull to refresh for the latest market activity';
    }
    final difference = DateTime.now().difference(_lastRefresh!);
    if (difference.inMinutes < 1) {
      return 'Updated moments ago';
    }
    if (difference.inHours < 1) {
      return 'Updated ${difference.inMinutes} min ago';
    }
    return 'Updated ${difference.inHours} hr ago';
  }

  void _onProductTap(BuildContext context, MarketProduct product) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            product.inStock
                ? 'Product details coming soon for ${product.name}.'
                : '${product.name} is currently unavailable.',
          ),
        ),
      );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Produce':
        return Icons.eco_outlined;
      case 'Bakery':
        return Icons.bakery_dining_outlined;
      case 'Beverages':
        return Icons.local_cafe_outlined;
      case 'Dairy':
        return Icons.egg_outlined;
      case 'Household':
        return Icons.cleaning_services_outlined;
      case 'Snacks':
        return Icons.cookie_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  Future<void> _loadProducts({bool showPrimarySpinner = true}) async {
    if (showPrimarySpinner) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    } else {
      setState(() {
        _loadError = null;
      });
    }

    try {
      final response = await Supabase.instance.client
          .from(_productsTable)
          .select()
          .order('name');

      final products = (response as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(MarketProduct.fromMap)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _lastRefresh = DateTime.now();
        _isLoading = false;
        _usingFallbackProducts = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = _readableErrorMessage(error);
      final hadProducts = _products.isNotEmpty;

      setState(() {
        _isLoading = false;
        if (!hadProducts) {
          _products = _seedProducts;
          _usingFallbackProducts = true;
        }
        _loadError = message;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      });
    }
  }

  String _readableErrorMessage(Object error) {
    if (error is PostgrestException && error.message.isNotEmpty) {
      return error.message;
    }
    return 'We had trouble loading products. Please pull to refresh.';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final bool isOfflineSession =
        authState is AuthAuthenticated && authState.isOffline;
    final filteredProducts = _filteredProducts;
    final categories = _availableCategories;
    final bool showErrorView = _loadError != null && _products.isEmpty;
    final bool showEmptyState =
        !showErrorView && !_isLoading && filteredProducts.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            onPressed: (_searchQuery.isNotEmpty || _selectedCategory != null)
                ? _clearSearchAndFilters
                : null,
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
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
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isOfflineSession
                ? Container(
                    key: const ValueKey('offline-banner'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.offline_bolt, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You are browsing with cached credentials. Some actions may be limited until you reconnect.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.orange.shade900),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (_usingFallbackProducts)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.blueGrey.shade50,
              child: Row(
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    color: Colors.blueGrey.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Showing fallback catalog while we reconnect to Supabase.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              displacement: 24,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Market feed',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _refreshLabel,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              labelText: 'Search products',
                              hintText: 'Try "coffee" or "household"',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      onPressed: _clearSearchAndFilters,
                                      icon: const Icon(Icons.clear),
                                      tooltip: 'Clear search',
                                    )
                                  : null,
                            ),
                          ),
                          if (categories.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Browse by category',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: categories.map((category) {
                                final bool isSelected =
                                    _selectedCategory == category;
                                return FilterChip(
                                  selected: isSelected,
                                  onSelected: (_) => _toggleCategory(category),
                                  label: Text(category),
                                  avatar: Icon(
                                    _iconForCategory(category),
                                    size: 18,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            showErrorView
                                ? _loadError ?? 'Unable to load products'
                                : filteredProducts.isEmpty
                                ? 'No matching products'
                                : '${filteredProducts.length} curated products',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (showErrorView)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _FeedErrorView(
                        message: _loadError ?? 'Unable to load products',
                        onRetry: () => _loadProducts(),
                      ),
                    )
                  else if (showEmptyState)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.hourglass_empty_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nothing on the shelf just yet',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                              ),
                              child: Text(
                                'Try adjusting the search or filters to discover more items.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final product = filteredProducts[index];
                        return _ProductCard(
                          product: product,
                          icon: _iconForCategory(product.category),
                          onTap: () => _onProductTap(context, product),
                        );
                      }, childCount: filteredProducts.length),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.icon,
    required this.onTap,
  });

  final MarketProduct product;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.textTheme.bodySmall?.color,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: product.isTrending
                      ? Colors.orange.shade100
                      : theme.colorScheme.primary.withValues(alpha: 0.08),
                  foregroundColor: theme.colorScheme.primary,
                  child: Icon(icon),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            product.priceLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(product.description, style: bodyStyle),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(product.category),
                            avatar: Icon(icon, size: 16),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          if (product.isTrending)
                            Chip(
                              label: const Text('Trending'),
                              avatar: const Icon(Icons.trending_up, size: 16),
                              backgroundColor: Colors.orange.shade50,
                            ),
                          Chip(
                            label: Text(
                              product.inStock ? 'In stock' : 'Out of stock',
                            ),
                            avatar: Icon(
                              product.inStock
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              size: 16,
                            ),
                            backgroundColor: product.inStock
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            labelStyle: TextStyle(
                              color: product.inStock
                                  ? Colors.green.shade800
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (product.rating != null)
                            Chip(
                              label: Text(product.rating!.toStringAsFixed(1)),
                              avatar: const Icon(
                                Icons.star_rate_rounded,
                                size: 16,
                              ),
                              backgroundColor: Colors.yellow.shade50,
                              labelStyle: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedErrorView extends StatelessWidget {
  const _FeedErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Unable to reach the market right now',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
