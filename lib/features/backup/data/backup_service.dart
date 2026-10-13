import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/backup_data.dart';

class BackupService {
  BackupService(this._db, {this.appVersion});

  static const maxRestorePoints = 10;

  final AppDatabase _db;
  final String? appVersion;

  /// Attachments go into full backups only, and never into restore points (they would multiply their size).
  Future<BackupData> export(BackupMode mode, {bool? attachments}) async {
    final withAttachments = attachments ?? mode == BackupMode.full;
    return _db.transaction(() async {
      final settings = mode == BackupMode.full
          ? {
              for (final s in await _db.select(_db.appSettings).get())
                if (SettingKeys.portable.contains(s.key)) s.key: s.value,
            }
          : <String, String>{};
      return BackupData(
        mode: mode,
        exportedAt: DateTime.now(),
        appVersion: appVersion,
        vehicles: await _db.select(_db.vehicles).get(),
        entries: await _db.select(_db.entries).get(),
        reminders: await _db.select(_db.reminders).get(),
        reminderResets: await _db.select(_db.reminderResets).get(),
        fuelTypes: await _db.select(_db.fuelTypes).get(),
        places: await _db.select(_db.places).get(),
        expenseCategories: await _db.select(_db.expenseCategories).get(),
        settings: settings,
        attachments: withAttachments ? await _db.select(_db.attachments).get() : const [],
        tombstones: await _db.select(_db.tombstones).get(),
        attachmentsIncluded: withAttachments,
      );
    });
  }

