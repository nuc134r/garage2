import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/enums.dart';
import 'tables.dart';

export 'tables.dart' show newId;

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
  int get schemaVersion => 3;

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
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.defaults();
  ref.onDispose(db.close);
  return db;
});
