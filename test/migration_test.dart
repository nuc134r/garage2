import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/core/model/enums.dart';

void main() {
  test('v1 databases get the attachments table', () async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final dir = await Directory.systemTemp.createTemp('garage_migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');

    final v1 = AppDatabase(NativeDatabase(file));
    await v1.into(v1.vehicles).insert(VehiclesCompanion.insert(id: const Value('v'), name: 'Old'));
    await v1.into(v1.entries).insert(
          EntriesCompanion.insert(id: const Value('e'), vehicleId: 'v', type: EntryType.odometer, date: DateTime(2025), odometer: 1),
        );
    await v1.customStatement('DROP TABLE attachments');
    await v1.customStatement('PRAGMA user_version = 1');
    await v1.close();

    final v2 = AppDatabase(NativeDatabase(file));
    addTearDown(v2.close);
    await v2.into(v2.attachments).insert(
          AttachmentsCompanion.insert(entryId: 'e', name: 'a.jpg', mimeType: 'image/jpeg', size: 1, data: Uint8List(1)),
        );
    expect(await v2.select(v2.attachments).get(), hasLength(1));
    expect((await v2.select(v2.entries).get()).single.id, 'e');
  });
}
