import 'package:clock/clock.dart';
import 'dart:convert';
import 'dart:math';

import '../../../core/db/database.dart';
import '../../../core/model/enums.dart';
import 'backup_data.dart';

/// Shown in debug builds or when built with `--dart-define=GARAGE_DEMO=true`.
const sampleDataEnabled = bool.fromEnvironment('GARAGE_DEMO');

/// A year of plausible history for two vehicles, as a backup to merge.
BackupData buildSampleData({DateTime? now}) {
  final today = now ?? clock.now();
  final rnd = Random(42);
  DateTime ago(int days) => today.subtract(Duration(days: days));

  final regular = FuelType(id: newId(), name: 'Regular', createdAt: ago(400), updatedAt: ago(400));
  final premium = FuelType(id: newId(), name: 'Premium', createdAt: ago(400), updatedAt: ago(400));
  final shell = Place(id: newId(), name: 'Shell', kind: PlaceKind.fuel, createdAt: ago(400), updatedAt: ago(400));
  final chevron = Place(id: newId(), name: 'Chevron', kind: PlaceKind.fuel, createdAt: ago(400), updatedAt: ago(400));
  final supercharger = Place(id: newId(), name: 'Supercharger', kind: PlaceKind.fuel, createdAt: ago(400), updatedAt: ago(400));
  final service = Place(id: newId(), name: 'Main Street Auto', kind: PlaceKind.service, createdAt: ago(400), updatedAt: ago(400));
  final parking = ExpenseCategory(id: newId(), name: 'Parking', createdAt: ago(400), updatedAt: ago(400));
  final wash = ExpenseCategory(id: newId(), name: 'Car wash', createdAt: ago(400), updatedAt: ago(400));

  Vehicle vehicle(String name, int color, int odometer, int order, BodyType body, {bool electric = false}) => Vehicle(
        id: newId(),
        createdAt: ago(370),
        updatedAt: ago(370),
        name: name,
        color: color,
        bodyType: body,
        purchaseDate: ago(370),
        initialOdometer: odometer,
        distanceUnit: DistanceUnit.km,
        volumeUnit: electric ? VolumeUnit.kwh : VolumeUnit.liter,
        efficiencyUnit: electric ? EfficiencyUnit.kwhPer100Km : EfficiencyUnit.litersPer100Km,
        currencyCode: 'USD',
        archived: false,
        sortOrder: order,
      );

  final civic = vehicle('Honda Civic', 0xFF1F5FAD, 81800, 0, BodyType.sedan);
  final tiguan = vehicle('Volkswagen Tiguan', 0xFFF4F5F6, 125738, 1, BodyType.suv);
  final tesla = vehicle('Tesla Model 3', 0xFFC62828, 42300, 2, BodyType.sedan, electric: true);

  final entries = <Entry>[];
  final reminders = <Reminder>[];
  final resets = <ReminderReset>[];
  final attachments = <Attachment>[];

  Entry entry(Vehicle v, EntryType type, int daysAgo, int odometer,
      {int cost = 0, double? volume, String? place, String? fuelType, String? category, String note = ''}) {
    final d = ago(daysAgo);
    final e = Entry(
      id: newId(),
      createdAt: d,
      updatedAt: d,
      vehicleId: v.id,
      type: type,
      date: DateTime(d.year, d.month, d.day),
      odometer: odometer,
      note: note,
      totalCost: cost,
      volume: volume,
      fullTank: true,
      fuelTypeId: fuelType,
      placeId: place,
      expenseCategoryId: category,
    );
    entries.add(e);
    return e;
  }

  // Consumption per 100 km; price in cents per litre or kWh.
  for (final (v, daily, consumption, fuel, price, stations) in [
    (civic, 45, 6.8, regular, 95, [shell, chevron]),
    (tiguan, 30, 9.4, premium, 110, [shell, chevron]),
    (tesla, 25, 15.5, null, 28, [supercharger]),
  ]) {
    final electric = v.volumeUnit == VolumeUnit.kwh;
    final serviceNote = electric ? 'Tire rotation and cabin filter' : 'Oil and filter change';
    final oil = Reminder(
      id: newId(),
      createdAt: ago(360),
      updatedAt: ago(360),
      vehicleId: v.id,
      name: electric ? 'Tire rotation' : 'Engine oil',
      intervalDistance: electric ? 10000 : 7500,
      intervalDays: 365,
      archived: false,
    );
    final insurance = Reminder(
      id: newId(),
      createdAt: ago(300),
      updatedAt: ago(300),
      vehicleId: v.id,
      name: 'Insurance',
      intervalDays: 365,
      archived: false,
    );
    reminders.addAll([oil, insurance]);

    var odometer = v.initialOdometer;
    for (var day = 360; day > 0;) {
      final gap = 6 + rnd.nextInt(8);
      day -= gap;
      if (day <= 0) break;
      odometer += gap * daily + rnd.nextInt(80);
      final amount = (gap * daily * consumption / 100 + rnd.nextDouble() * 3);
      entry(v, EntryType.fuel, day, odometer,
          volume: double.parse(amount.toStringAsFixed(2)),
          cost: (amount * (price + rnd.nextInt(price ~/ 5))).round(),
          fuelType: fuel?.id,
          place: stations[rnd.nextInt(stations.length)].id);
      if (rnd.nextInt(5) == 0) {
        entry(v, EntryType.expense, day, odometer, cost: 300 + rnd.nextInt(1200), category: rnd.nextBool() ? parking.id : wash.id);
      }
    }
    final oilChange = entry(v, EntryType.service, 120, odometer - 120 * daily,
        cost: electric ? 6000 : 8500, place: service.id, note: serviceNote);
    resets.add(ReminderReset(entryId: oilChange.id, reminderId: oil.id));
    // Earlier oil changes, so the reminder history has intervals to compare.
    for (final day in [350, 175]) {
      final earlier = entry(v, EntryType.service, day, v.initialOdometer + (360 - day) * daily,
          cost: electric ? 5500 : 7800, place: service.id, note: serviceNote);
      resets.add(ReminderReset(entryId: earlier.id, reminderId: oil.id));
    }
    attachments.add(Attachment(
      id: newId(),
      createdAt: oilChange.createdAt,
      updatedAt: oilChange.createdAt,
      entryId: oilChange.id,
      name: 'receipt.png',
      mimeType: 'image/png',
      size: _receiptPng.length,
      data: _receiptPng,
    ));
  }

  return BackupData(
    mode: BackupMode.quick,
    exportedAt: today,
    vehicles: [civic, tiguan, tesla],
    entries: entries,
    reminders: reminders,
    reminderResets: resets,
    fuelTypes: [regular, premium],
    places: [shell, chevron, supercharger, service],
    expenseCategories: [parking, wash],
    attachments: attachments,
    attachmentsIncluded: true,
  );
}

/// A tiny drawing of a receipt.
final _receiptPng = base64Decode('iVBORw0KGgoAAAANSUhEUgAAADAAAABACAIAAADTQmMRAAAAX0lEQVR42u3VsQkAIAwEwAxplf1HsErlChYRAh78AAdv/KjaoxJAQEBAQEAdoMzVG5UBAb2+svvrUxmQK7NlQEC2zBsCsmUqAwKyZUBAtkxlvRn3Mf4BsmVAQEBAc3IAcr68gbxQOP0AAAAASUVORK5CYII=');