  /// Applies [data]. Merge upserts by id and keeps whichever row was updated last, and applies
  /// the file's deletions to rows not edited since, so importing the same file twice changes nothing.
  /// Replace wipes all data first.
  Future<void> import(BackupData data, ImportStrategy strategy) {
    return _db.transaction(() async {
      // Attachments of a file without them survive a replace if their entry comes back.
      final kept = strategy == ImportStrategy.replace && !data.attachmentsIncluded
          ? await _db.select(_db.attachments).get()
          : const <Attachment>[];
      if (strategy == ImportStrategy.replace) {
        await _db.delete(_db.attachments).go();
        await _db.delete(_db.reminderResets).go();
        await _db.delete(_db.entries).go();
        await _db.delete(_db.reminders).go();
        await _db.delete(_db.vehicles).go();
        await _db.delete(_db.places).go();
        await _db.delete(_db.fuelTypes).go();
        await _db.delete(_db.expenseCategories).go();
        await _db.delete(_db.tombstones).go();
      }

      // Deletions known here and in the file; a row is only brought back if edited after its deletion.
      final deleted = {for (final t in await _db.select(_db.tombstones).get()) t.rowId: t};
      for (final t in data.tombstones) {
        final known = deleted[t.rowId];
        if (known == null || t.deletedAt.isAfter(known.deletedAt)) {
          deleted[t.rowId] = t;
          await _db.into(_db.tombstones).insertOnConflictUpdate(t);
        }
      }
      bool alive(String id, DateTime updatedAt) => deleted[id] == null || updatedAt.isAfter(deleted[id]!.deletedAt);

      await _upsert(_db.fuelTypes, data.fuelTypes, (r) => r.id, (r) => r.updatedAt, alive);
      await _upsert(_db.places, data.places, (r) => r.id, (r) => r.updatedAt, alive);
      await _upsert(_db.expenseCategories, data.expenseCategories, (r) => r.id, (r) => r.updatedAt, alive);
      await _upsert(_db.vehicles, data.vehicles, (r) => r.id, (r) => r.updatedAt, alive);
      await _applyDeletions(data.tombstones);

      // Children of rows that are gone (deleted here, or missing from a partial file) are skipped,
      // and references to deleted list items are cleared, as the database does locally.
      final vehicleIds = await _ids(_db.vehicles);
      final dictIds = {...await _ids(_db.fuelTypes), ...await _ids(_db.places), ...await _ids(_db.expenseCategories)};
      String? ref(String? id) => id != null && dictIds.contains(id) ? id : null;
      final entries = [
        for (final e in data.entries)
          if (vehicleIds.contains(e.vehicleId))
            e.copyWith(
              fuelTypeId: Value(ref(e.fuelTypeId)),
              placeId: Value(ref(e.placeId)),
              expenseCategoryId: Value(ref(e.expenseCategoryId)),
            ),
      ];
      final writtenEntries = await _upsert(_db.entries, entries, (r) => r.id, (r) => r.updatedAt, alive);
      await _upsert(
        _db.reminders,
        [for (final r in data.reminders) if (vehicleIds.contains(r.vehicleId)) r],
        (r) => r.id,
        (r) => r.updatedAt,
        alive,
      );
      await _applyDeletions(data.tombstones);

      final entryIds = await _ids(_db.entries);
      final reminderIds = await _ids(_db.reminders);
      await _upsert(
        _db.attachments,
        [for (final a in data.attachments) if (entryIds.contains(a.entryId)) a],
        (r) => r.id,
        (r) => r.updatedAt,
        alive,
      );
      for (final a in kept.where((a) => entryIds.contains(a.entryId))) {
        await _db.into(_db.attachments).insert(a, mode: InsertMode.insertOrIgnore);
      }

      // An entry taken from the file brings its reminder resets along, replacing the local ones.
      for (final id in writtenEntries) {
        await (_db.delete(_db.reminderResets)..where((r) => r.entryId.equals(id))).go();
      }
      for (final r in data.reminderResets) {
        if (!entryIds.contains(r.entryId) || !reminderIds.contains(r.reminderId)) continue;
        await _db.into(_db.reminderResets).insert(r, mode: InsertMode.insertOrIgnore);
      }
      for (final s in data.settings.entries) {
        if (!SettingKeys.portable.contains(s.key)) continue;
        await _db.into(_db.appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: s.key, value: s.value));
      }
    });
  }

  /// Ids of all rows of a synced table.
  Future<Set<String>> _ids(TableInfo<Table, DataClass> table) async {
    final id = (table as SyncedTable).id;
    return {for (final r in await (_db.selectOnly(table)..addColumns([id])).get()) r.read(id)!};
  }

  /// Deletes rows named by [tombstones] unless they were edited after the deletion.
  Future<void> _applyDeletions(List<Tombstone> tombstones) async {
    final tables = _db.syncedTables;
    for (final t in tombstones) {
      final table = tables[t.sourceTable];
      if (table == null) continue;
      final synced = table as SyncedTable;
      final row = await (_db.selectOnly(table)
            ..addColumns([synced.updatedAt])
            ..where(synced.id.equals(t.rowId)))
          .getSingleOrNull();
      // Compared in Dart: stored timestamps may differ in time zone notation.
      final updatedAt = row?.read(synced.updatedAt);
      if (updatedAt == null || updatedAt.isAfter(t.deletedAt)) continue;
      await (_db.delete(table)..where((_) => synced.id.equals(t.rowId))).go();
    }
  }

  /// Writes rows that are new or newer than the local version; returns the ids written.
  Future<Set<String>> _upsert<T extends Table, R extends DataClass>(
    TableInfo<T, R> table,
    List<R> rows,
    String Function(R) id,
    DateTime Function(R) updatedAt,
    bool Function(String id, DateTime updatedAt) alive,
  ) async {
    final written = <String>{};
    if (rows.isEmpty) return written;
    final synced = table as SyncedTable;
    final q = _db.selectOnly(table)..addColumns([synced.id, synced.updatedAt]);
    final existing = {for (final r in await q.get()) r.read(synced.id)!: r.read(synced.updatedAt)!};
    for (final row in rows) {
      final current = existing[id(row)];
      if (!alive(id(row), updatedAt(row))) continue;
      if (current == null || updatedAt(row).isAfter(current)) {
        await _db.into(table).insertOnConflictUpdate(row as Insertable<R>);
        written.add(id(row));
      }
    }
    return written;
  }

  Future<void> deleteAllData() => import(BackupData(mode: BackupMode.quick, exportedAt: DateTime.now()), ImportStrategy.replace);

  // Restore points: full snapshots kept inside the database, so they work on web too.

  Stream<List<RestorePoint>> watchRestorePoints() =>
      (_db.select(_db.restorePoints)..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).watch();

  Future<void> createRestorePoint(String reason) async {
    final data = await export(BackupMode.full, attachments: false);
    if (data.vehicles.isEmpty) return;
    await _db.into(_db.restorePoints).insert(RestorePointsCompanion.insert(reason: reason, data: data.encode()));
    await _db.into(_db.appSettings).insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: SettingKeys.lastRestorePointAt, value: DateTime.now().toIso8601String()),
        );
    final all = await (_db.select(_db.restorePoints)..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).get();
    for (final old in all.skip(maxRestorePoints)) {
      await (_db.delete(_db.restorePoints)..where((r) => r.id.equals(old.id))).go();
    }
  }

  /// Creates a daily restore point if enabled and the last one is older than a day.
  Future<void> createDailyRestorePointIfDue(AppSettingsState settings) async {
    if (!settings.restorePointsEnabled) return;
    final last = settings.lastRestorePointAt;
    if (last != null && DateTime.now().difference(last) < const Duration(days: 1)) return;
    await createRestorePoint('daily');
  }

  BackupData readRestorePoint(RestorePoint point) => BackupData.decode(point.data);

  Future<void> deleteRestorePoint(String id) => (_db.delete(_db.restorePoints)..where((r) => r.id.equals(id))).go();
}

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version}+${info.buildNumber}';
});

final backupServiceProvider = Provider((ref) {
  final version = ref.watch(appVersionProvider).value;
  return BackupService(ref.watch(appDatabaseProvider), appVersion: version);
});

final restorePointsProvider =
    StreamProvider<List<RestorePoint>>((ref) => ref.watch(backupServiceProvider).watchRestorePoints());
