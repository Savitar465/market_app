import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../domain/entities/inventory_location.dart';
import '../../domain/entities/inventory_transaction.dart';
import '../bloc/locations_cubit.dart';
import '../bloc/transactions_cubit.dart';
import 'inventory_ui_utils.dart';

class InventoryTransactionsSection extends StatefulWidget {
  const InventoryTransactionsSection({super.key});

  @override
  State<InventoryTransactionsSection> createState() =>
      _InventoryTransactionsSectionState();
}

class _InventoryTransactionsSectionState
    extends State<InventoryTransactionsSection>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Compras'),
            Tab(text: 'Ventas'),
            Tab(text: 'Transferencias'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: const [
              _PurchaseForm(),
              _SaleForm(),
              _TransferForm(),
            ],
          ),
        ),
      ],
    );
  }
}

class _PurchaseForm extends StatefulWidget {
  const _PurchaseForm();

  @override
  State<_PurchaseForm> createState() => _PurchaseFormState();
}

class _PurchaseFormState extends State<_PurchaseForm> {
  final _formKey = GlobalKey<FormState>();
  String? _locationId;
  InventoryLocationType? _locationType;
  final _supplierController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime _date = DateTime.now();
  final List<_LineDraft> _lines = [];

  @override
  Widget build(BuildContext context) {
    final locationsState = context.watch<LocationsCubit>().state;
    final locations = [
      ...locationsState.stores,
      ...locationsState.warehouses,
    ];

    return _TransactionFormShell(
      title: 'Registrar compra',
      formKey: _formKey,
      onSubmit: () {
        if ((_formKey.currentState?.validate() ?? false) &&
            _locationId != null &&
            _locationType != null &&
            _lines.isNotEmpty) {
          final purchase = Purchase(
            id: const Uuid().v4(),
            locationId: _locationId!,
            locationType: _locationType!,
            supplierName: _supplierController.text.trim(),
            referenceCode: _referenceController.text.trim(),
            date: _date,
            lines: _lines
                .map(
                  (draft) => PurchaseLine(
                    productId: draft.productId ?? '',
                    quantity: draft.quantity,
                    unitCost: draft.unitValue,
                    lineTotal: draft.quantity * draft.unitValue,
                  ),
                )
                .toList(),
          );
          context.read<TransactionsCubit>().recordPurchase(purchase);
          setState(() {
            _lines.clear();
          });
        }
      },
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _locationId,
            decoration: const InputDecoration(labelText: 'Ubicacion de destino'),
            items: locations
                .map(
                  (location) => DropdownMenuItem(
                    value: location.id,
                    child: Text(location.name),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _locationId = value;
                _locationType = value == null
                    ? null
                    : locations.firstWhere((element) => element.id == value).type;
              });
            },
            validator: (value) => value == null ? 'Seleccione una ubicacion' : null,
          ),
          TextFormField(
            controller: _supplierController,
            decoration: const InputDecoration(labelText: 'Proveedor'),
          ),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(labelText: 'Referencia'),
          ),
          _DateSelector(
            date: _date,
            onChanged: (value) => setState(() => _date = value),
          ),
          _LinesList(
            lines: _lines,
            onAdd: () => _addLine(context, isSale: false),
            onRemove: (line) => setState(() => _lines.remove(line)),
            isSale: false,
          ),
        ],
      ),
    );
  }

  Future<void> _addLine(BuildContext context, {required bool isSale}) async {
    final draft = await _LineEditor.show(context, isSale: isSale);
    if (draft != null) {
      setState(() => _lines.add(draft));
    }
  }
}

class _SaleForm extends StatefulWidget {
  const _SaleForm();

