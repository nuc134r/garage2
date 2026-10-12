import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../model/enums.dart';

const _uuid = Uuid();

String newId() => _uuid.v4();

/// Every synced row has a UUID key and timestamps, so backups can be merged.
mixin SyncedTable on Table {
  TextColumn get id => text().clientDefault(newId)();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Vehicle')
class Vehicles extends Table with SyncedTable {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get color => integer().withDefault(const Constant(0xFF607D8B))();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get initialOdometer => integer().withDefault(const Constant(0))();
  TextColumn get distanceUnit => textEnum<DistanceUnit>().withDefault(const Constant('km'))();
  TextColumn get volumeUnit => textEnum<VolumeUnit>().withDefault(const Constant('liter'))();
  TextColumn get efficiencyUnit => textEnum<EfficiencyUnit>().withDefault(const Constant('litersPer100Km'))();
  TextColumn get currencyCode => text().withDefault(const Constant('USD'))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('Entry')
@TableIndex(name: 'entries_vehicle_odometer', columns: {#vehicleId, #odometer})
class Entries extends Table with SyncedTable {
  TextColumn get vehicleId => text().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => textEnum<EntryType>()();
  DateTimeColumn get date => dateTime()();
  IntColumn get odometer => integer()();
  TextColumn get note => text().withDefault(const Constant(''))();

  /// Total cost in currency minor units (cents, kopecks).
  IntColumn get totalCost => integer().withDefault(const Constant(0))();

  /// Fuel amount in the vehicle's volume unit.
  RealColumn get volume => real().nullable()();
  BoolColumn get fullTank => boolean().withDefault(const Constant(true))();
  TextColumn get fuelTypeId => text().nullable().references(FuelTypes, #id, onDelete: KeyAction.setNull)();
  TextColumn get placeId => text().nullable().references(Places, #id, onDelete: KeyAction.setNull)();
  TextColumn get expenseCategoryId =>
      text().nullable().references(ExpenseCategories, #id, onDelete: KeyAction.setNull)();
}

/// A file (bill photo, PDF) attached to an entry. Content is stored in the database, so it works on web too.
@DataClassName('Attachment')
@TableIndex(name: 'attachments_entry', columns: {#entryId})
class Attachments extends Table with SyncedTable {
  TextColumn get entryId => text().references(Entries, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get mimeType => text()();

  /// Size of [data] in bytes, so lists don't have to load the content.
  IntColumn get size => integer()();
  BlobColumn get data => blob()();
}

@DataClassName('Reminder')
class Reminders extends Table with SyncedTable {
  TextColumn get vehicleId => text().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get intervalDistance => integer().nullable()();
  IntColumn get intervalDays => integer().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// A service entry that resets (fixes) a reminder.
@DataClassName('ReminderReset')
class ReminderResets extends Table {
  TextColumn get entryId => text().references(Entries, #id, onDelete: KeyAction.cascade)();
  TextColumn get reminderId => text().references(Reminders, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {entryId, reminderId};
}

@DataClassName('FuelType')
class FuelTypes extends Table with SyncedTable {
  TextColumn get name => text().withLength(min: 1, max: 100)();
}

@DataClassName('Place')
class Places extends Table with SyncedTable {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get kind => textEnum<PlaceKind>()();
}

@DataClassName('ExpenseCategory')
class ExpenseCategories extends Table with SyncedTable {
  TextColumn get name => text().withLength(min: 1, max: 100)();
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Local snapshots of the whole database (backup JSON). Never exported in backups.
@DataClassName('RestorePoint')
class RestorePoints extends Table {
  TextColumn get id => text().clientDefault(newId)();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  TextColumn get reason => text()();
  TextColumn get data => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
