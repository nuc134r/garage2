import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/enums.dart';
import 'tables.dart';

export 'tables.dart' show newId, SyncedTable;

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
    Entries,
    Attachments,
    Reminders,
    ReminderResets,
    FuelTypes,
    Places,
    ExpenseCategories,
    Tombstones,
    AppSettings,
    RestorePoints,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.defaults()
      : super(
          driftDatabase(
            name: 'garage',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.base.resolve('sqlite3.wasm'),
              driftWorker: Uri.base.resolve('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(attachments);
            await m.createIndex(attachmentsEntry);
          }
          if (from < 3) {
            await m.addColumn(reminders, reminders.lastDoneDate);
            await m.addColumn(reminders, reminders.lastDoneOdometer);
          }
          if (from < 4) await m.createTable(tombstones);
          if (from < 5) await m.addColumn(vehicles, vehicles.bodyType);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

extension SyncedDelete on AppDatabase {
  /// Tables whose rows are tracked by id for backup merging, by SQL name.
  Map<String, TableInfo<Table, DataClass>> get syncedTables => {
        for (final t in <TableInfo<Table, DataClass>>[vehicles, entries, attachments, reminders, fuelTypes, places, expenseCategories])
          t.actualTableName: t,
      };

  /// Deletes a synced row and leaves a tombstone, so merging this device's backup elsewhere deletes it too.
  /// Rows removed by a cascade need none: deleting their parent there cascades the same way.
  Future<void> deleteSynced(TableInfo<Table, DataClass> table, String id) => transaction(() async {
        await into(tombstones).insertOnConflictUpdate(
          TombstonesCompanion.insert(rowId: id, sourceTable: table.actualTableName, deletedAt: clock.now()),
        );
        await (delete(table)..where((t) => (t as SyncedTable).id.equals(id))).go();
      });
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
});