  @override
  State<_SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<_SaleForm> {
  final _formKey = GlobalKey<FormState>();
  String? _storeId;
  final _customerController = TextEditingController();
  final _referenceController = TextEditingController();
  DateTime _date = DateTime.now();
  final List<_LineDraft> _lines = [];

  @override
  Widget build(BuildContext context) {
    final stores = context.watch<LocationsCubit>().state.stores;

    return _TransactionFormShell(
      title: 'Registrar venta',
      formKey: _formKey,
      onSubmit: () {
        if ((_formKey.currentState?.validate() ?? false) &&
            _storeId != null &&
            _lines.isNotEmpty) {
          final sale = Sale(
            id: const Uuid().v4(),
            storeId: _storeId!,
            customerName: _customerController.text.trim(),
            referenceCode: _referenceController.text.trim(),
            date: _date,
            lines: _lines
                .map(
                  (draft) => SaleLine(
                    productId: draft.productId ?? '',
                    quantity: draft.quantity,
                    unitPrice: draft.unitValue,
                    lineTotal: draft.quantity * draft.unitValue,
                  ),
                )
                .toList(),
          );
          context.read<TransactionsCubit>().recordSale(sale);
          setState(() {
            _lines.clear();
          });
        }
      },
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _storeId,
            decoration: const InputDecoration(labelText: 'Tienda'),
            items: stores
                .map(
                  (store) => DropdownMenuItem(
                    value: store.id,
                    child: Text(store.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _storeId = value),
            validator: (value) => value == null ? 'Seleccione tienda' : null,
          ),
          TextFormField(
            controller: _customerController,
            decoration: const InputDecoration(labelText: 'Cliente'),
          ),
          TextFormField(
            controller: _referenceController,
            decoration: const InputDecoration(labelText: 'Referencia'),
          ),
          _DateSelector(
            date: _date,
            onChanged: (value) => setState(() => _date = value),
          ),
          _LinesList(
            lines: _lines,
            onAdd: () => _addLine(context, isSale: true),
            onRemove: (line) => setState(() => _lines.remove(line)),
            isSale: true,
          ),
        ],
      ),
    );
  }

  Future<void> _addLine(BuildContext context, {required bool isSale}) async {
    final draft = await _LineEditor.show(context, isSale: isSale);
    if (draft != null) {
      setState(() => _lines.add(draft));
    }
  }
}

class _TransferForm extends StatefulWidget {
  const _TransferForm();

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _formKey = GlobalKey<FormState>();
  String? _originId;
  String? _destinationId;
  InventoryLocationType? _originType;
  InventoryLocationType? _destinationType;
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  final List<_LineDraft> _lines = [];

  @override
  Widget build(BuildContext context) {
    final locations = context.watch<LocationsCubit>().state;
    final options = [
      ...locations.stores,
      ...locations.warehouses,
    ];

    return _TransactionFormShell(
      title: 'Registrar transferencia',
      formKey: _formKey,
      onSubmit: () {
        if ((_formKey.currentState?.validate() ?? false) &&
            _originId != null &&
            _destinationId != null &&
            _originType != null &&
            _destinationType != null &&
            _lines.isNotEmpty) {
          final transfer = InventoryTransfer(
            id: const Uuid().v4(),
            originLocationId: _originId!,
            originLocationType: _originType!,
            destinationLocationId: _destinationId!,
            destinationLocationType: _destinationType!,
            notes: _notesController.text.trim(),
            date: _date,
            lines: _lines
                .map(
                  (draft) => TransferLine(
                    productId: draft.productId ?? '',
                    quantity: draft.quantity,
                  ),
                )
                .toList(),
          );
          context.read<TransactionsCubit>().recordTransfer(transfer);
          setState(() {
            _lines.clear();
            _notesController.clear();
          });
        }
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _originId,
                  decoration: const InputDecoration(labelText: 'Origen'),
                  items: options
                      .map(
                        (location) => DropdownMenuItem(
                          value: location.id,
                          child: Text(location.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _originId = value;
                    _originType = value == null
                        ? null
                        : options.firstWhere((element) => element.id == value).type;
                  }),
                  validator: (value) => value == null ? 'Seleccione origen' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _destinationId,
                  decoration: const InputDecoration(labelText: 'Destino'),
                  items: options
                      .map(
                        (location) => DropdownMenuItem(
                          value: location.id,
                          child: Text(location.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _destinationId = value;
                    _destinationType = value == null
                        ? null
                        : options.firstWhere((element) => element.id == value).type;
                  }),
                  validator: (value) => value == null ? 'Seleccione destino' : null,
                ),
              ),
            ],
          ),
          _DateSelector(
            date: _date,
            onChanged: (value) => setState(() => _date = value),
          ),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          _LinesList(
            lines: _lines,
            onAdd: () => _addLine(context),
            onRemove: (line) => setState(() => _lines.remove(line)),
            isSale: true,
          ),
        ],
      ),
    );
  }

  Future<void> _addLine(BuildContext context) async {
    final draft = await _LineEditor.show(context, isSale: true);
    if (draft != null) {
      setState(() => _lines.add(draft));
    }
  }
}

