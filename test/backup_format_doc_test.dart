// Keeps docs/backup in step with the code: the documented example must import as described.
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/model/enums.dart';
import 'package:garage/features/backup/data/backup_service.dart';
import 'package:garage/features/backup/domain/backup_data.dart';
import 'package:garage/features/stats/domain/stats_calculator.dart';

import 'helpers.dart';

void main() {
  test('the example in docs/backup imports', () async {
    final data = BackupData.decode(File('docs/backup/example.garage').readAsStringSync());
    final db = memoryDb();
    addTearDown(db.close);
    await BackupService(db).import(data, ImportStrategy.merge);

    final vehicle = (await db.select(db.vehicles).get()).single;
    expect(vehicle.bodyType, BodyType.sedan);
    expect(vehicle.currencyCode, 'EUR');
    final entries = await (db.select(db.entries)..orderBy([(e) => OrderingTerm.asc(e.date)])).get();
    expect(entries.map((e) => e.type), [
      EntryType.fuel,
      EntryType.fuel,
      EntryType.fuel,
      EntryType.service,
      EntryType.expense,
      EntryType.odometer,
    ]);
    // References survive the import, and the integer volume reads as a double.
    expect(entries.every((e) => e.type != EntryType.fuel || e.fuelTypeId != null), isTrue);
    expect(entries[1].volume, 20.0);
    expect(entries[4].expenseCategoryId, isNotNull);
    expect(fillEfficiencies(entries, vehicle).values.single, closeTo((20 + 30.1) / 670 * 100, 1e-9));
    expect(await db.select(db.reminderResets).get(), hasLength(1));
    expect(await db.select(db.places).get(), hasLength(2));
  });
}
