import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/core/model/enums.dart';
import 'package:garage/features/backup/data/backup_service.dart';
import 'package:garage/features/backup/domain/backup_data.dart';
import 'package:garage/features/dictionaries/data/dictionary_repository.dart';
import 'package:garage/features/entries/data/attachment_repository.dart';
import 'package:garage/features/entries/data/entry_repository.dart';
import 'package:garage/features/reminders/data/reminder_repository.dart';
import 'package:garage/features/settings/data/settings_repository.dart';
import 'package:garage/features/vehicles/data/vehicle_repository.dart';

import 'helpers.dart';

Future<void> seed(AppDatabase db) async {
  final vehicles = VehicleRepository(db);
  final entries = EntryRepository(db);
  final reminders = ReminderRepository(db);
  final dict = DictionaryRepository(db);
  await SettingsRepository(db).set(SettingKeys.themeMode, 'light');
  await SettingsRepository(db).set(SettingKeys.lastVehicleId, 'device-specific');

  final v1 = await vehicles.create(VehiclesCompanion.insert(name: 'Aveo', currencyCode: const Value('RUB')));
  final v2 = await vehicles.create(VehiclesCompanion.insert(name: 'i30 N', distanceUnit: const Value(DistanceUnit.mi)));
  final station = await dict.add(DictionaryKind.fuelStation, 'Shell');
  final fuelType = await dict.add(DictionaryKind.fuelType, 'AI-95');
  final oil = await reminders.save(RemindersCompanion.insert(vehicleId: v1, name: 'Oil', intervalDistance: const Value(7500)));

  await entries.save(EntriesCompanion.insert(
    vehicleId: v1,
    type: EntryType.fuel,
    date: DateTime(2025, 1, 1, 10, 30, 15, 123),
    odometer: 1000,
    totalCost: const Value(240050),
    volume: const Value(40.5),
    placeId: Value(station),
    fuelTypeId: Value(fuelType),
  ));
  await entries.save(
    EntriesCompanion.insert(
      vehicleId: v1,
      type: EntryType.service,
      date: DateTime(2025, 2, 1),
      odometer: 1500,
      note: const Value('Oil change\nmultiline ✓'),
    ),
    resetReminderIds: {oil},
  );
  final odo = await entries.save(EntriesCompanion.insert(vehicleId: v2, type: EntryType.odometer, date: DateTime(2025, 3, 1), odometer: 42));
  await AttachmentRepository(db).add(
    entryId: odo,
    name: 'bill.pdf',
    mimeType: 'application/pdf',
    data: Uint8List.fromList(List.generate(1000, (i) => i % 256)),
  );
}