class _TransactionFormShell extends StatelessWidget {
  const _TransactionFormShell({
    required this.title,
    required this.formKey,
    required this.onSubmit,
    required this.child,
  });

  final String title;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 16),
            BlocConsumer<TransactionsCubit, TransactionsState>(
              listener: (context, state) {
                if (state.message != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message!)));
                }
                if (state.error != null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.error!)));
                }
              },
              builder: (context, state) {
                return FilledButton.icon(
                  onPressed: state.isProcessing ? null : onSubmit,
                  icon: state.isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Guardar movimiento'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LinesList extends StatelessWidget {
  const _LinesList({
    required this.lines,
    required this.onAdd,
    required this.onRemove,
    required this.isSale,
  });

  final List<_LineDraft> lines;
  final VoidCallback onAdd;
  final ValueChanged<_LineDraft> onRemove;
  final bool isSale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Detalle',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Agregar'),
            ),
          ],
        ),
        if (lines.isEmpty)
          const Text('No hay productos agregados.')
        else
          Column(
            children: lines
                .map(
                  (line) => ListTile(
                    title: Text(line.product?.name ?? line.productId ?? ''),
                    subtitle: Text(
                      '${line.quantity.toStringAsFixed(2)} unidades | ${isSale ? 'Precio' : 'Costo'} ${formatCurrency(line.unitValue)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => onRemove(line),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _LineDraft {
  _LineDraft({
    required this.productId,
    this.product,
    required this.quantity,
    required this.unitValue,
  });

  final String? productId;
  final Product? product;
  final double quantity;
  final double unitValue;
}

class _LineEditor extends StatefulWidget {
  const _LineEditor({required this.isSale});

  final bool isSale;

  static Future<_LineDraft?> show(BuildContext context, {required bool isSale}) {
    return showDialog<_LineDraft>(
      context: context,
      builder: (_) => _LineEditor(isSale: isSale),
    );
  }

  @override
  State<_LineEditor> createState() => _LineEditorState();
}

class _LineEditorState extends State<_LineEditor> {
  final formKey = GlobalKey<FormState>();
  final productIdController = TextEditingController();
  final quantityController = TextEditingController();
  final valueController = TextEditingController();
  Product? selectedProduct;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProductRepository>();
    return FutureBuilder<List<Product>>(
      future: repository.watchProducts().first,
      builder: (context, snapshot) {
        final products = snapshot.data ?? const <Product>[];
        return AlertDialog(
          title: const Text('Agregar detalle'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Autocomplete<Product>(
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) return products;
                      return products.where((product) =>
                          product.name.toLowerCase().contains(value.text.toLowerCase()));
                    },
                    displayStringForOption: (product) => product.name,
                    onSelected: (product) {
                      selectedProduct = product;
                      productIdController.text = product.id;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(labelText: 'Producto'),
                      );
                    },
                  ),
                  TextFormField(
                    controller: productIdController,
                    decoration: const InputDecoration(labelText: 'ID de producto'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingrese el producto' : null,
                  ),
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Cantidad invalida';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: valueController,
                    decoration: InputDecoration(
                      labelText: widget.isSale ? 'Precio unitario' : 'Costo unitario',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null || parsed < 0) {
                        return 'Valor invalido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(
                    _LineDraft(
                      productId: productIdController.text.trim(),
                      product: selectedProduct,
                      quantity: double.parse(quantityController.text),
                      unitValue: double.parse(valueController.text),
                    ),
                  );
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Fecha: ${formatDate(date)}'),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime(DateTime.now().year + 5),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: const Text('Cambiar'),
        ),
      ],
    );
  }
}



