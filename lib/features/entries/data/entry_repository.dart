import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../stats/domain/stats_calculator.dart';

class EntryRepository {
  EntryRepository(this._db);

  final AppDatabase _db;

  Stream<List<Entry>> watchForVehicle(String vehicleId) =>
      (_db.select(_db.entries)..where((e) => e.vehicleId.equals(vehicleId))).watch().map(sortEntries);

  Future<Entry?> get(String id) => (_db.select(_db.entries)..where((e) => e.id.equals(id))).getSingleOrNull();

  Stream<List<ReminderReset>> watchResetsForVehicle(String vehicleId) {
    final q = _db.select(_db.reminderResets).join([
      innerJoin(_db.entries, _db.entries.id.equalsExp(_db.reminderResets.entryId)),
    ])
      ..where(_db.entries.vehicleId.equals(vehicleId));
    return q.watch().map((rows) => rows.map((r) => r.readTable(_db.reminderResets)).toList());
  }

  /// Inserts or updates an entry; [resetReminderIds] replaces its reminder resets when given.
  Future<String> save(EntriesCompanion data, {Set<String>? resetReminderIds}) {
    return _db.transaction(() async {
      final id = data.id.present ? data.id.value : newId();
      final row = data.copyWith(id: Value(id), updatedAt: Value(DateTime.now()));
      final exists = await get(id) != null;
      if (exists) {
        await (_db.update(_db.entries)..where((e) => e.id.equals(id))).write(row);
      } else {
        await _db.into(_db.entries).insert(row);
      }
      if (resetReminderIds != null) {
        await (_db.delete(_db.reminderResets)..where((r) => r.entryId.equals(id))).go();
        for (final reminderId in resetReminderIds) {
          await _db.into(_db.reminderResets).insert(ReminderResetsCompanion.insert(entryId: id, reminderId: reminderId));
        }
      }
      return id;
    });
  }

  Future<void> delete(String id) => (_db.delete(_db.entries)..where((e) => e.id.equals(id))).go();
}

final entryRepositoryProvider = Provider((ref) => EntryRepository(ref.watch(appDatabaseProvider)));

/// Entries of a vehicle sorted chronologically (oldest first).
final entriesProvider = StreamProvider.autoDispose
    .family<List<Entry>, String>((ref, vehicleId) => ref.watch(entryRepositoryProvider).watchForVehicle(vehicleId));

final reminderResetsProvider = StreamProvider.autoDispose.family<List<ReminderReset>, String>(
    (ref, vehicleId) => ref.watch(entryRepositoryProvider).watchResetsForVehicle(vehicleId));