void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUp(() async {
    source = memoryDb();
    target = memoryDb();
    await seed(source);
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  test('round-trips through the file format into an empty database', () async {
    final exported = await BackupService(source).export(BackupMode.full);
    final decoded = BackupData.decodeBytes(exported.encodeBytes());

    expect(decoded.mode, BackupMode.full);
    expect(decoded.vehicles.length, 2);
    expect(decoded.settings, {SettingKeys.themeMode: 'light'}, reason: 'device-specific settings are not exported');

    await BackupService(target).import(decoded, ImportStrategy.replace);
    final again = await BackupService(target).export(BackupMode.full);

    expect(again.vehicles, unorderedEquals(exported.vehicles));
    expect(again.entries, unorderedEquals(exported.entries));
    expect(again.reminders, unorderedEquals(exported.reminders));
    expect(again.reminderResets, unorderedEquals(exported.reminderResets));
    expect(again.places, unorderedEquals(exported.places));
    expect(again.fuelTypes, unorderedEquals(exported.fuelTypes));
    expect(again.settings, exported.settings);
  });

  test('quick backup has no settings', () async {
    final data = await BackupService(source).export(BackupMode.quick);
    expect(data.toJson().containsKey('settings'), isFalse);
  });

  test('merging the same file twice creates no duplicates', () async {
    final data = await BackupService(source).export(BackupMode.quick);
    final service = BackupService(target);
    await service.import(data, ImportStrategy.merge);
    await service.import(data, ImportStrategy.merge);
    final result = await service.export(BackupMode.quick);
    expect(result.vehicles.length, 2);
    expect(result.entries.length, 3);
    expect(result.reminderResets.length, 1);
  });

  test('merge keeps the newer version of a row', () async {
    final data = await BackupService(source).export(BackupMode.quick);
    final service = BackupService(target);
    await service.import(data, ImportStrategy.merge);

    final vehicleId = data.vehicles.first.id;
    await VehicleRepository(target).update(vehicleId, const VehiclesCompanion(name: Value('Renamed locally')));
    await service.import(data, ImportStrategy.merge); // older copy must not win
    expect((await VehicleRepository(target).get(vehicleId))!.name, 'Renamed locally');

    final newer = data.vehicles.first.copyWith(name: 'Renamed remotely', updatedAt: DateTime.now().add(const Duration(hours: 1)));
    await service.import(
      BackupData(mode: BackupMode.quick, exportedAt: DateTime.now(), vehicles: [newer]),
      ImportStrategy.merge,
    );
    expect((await VehicleRepository(target).get(vehicleId))!.name, 'Renamed remotely');
  });

  test('replace removes local data not in the file', () async {
    await VehicleRepository(target).create(VehiclesCompanion.insert(name: 'Local only'));
    final data = await BackupService(source).export(BackupMode.quick);
    await BackupService(target).import(data, ImportStrategy.replace);
    final names = (await BackupService(target).export(BackupMode.quick)).vehicles.map((v) => v.name);
    expect(names, unorderedEquals(['Aveo', 'i30 N']));
  });

  test('rejects foreign files', () {
    expect(() => BackupData.decode('{"hello": 1}'), throwsA(isA<BackupFormatException>()));
    expect(() => BackupData.decode('not json'), throwsA(isA<BackupFormatException>()));
    expect(
      () => BackupData.decode('{"format": "garage-backup", "schema": 99}'),
      throwsA(isA<BackupFormatException>()),
    );
  });

  test('restore points are capped', () async {
    final service = BackupService(source);
    for (var i = 0; i < BackupService.maxRestorePoints + 3; i++) {
      await service.createRestorePoint('test');
    }
    final points = await service.watchRestorePoints().first;
    expect(points.length, BackupService.maxRestorePoints);
    expect(service.readRestorePoint(points.first).vehicles.length, 2);
  });

  test('deleting a vehicle cascades to its entries and reminders', () async {
    final data = await BackupService(source).export(BackupMode.quick);
    final aveo = data.vehicles.firstWhere((v) => v.name == 'Aveo');
    await VehicleRepository(source).delete(aveo.id);
    final after = await BackupService(source).export(BackupMode.quick);
    expect(after.entries.length, 1);
    expect(after.reminders, isEmpty);
    expect(after.reminderResets, isEmpty);
  });

  test('full backups carry attachments as base64, quick ones do not', () async {
    final full = await BackupService(source).export(BackupMode.full);
    final json = full.encode();
    expect(json, contains('"data":"AAECAwQF'));
    final decoded = BackupData.decode(json);
    expect(decoded.attachmentsIncluded, isTrue);
    expect(decoded.attachments.single.data, full.attachments.single.data);
    expect(decoded.attachments.single.size, 1000);

    await BackupService(target).import(decoded, ImportStrategy.replace);
    final again = await BackupService(target).export(BackupMode.full);
    expect(again.attachments, unorderedEquals(full.attachments));

    final quick = BackupData.decode((await BackupService(source).export(BackupMode.quick)).encode());
    expect(quick.attachmentsIncluded, isFalse);
    expect(quick.attachments, isEmpty);
  });

  test('restoring a file without attachments keeps the existing ones', () async {
    final service = BackupService(source);
    await service.createRestorePoint('test');
    final point = (await service.watchRestorePoints().first).single;
    expect(point.data, isNot(contains('attachments')), reason: 'restore points stay small');

    await service.import(service.readRestorePoint(point), ImportStrategy.replace);
    expect(await source.select(source.attachments).get(), hasLength(1));

    await service.deleteAllData();
    expect(await source.select(source.attachments).get(), isEmpty);
  });

  test('attachment counts and metadata do not need the content', () async {
    final repo = AttachmentRepository(source);
    final odo = (await source.select(source.entries).get()).firstWhere((e) => e.type == EntryType.odometer);
    expect(await repo.watchCountsForVehicle(odo.vehicleId).first, {odo.id: 1});
    final info = (await repo.watchForEntry(odo.id).first).single;
    expect(info.name, 'bill.pdf');
    expect(info.isImage, isFalse);
    expect((await repo.bytes(info.id))!.length, 1000);
  });
}
