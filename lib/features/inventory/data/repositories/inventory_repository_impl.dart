import 'package:market_app/features/inventory/domain/entities/employee.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_location.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_report.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_stock.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_transaction.dart';

import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local/inventory_local_data_source.dart';
import '../datasources/remote/inventory_remote_data_source.dart';
import '../models/employee_model.dart';
import '../models/inventory_location_model.dart';
import '../models/inventory_transaction_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({
    required InventoryLocalDataSource localDataSource,
    InventoryRemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final InventoryLocalDataSource _localDataSource;
  final InventoryRemoteDataSource? _remoteDataSource;

  @override
  Stream<List<InventoryLocation>> watchLocations(InventoryLocationType type) {
    return _localDataSource
        .watchLocations(type.label)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> saveLocation(InventoryLocation location) async {
    final model = InventoryLocationModel.fromEntity(location);
    await _localDataSource.upsertLocation(model);
    // Best-effort remote save
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource.upsertLocation(model);
        await _localDataSource.markLocationSynced(model.id, DateTime.now().toUtc());
      } catch (_) {
        // ignore network errors; will be retried by syncPendingChanges
      }
    }
  }

  @override
  Future<void> deleteLocation(String locationId) async {
    await _localDataSource.deleteLocation(locationId);
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource.deleteLocation(locationId);
      } catch (_) {
        // ignore – delete will reconcile on next full sync/prune
      }
    }
  }

  @override
  Stream<List<Employee>> watchEmployees({String? locationId}) {
    return _localDataSource
        .watchEmployees(locationId: locationId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> saveEmployee(Employee employee) async {
    final model = EmployeeModel.fromEntity(employee);
    await _localDataSource.upsertEmployee(model);
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource.upsertEmployee(model);
        await _localDataSource.markEmployeeSynced(model.id, DateTime.now().toUtc());
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteEmployee(String employeeId) async {
    await _localDataSource.deleteEmployee(employeeId);
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource.deleteEmployee(employeeId);
      } catch (_) {}
    }
  }

  @override
  Stream<List<InventoryStock>> watchInventory({
    String? locationId,
    InventoryLocationType? locationType,
  }) {
    return _localDataSource
        .watchInventory(
          locationId: locationId,
          locationType: locationType?.label,
        )
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<List<InventoryStock>> fetchGlobalInventory() async {
    final models = await _localDataSource.fetchGlobalInventory();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<InventoryStock?> getStockForProduct({
    required String productId,
    required String locationId,
  }) async {
    final model =
        await _localDataSource.getStock(productId: productId, locationId: locationId);
    return model?.toEntity();
  }

  @override
  Future<void> recordPurchase(Purchase purchase) async {
    final model = PurchaseModel.fromEntity(purchase);
    await _localDataSource.recordPurchase(model);
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource.savePurchase(model);
        await _localDataSource.markPurchaseSynced(model.id, DateTime.now().toUtc());
      } catch (_) {}
    }
  }

  @override
  Future<void> recordSale(Sale sale) async {
    final model = SaleModel.fromEntity(sale);
    await _localDataSource.recordSale(model);
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource.saveSale(model);
        await _localDataSource.markSaleSynced(model.id, DateTime.now().toUtc());
      } catch (_) {}
    }
  }

  @override
  Future<void> recordTransfer(InventoryTransfer transfer) async {
    final model = TransferModel.fromEntity(transfer);
    await _localDataSource.recordTransfer(model);
    if (_remoteDataSource != null) {
      try {
        await _remoteDataSource.saveTransfer(model);
        await _localDataSource.markTransferSynced(model.id, DateTime.now().toUtc());
      } catch (_) {}
    }
  }

  @override
  Stream<List<SalesReportEntry>> watchSalesReport({
    String? storeId,
    DateRange? range,
  }) {
    return _localDataSource
        .watchSalesReport(
          storeId: storeId,
          start: range?.start,
          end: range?.end,
        )
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }

  @override
  Stream<List<PurchaseReportEntry>> watchPurchaseReport({
    String? locationId,
    DateRange? range,
  }) {
    return _localDataSource
        .watchPurchaseReport(
          locationId: locationId,
          start: range?.start,
          end: range?.end,
        )
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }

  @override
  Stream<List<TransferReportEntry>> watchTransferReport({
    String? originId,
    String? destinationId,
    DateRange? range,
  }) {
    return _localDataSource
        .watchTransferReport(
          originId: originId,
          destinationId: destinationId,
          start: range?.start,
          end: range?.end,
        )
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }

  @override
  Stream<DailySalesSummary> watchDailySalesSummary(DateTime date) {
    return _localDataSource
        .watchDailySalesSummary(date)
        .map((model) => model.toEntity());
  }

  @override
  Future<double> fetchTodayGlobalSalesTotal() {
    return _localDataSource.fetchTodayGlobalSalesTotal();
  }

  @override
  Stream<List<InventoryMovement>> watchMovements({
    String? productId,
    String? locationId,
  }) {
    return _localDataSource
        .watchMovements(productId: productId, locationId: locationId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> syncPendingChanges() async {
    if (_remoteDataSource == null) return;

    // Locations
    final unsyncedLocations = await _localDataSource.fetchUnsyncedLocationsForSync();
    for (final loc in unsyncedLocations) {
      try {
        await _remoteDataSource.upsertLocation(loc);
        await _localDataSource.markLocationSynced(loc.id, DateTime.now().toUtc());
      } catch (_) {}
    }

    // Employees
    final unsyncedEmployees = await _localDataSource.fetchUnsyncedEmployeesForSync();
    for (final emp in unsyncedEmployees) {
      try {
        await _remoteDataSource.upsertEmployee(emp);
        await _localDataSource.markEmployeeSynced(emp.id, DateTime.now().toUtc());
      } catch (error) {
        print(error);
      }
    }

    // Purchases
    final unsyncedPurchases = await _localDataSource.fetchUnsyncedPurchasesForSync();
    for (final p in unsyncedPurchases) {
      try {
        await _remoteDataSource.savePurchase(p);
        await _localDataSource.markPurchaseSynced(p.id, DateTime.now().toUtc());
      } catch (error) {
        print(error);
      }
    }

    // // Sales
    // final unsyncedSales = await _localDataSource.fetchUnsyncedSalesForSync();
    // for (final s in unsyncedSales) {
    //   try {
    //     await _remoteDataSource.saveSale(s);
    //     await _localDataSource.markSaleSynced(s.id, DateTime.now().toUtc());
    //   } catch (_) {}
    // }
    //
    // // Transfers
    // final unsyncedTransfers = await _localDataSource.fetchUnsyncedTransfersForSync();
    // for (final t in unsyncedTransfers) {
    //   try {
    //     await _remoteDataSource.saveTransfer(t);
    //     await _localDataSource.markTransferSynced(t.id, DateTime.now().toUtc());
    //   } catch (_) {}
    // }
  }
}

