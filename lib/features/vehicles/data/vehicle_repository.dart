import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';

class VehicleSummary {
  const VehicleSummary({required this.entryCount, required this.lastOdometer});

  final int entryCount;
  final int? lastOdometer;
}

class VehicleRepository {
  VehicleRepository(this._db);

  final AppDatabase _db;

  Stream<List<Vehicle>> watchAll({bool includeArchived = false}) {
    final q = _db.select(_db.vehicles)
      ..orderBy([(v) => OrderingTerm.asc(v.sortOrder), (v) => OrderingTerm.asc(v.createdAt)]);
    if (!includeArchived) q.where((v) => v.archived.equals(false));
    return q.watch();
  }

  Stream<Vehicle?> watch(String id) =>
      (_db.select(_db.vehicles)..where((v) => v.id.equals(id))).watchSingleOrNull();

  Future<Vehicle?> get(String id) => (_db.select(_db.vehicles)..where((v) => v.id.equals(id))).getSingleOrNull();

  Stream<Map<String, VehicleSummary>> watchSummaries() {
    final count = _db.entries.id.count();
    final maxOdo = _db.entries.odometer.max();
    final q = _db.selectOnly(_db.entries)
      ..addColumns([_db.entries.vehicleId, count, maxOdo])
      ..groupBy([_db.entries.vehicleId]);
    return q.watch().map((rows) => {
          for (final r in rows)
            r.read(_db.entries.vehicleId)!: VehicleSummary(entryCount: r.read(count) ?? 0, lastOdometer: r.read(maxOdo)),
        });
  }

  /// Inserts a new vehicle at the end of the list and returns its id.
  Future<String> create(VehiclesCompanion data) async {
    final maxOrder = _db.vehicles.sortOrder.max();
    final last = await (_db.selectOnly(_db.vehicles)..addColumns([maxOrder])).map((r) => r.read(maxOrder)).getSingle();
    final id = data.id.present ? data.id.value : newId();
    await _db.into(_db.vehicles).insert(data.copyWith(id: Value(id), sortOrder: Value((last ?? -1) + 1)));
    return id;
  }

  Future<void> update(String id, VehiclesCompanion data) =>
      (_db.update(_db.vehicles)..where((v) => v.id.equals(id))).write(data.copyWith(updatedAt: Value(DateTime.now())));

  Future<void> setArchived(String id, bool archived) => update(id, VehiclesCompanion(archived: Value(archived)));

  Future<void> reorder(List<String> ids) => _db.transaction(() async {
        for (var i = 0; i < ids.length; i++) {
          await update(ids[i], VehiclesCompanion(sortOrder: Value(i)));
        }
      });

  Future<void> delete(String id) => (_db.delete(_db.vehicles)..where((v) => v.id.equals(id))).go();
}

final vehicleRepositoryProvider = Provider((ref) => VehicleRepository(ref.watch(appDatabaseProvider)));

/// Active (not archived) vehicles in display order.
final vehiclesProvider = StreamProvider<List<Vehicle>>((ref) => ref.watch(vehicleRepositoryProvider).watchAll());

final allVehiclesProvider =
    StreamProvider<List<Vehicle>>((ref) => ref.watch(vehicleRepositoryProvider).watchAll(includeArchived: true));

final vehicleProvider =
    StreamProvider.family<Vehicle?, String>((ref, id) => ref.watch(vehicleRepositoryProvider).watch(id));

final vehicleSummariesProvider =
    StreamProvider<Map<String, VehicleSummary>>((ref) => ref.watch(vehicleRepositoryProvider).watchSummaries());
