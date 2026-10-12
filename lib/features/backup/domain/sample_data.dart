import 'dart:math';

import '../../../core/db/database.dart';
import '../../../core/model/enums.dart';
import 'backup_data.dart';

/// Shown in debug builds or when built with `--dart-define=GARAGE_DEMO=true`.
const sampleDataEnabled = bool.fromEnvironment('GARAGE_DEMO');

/// A year of plausible history for two vehicles, as a backup to merge.
BackupData buildSampleData({DateTime? now}) {
  final today = now ?? DateTime.now();
  final rnd = Random(42);
  DateTime ago(int days) => today.subtract(Duration(days: days));

  final ai95 = FuelType(id: newId(), name: 'AI-95', createdAt: ago(400), updatedAt: ago(400));
  final ai98 = FuelType(id: newId(), name: 'AI-98', createdAt: ago(400), updatedAt: ago(400));
  final shell = Place(id: newId(), name: 'Shell', kind: PlaceKind.fuel, createdAt: ago(400), updatedAt: ago(400));
  final lukoil = Place(id: newId(), name: 'Lukoil', kind: PlaceKind.fuel, createdAt: ago(400), updatedAt: ago(400));
  final service = Place(id: newId(), name: 'Fit Service', kind: PlaceKind.service, createdAt: ago(400), updatedAt: ago(400));
  final parking = ExpenseCategory(id: newId(), name: 'Parking', createdAt: ago(400), updatedAt: ago(400));
  final wash = ExpenseCategory(id: newId(), name: 'Car wash', createdAt: ago(400), updatedAt: ago(400));

  Vehicle vehicle(String name, int color, int odometer, int order) => Vehicle(
        id: newId(),
        createdAt: ago(370),
        updatedAt: ago(370),
        name: name,
        color: color,
        purchaseDate: ago(370),
        initialOdometer: odometer,
        distanceUnit: DistanceUnit.km,
        volumeUnit: VolumeUnit.liter,
        efficiencyUnit: EfficiencyUnit.litersPer100Km,
        currencyCode: 'RUB',
        archived: false,
        sortOrder: order,
      );

  final i30 = vehicle('Hyundai i30 N', 0xFF1E88E5, 81800, 0);
  final aveo = vehicle('Chevrolet Aveo', 0xFF43A047, 125738, 1);

  final entries = <Entry>[];
  final reminders = <Reminder>[];
  final resets = <ReminderReset>[];

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

  for (final (v, daily, consumption, fuel) in [(i30, 45, 9.5, ai98), (aveo, 30, 7.2, ai95)]) {
    final oil = Reminder(
      id: newId(),
      createdAt: ago(360),
      updatedAt: ago(360),
      vehicleId: v.id,
      name: 'Engine oil',
      intervalDistance: 7500,
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
      final liters = (gap * daily * consumption / 100 + rnd.nextDouble() * 3);
      final price = 5800 + rnd.nextInt(700); // kopecks per liter
      entry(v, EntryType.fuel, day, odometer,
          volume: double.parse(liters.toStringAsFixed(2)),
          cost: (liters * price).round(),
          fuelType: fuel.id,
          place: rnd.nextBool() ? shell.id : lukoil.id);
      if (rnd.nextInt(5) == 0) {
        entry(v, EntryType.expense, day, odometer, cost: 30000 + rnd.nextInt(50000), category: rnd.nextBool() ? parking.id : wash.id);
      }
    }
    final oilChange = entry(v, EntryType.service, 120, odometer - 120 * daily,
        cost: 850000, place: service.id, note: 'Oil and filter change');
    resets.add(ReminderReset(entryId: oilChange.id, reminderId: oil.id));
  }

  return BackupData(
    mode: BackupMode.quick,
    exportedAt: today,
    vehicles: [i30, aveo],
    entries: entries,
    reminders: reminders,
    reminderResets: resets,
    fuelTypes: [ai95, ai98],
    places: [shell, lukoil, service],
    expenseCategories: [parking, wash],
  );
}
