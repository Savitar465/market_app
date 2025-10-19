import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/employee.dart';

class EmployeeModel extends Equatable {
  const EmployeeModel({
    required this.id,
    required this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.authUserId,
    required this.role,
    this.locationId,
    this.locationType,
    this.isActive = true,
    this.hiredAt,
    this.createdAt,
    this.updatedAt,
    this.syncedAt,
  });

  final String id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? authUserId;
  final String role;
  final String? locationId;
  final String? locationType;
  final bool isActive;
  final DateTime? hiredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? syncedAt;

  Employee toEntity() {
    return Employee(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      authUserId: authUserId,
      role: role,
      locationId: locationId,
      locationType: locationType,
      isActive: isActive,
      hiredAt: hiredAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncedAt: syncedAt,
    );
  }

  EmployeesTableCompanion toCompanion() {
    return EmployeesTableCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      email: Value(email),
      phone: Value(phone),
      authUserId: Value(authUserId),
      role: Value(role),
      locationId: Value(locationId),
      locationType: Value(locationType),
      isActive: Value(isActive),
      hiredAt: Value(hiredAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncedAt: Value(syncedAt),
    );
  }

  factory EmployeeModel.fromTable(EmployeesTableData data) {
    return EmployeeModel(
      id: data.id,
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      phone: data.phone,
      authUserId: data.authUserId,
      role: data.role,
      locationId: data.locationId,
      locationType: data.locationType,
      isActive: data.isActive,
      hiredAt: data.hiredAt,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      syncedAt: data.syncedAt,
    );
  }

  factory EmployeeModel.fromEntity(Employee entity) {
    return EmployeeModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phone: entity.phone,
      authUserId: entity.authUserId,
      role: entity.role,
      locationId: entity.locationId,
      locationType: entity.locationType,
      isActive: entity.isActive,
      hiredAt: entity.hiredAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      syncedAt: entity.syncedAt,
    );
  }

  EmployeeModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? authUserId,
    String? role,
    String? locationId,
    String? locationType,
    bool? isActive,
    DateTime? hiredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      authUserId: authUserId ?? this.authUserId,
      role: role ?? this.role,
      locationId: locationId ?? this.locationId,
      locationType: locationType ?? this.locationType,
      isActive: isActive ?? this.isActive,
      hiredAt: hiredAt ?? this.hiredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    phone,
    authUserId,
    role,
    locationId,
    locationType,
    isActive,
    hiredAt,
    createdAt,
    updatedAt,
    syncedAt,
  ];
}
