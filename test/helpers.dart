import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/core/model/enums.dart';

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
}

final _t0 = DateTime(2025, 1, 1);

Vehicle testVehicle({
  String id = 'v1',
  int initialOdometer = 0,
  DistanceUnit distanceUnit = DistanceUnit.km,
  VolumeUnit volumeUnit = VolumeUnit.liter,
  EfficiencyUnit efficiencyUnit = EfficiencyUnit.litersPer100Km,
}) =>
    Vehicle(
      id: id,
      createdAt: _t0,
      updatedAt: _t0,
      name: 'Test',
      color: 0,
      initialOdometer: initialOdometer,
      distanceUnit: distanceUnit,
      volumeUnit: volumeUnit,
      efficiencyUnit: efficiencyUnit,
      currencyCode: 'EUR',
      archived: false,
      sortOrder: 0,
    );

int _seq = 0;

Entry testEntry({
  String? id,
  String vehicleId = 'v1',
  EntryType type = EntryType.fuel,
  required int odometer,
  required DateTime date,
  int totalCost = 0,
  double? volume,
  bool fullTank = true,
}) =>
    Entry(
      id: id ?? 'e${_seq++}',
      createdAt: date,
      updatedAt: date,
      vehicleId: vehicleId,
      type: type,
      date: date,
      odometer: odometer,
      note: '',
      totalCost: totalCost,
      volume: volume,
      fullTank: fullTank,
    );

Reminder testReminder({String id = 'r1', int? distance, int? days, required DateTime createdAt}) => Reminder(
      id: id,
      createdAt: createdAt,
      updatedAt: createdAt,
      vehicleId: 'v1',
      name: 'Oil',
      intervalDistance: distance,
      intervalDays: days,
      archived: false,
    );
