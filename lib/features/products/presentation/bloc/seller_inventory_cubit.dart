import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_location.dart';
import 'package:market_app/features/products/data/models/product_model.dart';
import 'package:market_app/features/products/domain/entities/product.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerInventoryState extends Equatable {
  const SellerInventoryState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  final bool isLoading;
  final List<SellerInventoryItem> items;
  final String? error;

  SellerInventoryState copyWith({
    bool? isLoading,
    List<SellerInventoryItem>? items,
    String? error,
  }) {
    return SellerInventoryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, items, error];
}

class SellerInventoryItem extends Equatable {
  const SellerInventoryItem({
    required this.product,
    required this.quantityOnHand,
    required this.quantityReserved,
    this.updatedAt,
  });

  final Product product;
  final double quantityOnHand;
  final double quantityReserved;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
    product,
    quantityOnHand,
    quantityReserved,
    updatedAt,
  ];
}

class SellerInventoryCubit extends Cubit<SellerInventoryState> {
  SellerInventoryCubit({required SupabaseClient supabase})
    : _supabase = supabase,
      super(const SellerInventoryState());

  final SupabaseClient _supabase;

  Future<void> loadForLocation({
    required String sellerId,
    required InventoryLocation location,
  }) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await _supabase
          .schema('market')
          .from('inventory_stocks')
          .select(
            'product_id, quantity_on_hand, quantity_reserved, updated_at, products(*)',
          )
          .eq('location_id', location.id)
          .eq('location_type', location.type.label)
          .eq('products.seller_id', sellerId)
          .order('updated_at', ascending: false);

      final rows = (response as List).cast<Map<String, dynamic>>();

      final items = <SellerInventoryItem>[];
      for (final entry in rows) {
        final productMap = entry['products'];
        if (productMap is! Map<String, dynamic>) {
          continue;
        }
        final productModel = ProductModel.fromRemote(productMap);
        final product = productModel.toEntity();
        final quantityOnHand = _parseDouble(entry['quantity_on_hand']);
        final quantityReserved = _parseDouble(entry['quantity_reserved']);
        final updatedAt = _parseDate(entry['updated_at']);
        items.add(
          SellerInventoryItem(
            product: product,
            quantityOnHand: quantityOnHand,
            quantityReserved: quantityReserved,
            updatedAt: updatedAt,
          ),
        );
      }

      emit(state.copyWith(isLoading: false, items: items, error: null));
    } on PostgrestException catch (error) {
      emit(state.copyWith(isLoading: false, error: error.message));
    } on TypeError catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Respuesta inesperada de Supabase',
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  void clear() {
    emit(state.copyWith(isLoading: false, items: const [], error: null));
  }

  double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc();
    }
    return null;
  }
}
