import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../entries/data/entry_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/reminder_status.dart';

class ReminderRepository {
  ReminderRepository(this._db);

  final AppDatabase _db;

  Stream<List<Reminder>> watchForVehicle(String vehicleId) => (_db.select(_db.reminders)
        ..where((r) => r.vehicleId.equals(vehicleId) & r.archived.equals(false))
        ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
      .watch();

  Future<String> save(RemindersCompanion data) async {
    final id = data.id.present ? data.id.value : newId();
    await _db.into(_db.reminders).insertOnConflictUpdate(data.copyWith(id: Value(id), updatedAt: Value(clock.now())));
    return id;
  }

  Future<void> delete(String id) => _db.deleteSynced(_db.reminders, id);
}

final reminderRepositoryProvider = Provider((ref) => ReminderRepository(ref.watch(appDatabaseProvider)));

final remindersProvider = StreamProvider.autoDispose
    .family<List<Reminder>, String>((ref, vehicleId) => ref.watch(reminderRepositoryProvider).watchForVehicle(vehicleId));

/// Reminder statuses of a vehicle, most urgent first.
final reminderStatusesProvider =
    FutureProvider.autoDispose.family<List<ReminderStatus>, String>((ref, vehicleId) async {
  final vehicle = await ref.watch(vehicleProvider(vehicleId).future);
  if (vehicle == null) return const [];
  final list = await ref.watch(remindersProvider(vehicleId).future);
  final entries = await ref.watch(entriesProvider(vehicleId).future);
  final resets = await ref.watch(reminderResetsProvider(vehicleId).future);
  final statuses = [
    for (final r in list)
      computeReminderStatus(reminder: r, vehicle: vehicle, entries: entries, resets: resets),
  ]..sort((a, b) {
      // Soonest first in time; reminders without a time estimate after those with one.
      final da = a.dueInDays, db = b.dueInDays;
      if (da != null && db != null && da != db) return da.compareTo(db);
      if ((da == null) != (db == null)) return da == null ? 1 : -1;
      return a.minFraction.compareTo(b.minFraction);
    });
  return statuses;
});
