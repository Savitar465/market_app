import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/employee.dart';
import '../../domain/entities/inventory_location.dart';
import '../bloc/employees_cubit.dart';
import '../bloc/locations_cubit.dart';

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
            children: const [
              _LocationsTab(),
              _EmployeesTab(),
            ],
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
        final locations = [
          ...state.stores,
          ...state.warehouses,
        ];
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
                    ? const Center(child: Text('No hay ubicaciones registradas.'))
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
                                  Text(location.type == InventoryLocationType.store
                                      ? 'Tienda'
                                      : 'Almacen'),
                                  if (location.address != null)
                                    Text(location.address!),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _confirmDeleteLocation(context, location),
                              ),
                              onTap: () =>
                                  _showLocationDialog(context, location: location),
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
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _showEmployeeDialog(context),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Nuevo empleado'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.employees.isEmpty
                    ? const Center(child: Text('No hay empleados registrados.'))
                    : ListView.builder(
                        itemCount: state.employees.length,
                        itemBuilder: (context, index) {
                          final employee = state.employees[index];
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
                              title: Text(employee.displayName),
                              subtitle: Text(employee.role),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _confirmDeleteEmployee(context, employee),
                              ),
                              onTap: () =>
                                  _showEmployeeDialog(context, employee: employee),
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

Future<void> _showLocationDialog(
  BuildContext context, {
  InventoryLocation? location,
}) async {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: location?.name ?? '');
  final addressController = TextEditingController(text: location?.address ?? '');
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
                            value == InventoryLocationType.store ? 'Tienda' : 'Almacen'),
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
  final confirmed = await showDialog<bool>(
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

Future<void> _showEmployeeDialog(
  BuildContext context, {
  Employee? employee,
}) async {
  final formKey = GlobalKey<FormState>();
  final firstNameController =
      TextEditingController(text: employee?.firstName ?? '');
  final lastNameController =
      TextEditingController(text: employee?.lastName ?? '');
  final roleController = TextEditingController(text: employee?.role ?? '');
  final uuid = const Uuid();
  final locationsCubit = context.read<LocationsCubit>();
  final locations = locationsCubit.state;
  final options = [
    ...locations.stores,
    ...locations.warehouses,
  ];
  String? locationId = employee?.locationId;
  final employeesCubit = context.read<EmployeesCubit>();
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(employee == null ? 'Nuevo empleado' : 'Editar empleado'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese nombres' : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Apellidos'),
              ),
              TextFormField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Rol'),
              ),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final updated = Employee(
                  id: employee?.id ?? uuid.v4(),
                  firstName: firstNameController.text.trim(),
                  lastName: lastNameController.text.trim(),
                  email: employee?.email,
                  phone: employee?.phone,
                  role: roleController.text.trim().isEmpty
                      ? 'colaborador'
                      : roleController.text.trim(),
                  locationId: locationId,
                  locationType: locationId == null
                      ? null
                      : options
                          .firstWhere((element) => element.id == locationId)
                          .type
                          .label,
                  isActive: employee?.isActive ?? true,
                  hiredAt: employee?.hiredAt ?? DateTime.now().toUtc(),
                  createdAt: employee?.createdAt ?? DateTime.now().toUtc(),
                  updatedAt: DateTime.now().toUtc(),
                  syncedAt: employee?.syncedAt,
                );
  if (!context.mounted) {
    return;
  }
                employeesCubit.saveEmployee(updated);
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

Future<void> _confirmDeleteEmployee(
  BuildContext context,
  Employee employee,
) async {
  final confirmed = await showDialog<bool>(
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











