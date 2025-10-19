import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/employee.dart';
import '../../domain/entities/inventory_location.dart';
import '../../domain/entities/inventory_stock.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../bloc/employees_cubit.dart';
import '../bloc/locations_cubit.dart';
import 'inventory_ui_utils.dart';

class InventoryMasterSection extends StatefulWidget {
  const InventoryMasterSection({super.key});

  @override
  State<InventoryMasterSection> createState() => _InventoryMasterSectionState();
}

class _InventoryMasterSectionState extends State<InventoryMasterSection>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Ubicaciones'),
            Tab(text: 'Empleados'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: const [_LocationsTab(), _EmployeesTab()],
          ),
        ),
      ],
    );
  }
}

class _LocationsTab extends StatelessWidget {
  const _LocationsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (context, state) {
        final locations = [...state.stores, ...state.warehouses];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showLocationDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva ubicacion'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: locations.isEmpty
                    ? const Center(
                        child: Text('No hay ubicaciones registradas.'),
                      )
                    : ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          return Card(
                            child: ListTile(
                              title: Text(location.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.type == InventoryLocationType.store
                                        ? 'Tienda'
                                        : 'Almacen',
                                  ),
                                  if (location.address != null)
                                    Text(location.address!),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Ver inventario',
                                    icon: const Icon(
                                      Icons.inventory_2_outlined,
                                    ),
                                    onPressed: () => _showLocationInventory(
                                      context,
                                      location: location,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _confirmDeleteLocation(
                                      context,
                                      location,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showLocationDialog(
                                context,
                                location: location,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmployeesTab extends StatelessWidget {
  const _EmployeesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (context, locationsState) {
        final allLocations = [
          ...locationsState.stores,
          ...locationsState.warehouses,
        ];
        final locationFilters = <DropdownMenuItem<String?>>[
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('Todas las ubicaciones'),
          ),
          ...allLocations.map(
            (location) => DropdownMenuItem<String?>(
              value: location.id,
              child: Text(location.name),
            ),
          ),
        ];

        return BlocBuilder<EmployeesCubit, EmployeesState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: state.locationFilter,
                          items: locationFilters,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por ubicacion',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => context
                              .read<EmployeesCubit>()
                              .initialize(locationId: value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => _showEmployeeDialog(context),
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Nuevo empleado'),
                      ),
                    ],
                  ),
                  if (state.isLoading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ] else
                    const SizedBox(height: 12),
                  Expanded(
                    child: state.employees.isEmpty
                        ? const Center(
                            child: Text('No hay empleados registrados.'),
                          )
                        : ListView.builder(
                            itemCount: state.employees.length,
                            itemBuilder: (context, index) {
                              final employee = state.employees[index];
                              final locationName = _locationNameFor(
                                allLocations,
                                employee.locationId,
                              );
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(
                                      employee.displayName.characters
                                          .take(2)
                                          .toString()
                                          .toUpperCase(),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(employee.displayName),
                                      ),
                                      if (!employee.isActive)
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8),
                                          child: Chip(label: Text('Inactivo')),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (employee.email != null &&
                                          employee.email!.isNotEmpty)
                                        Text(employee.email!),
                                      Text('Rol: ${employee.role}'),
                                      if (locationName != null)
                                        Text('Ubicacion: $locationName'),
                                      if (employee.phone != null &&
                                          employee.phone!.isNotEmpty)
                                        Text('Telefono: ${employee.phone}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Switch(
                                        value: employee.isActive,
                                        onChanged: (value) =>
                                            _toggleEmployeeActive(
                                              context,
                                              employee,
                                              value,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _confirmDeleteEmployee(
                                          context,
                                          employee,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showEmployeeDialog(
                                    context,
                                    employee: employee,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Future<void> _showLocationDialog(
  BuildContext context, {
  InventoryLocation? location,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: location?.name ?? '');
  final addressController = TextEditingController(
    text: location?.address ?? '',
  );
  InventoryLocationType type = location?.type ?? InventoryLocationType.store;
  final uuid = const Uuid();
  final locationsCubit = context.read<LocationsCubit>();

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(location == null ? 'Nueva ubicacion' : 'Editar ubicacion'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<InventoryLocationType>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: InventoryLocationType.values
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(
                          value == InventoryLocationType.store
                              ? 'Tienda'
                              : 'Almacen',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) type = value;
                },
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Direccion'),
              ),
            ],
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
                final updated = InventoryLocation(
                  id: location?.id ?? uuid.v4(),
                  type: type,
                  name: nameController.text.trim(),
                  address: addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                  isActive: location?.isActive ?? true,
                  createdAt: location?.createdAt ?? DateTime.now().toUtc(),
                  updatedAt: DateTime.now().toUtc(),
                );
                if (!context.mounted) {
                  return;
                }
                locationsCubit.saveLocation(updated);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      );
    },
  );
}

Future<void> _confirmDeleteLocation(
  BuildContext context,
  InventoryLocation location,
) async {
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar ubicacion'),
          content: Text('Eliminar ${location.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
  if (!context.mounted) {
    return;
  }
  if (confirmed) {
    await context.read<LocationsCubit>().deleteLocation(location.id);
  }
}

Future<void> _showLocationInventory(
  BuildContext context, {
  required InventoryLocation location,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: _LocationInventorySheet(location: location),
    ),
  );
}

Future<void> _showEmployeeDialog(
  BuildContext context, {
  Employee? employee,
}) async {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController(
    text: employee?.firstName ?? '',
  );
  final lastNameController = TextEditingController(
    text: employee?.lastName ?? '',
  );
  final roleController = TextEditingController(text: employee?.role ?? '');
  final emailController = TextEditingController(text: employee?.email ?? '');
  final phoneController = TextEditingController(text: employee?.phone ?? '');
  final passwordController = TextEditingController();
  final uuid = const Uuid();
  final locationsCubit = context.read<LocationsCubit>();
  final locations = locationsCubit.state;
  final options = [...locations.stores, ...locations.warehouses];
  String? locationId = employee?.locationId;
  final employeesCubit = context.read<EmployeesCubit>();
  final supabase = Supabase.instance.client;
  final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  final hasLinkedAuthUser = employee?.authUserId != null;
  var isActive = employee?.isActive ?? true;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      bool isSaving = false;
      return StatefulBuilder(
        builder: (stateContext, setState) {
          return AlertDialog(
            title: Text(
              employee == null ? 'Nuevo empleado' : 'Editar empleado',
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(labelText: 'Nombres'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingrese nombres'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Apellidos'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return 'Ingrese email';
                        }
                        if (!emailPattern.hasMatch(trimmed)) {
                          return 'Ingrese un email valido';
                        }
                        return null;
                      },
                      readOnly: hasLinkedAuthUser,
                    ),
                    if (!hasLinkedAuthUser) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Contrasena temporal',
                        ),
                        obscureText: true,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if (hasLinkedAuthUser) {
                            return null;
                          }
                          final trimmed = value?.trim() ?? '';
                          if (trimmed.length < 8) {
                            return 'La contrasena debe tener al menos 8 caracteres';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Telefono'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Empleado activo'),
                      value: isActive,
                      onChanged: (value) {
                        setState(() => isActive = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: roleController.text.isEmpty
                          ? null
                          : roleController.text,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(
                          value: 'seller',
                          child: Text('seller'),
                        ),
                        DropdownMenuItem(value: 'admin', child: Text('admin')),
                        DropdownMenuItem(value: 'user', child: Text('user')),
                      ],
                      onChanged: (value) {
                        roleController.text = value ?? '';
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: locationId,
                      decoration: const InputDecoration(labelText: 'Ubicacion'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sin asignacion'),
                        ),
                        ...options.map(
                          (location) => DropdownMenuItem(
                            value: location.id,
                            child: Text(location.name),
                          ),
                        ),
                      ],
                      onChanged: (value) => locationId = value,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        FocusScope.of(stateContext).unfocus();
                        setState(() => isSaving = true);

                        final trimmedFirstName = firstNameController.text
                            .trim();
                        final trimmedLastName = lastNameController.text.trim();
                        final trimmedEmail = emailController.text.trim();
                        final trimmedPhone = phoneController.text.trim();
                        final trimmedRole = roleController.text.trim();
                        final roleValue = trimmedRole.isEmpty
                            ? 'user'
                            : trimmedRole.toLowerCase();

                        var authUserId = employee?.authUserId;

                        try {
                          if (!hasLinkedAuthUser) {
                            final password = passwordController.text.trim();
                            final response = await supabase.auth.signUp(
                              email: trimmedEmail,
                              password: password,
                              data: {
                                'first_name': trimmedFirstName,
                                if (trimmedLastName.isNotEmpty)
                                  'last_name': trimmedLastName,
                                'role': roleValue,
                              },
                            );
                            authUserId = response.user?.id;
                            final createdUserId = authUserId;
                            if (createdUserId == null) {
                              throw AuthException(
                                'No se pudo obtener el usuario de Supabase',
                              );
                            }
                            await _assignSupabaseUserRole(
                              supabase,
                              userId: createdUserId,
                              role: roleValue,
                            );
                          }

                          final updated = Employee(
                            id: employee?.id ?? uuid.v4(),
                            firstName: trimmedFirstName,
                            lastName: trimmedLastName.isEmpty
                                ? null
                                : trimmedLastName,
                            email: trimmedEmail,
                            phone: trimmedPhone.isEmpty ? null : trimmedPhone,
                            authUserId: authUserId,
                            role: roleValue,
                            locationId: locationId,
                            locationType: locationId == null
                                ? null
                                : options
                                      .firstWhere(
                                        (element) => element.id == locationId,
                                      )
                                      .type
                                      .label,
                            isActive: isActive,
                            hiredAt:
                                employee?.hiredAt ?? DateTime.now().toUtc(),
                            createdAt:
                                employee?.createdAt ?? DateTime.now().toUtc(),
                            updatedAt: DateTime.now().toUtc(),
                            syncedAt: employee?.syncedAt,
                          );

                          await employeesCubit.saveEmployee(updated);
                          if (!stateContext.mounted || !context.mounted) {
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                hasLinkedAuthUser
                                    ? 'Empleado actualizado'
                                    : 'Empleado creado y vinculado a Supabase',
                              ),
                            ),
                          );
                        } on AuthException catch (error) {
                          if (stateContext.mounted) {
                            setState(() => isSaving = false);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)),
                            );
                          }
                        } catch (error) {
                          if (stateContext.mounted) {
                            setState(() => isSaving = false);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "No se pudo guardar el empleado: $error",
                                ),
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _toggleEmployeeActive(
  BuildContext context,
  Employee employee,
  bool isActive,
) {
  final employeesCubit = context.read<EmployeesCubit>();
  final updated = employee.copyWith(
    isActive: isActive,
    updatedAt: DateTime.now().toUtc(),
  );
  employeesCubit.saveEmployee(updated);
}

Future<void> _confirmDeleteEmployee(
  BuildContext context,
  Employee employee,
) async {
  final confirmed =
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar empleado'),
          content: Text('Eliminar a ${employee.displayName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ) ??
      false;
  if (!context.mounted) {
    return;
  }
  if (confirmed) {
    await context.read<EmployeesCubit>().deleteEmployee(employee.id);
  }
}

class _LocationInventorySheet extends StatelessWidget {
  const _LocationInventorySheet({required this.location});

  final InventoryLocation location;

  @override
  Widget build(BuildContext context) {
    final inventoryRepository = context.read<InventoryRepository>();
    final typeLabel = location.type == InventoryLocationType.store
        ? 'Tienda'
        : 'Almacen';

    return Material(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder<List<InventoryStock>>(
            stream: inventoryRepository.watchInventory(
              locationId: location.id,
              locationType: location.type,
            ),
            builder: (context, snapshot) {
              final stocks = snapshot.data ?? const <InventoryStock>[];
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              location.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(typeLabel),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'No se pudo cargar el inventario: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  if (isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (stocks.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No hay inventario registrado en esta ubicacion.',
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        itemCount: stocks.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final stock = stocks[index];
                          final unit = stock.unit == null || stock.unit!.isEmpty
                              ? ''
                              : ' ${stock.unit}';
                          return ListTile(
                            title: Text(stock.productName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Disponible: ${stock.quantityOnHand.toStringAsFixed(2)}$unit',
                                ),
                                if (stock.quantityReserved > 0)
                                  Text(
                                    'Reservado: ${stock.quantityReserved.toStringAsFixed(2)}$unit',
                                  ),
                                if (stock.updatedAt != null)
                                  Text(
                                    'Actualizado: ${formatDate(stock.updatedAt!.toLocal())}',
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String? _locationNameFor(
  List<InventoryLocation> locations,
  String? locationId,
) {
  if (locationId == null) {
    return null;
  }
  for (final location in locations) {
    if (location.id == locationId) {
      return location.name;
    }
  }
  return null;
}

Future<void> _assignSupabaseUserRole(
  SupabaseClient client, {
  required String userId,
  required String role,
}) async {
  final roleCode = _normalizeSupabaseRoleCode(role);
  if (roleCode == null) {
    return;
  }

  try {
    await client.schema('market').from('user_roles').insert({
      'user_id': userId,
      'role_code': roleCode,
    });
  } on PostgrestException catch (error) {
    throw AuthException(
      'No se pudo asignar el rol en Supabase: ${error.message}',
    );
  } catch (error) {
    throw const AuthException('No se pudo asignar el rol en Supabase');
  }
}

String? _normalizeSupabaseRoleCode(String role) {
  final normalized = role.trim().toLowerCase();
  if (normalized.isEmpty) {
    return 'customer';
  }
  switch (normalized) {
    case 'admin':
    case 'seller':
      return normalized;
    case 'user':
    case 'customer':
    case 'colaborador':
      return 'customer';
    default:
      return normalized;
  }
}
