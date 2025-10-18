import 'package:market_app/features/inventory/domain/entities/employee.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_location.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_report.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_stock.dart';
import 'package:market_app/features/inventory/domain/entities/inventory_transaction.dart';

import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local/inventory_local_data_source.dart';
import '../models/employee_model.dart';
import '../models/inventory_location_model.dart';
import '../models/inventory_transaction_model.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({required InventoryLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final InventoryLocalDataSource _localDataSource;

  @override
  Stream<List<InventoryLocation>> watchLocations(InventoryLocationType type) {
    return _localDataSource
        .watchLocations(type.label)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> saveLocation(InventoryLocation location) {
    final model = InventoryLocationModel.fromEntity(location);
    return _localDataSource.upsertLocation(model);
  }

  @override
  Future<void> deleteLocation(String locationId) {
    return _localDataSource.deleteLocation(locationId);
  }

  @override
  Stream<List<Employee>> watchEmployees({String? locationId}) {
    return _localDataSource
        .watchEmployees(locationId: locationId)
        .map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<void> saveEmployee(Employee employee) {
    final model = EmployeeModel.fromEntity(employee);
    return _localDataSource.upsertEmployee(model);
  }

  @override
  Future<void> deleteEmployee(String employeeId) {
    return _localDataSource.deleteEmployee(employeeId);
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
  Future<void> recordPurchase(Purchase purchase) {
    final model = PurchaseModel.fromEntity(purchase);
    return _localDataSource.recordPurchase(model);
  }

  @override
  Future<void> recordSale(Sale sale) {
    final model = SaleModel.fromEntity(sale);
    return _localDataSource.recordSale(model);
  }

  @override
  Future<void> recordTransfer(InventoryTransfer transfer) {
    final model = TransferModel.fromEntity(transfer);
    return _localDataSource.recordTransfer(model);
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
}

