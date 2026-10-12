import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/model/enums.dart';
import 'package:garage/core/model/units.dart';
import 'package:garage/features/stats/domain/stats_calculator.dart';

import 'helpers.dart';

void main() {
  final vehicle = testVehicle();
  DateTime day(int d) => DateTime(2025, 1, 1).add(Duration(days: d));

  group('fuel efficiency (full-tank method)', () {
    test('needs two full fills', () {
      final stats = computeStats([testEntry(odometer: 1000, date: day(0), volume: 40)], vehicle, DateRange.allTime);
      expect(stats.efficiency, isNull);
    });

    test('uses fuel added after the first full fill', () {
      final entries = [
        testEntry(odometer: 1000, date: day(0), volume: 40),
        testEntry(odometer: 1500, date: day(5), volume: 40),
      ];
      expect(computeStats(entries, vehicle, DateRange.allTime).efficiency, closeTo(8.0, 1e-9));
    });

    test('partial fills are accumulated into the next full fill', () {
      final entries = [
        testEntry(odometer: 1000, date: day(0), volume: 50),
        testEntry(odometer: 1200, date: day(2), volume: 10, fullTank: false),
        testEntry(odometer: 1500, date: day(5), volume: 30),
      ];
      final stats = computeStats(entries, vehicle, DateRange.allTime);
      expect(stats.efficiency, closeTo(8.0, 1e-9));
      expect(stats.fuelVolume, 90);
    });

    test('is total fuel over total distance, not an average of fills', () {
      final entries = [
        testEntry(odometer: 0, date: day(0), volume: 40),
        testEntry(odometer: 100, date: day(1), volume: 10), // 10 L/100km
        testEntry(odometer: 1000, date: day(9), volume: 45), // 5 L/100km
      ];
      expect(computeStats(entries, vehicle, DateRange.allTime).efficiency, closeTo(55 / 1000 * 100, 1e-9));
    });

    test('per-fill efficiencies keyed by closing entry', () {
      final entries = [
        testEntry(id: 'a', odometer: 1000, date: day(0), volume: 40),
        testEntry(id: 'b', odometer: 1500, date: day(5), volume: 40),
      ];
      expect(fillEfficiencies(entries, vehicle), {'b': closeTo(8.0, 1e-9)});
    });
  });

  test('unit conversion to mpg', () {
    final mpg = convertEfficiency(
      volume: 1,
      distance: 30,
      volumeUnit: VolumeUnit.galUs,
      distanceUnit: DistanceUnit.mi,
      target: EfficiencyUnit.mpgUs,
    );
    expect(mpg, closeTo(30, 1e-9));
    final l100 = convertEfficiency(
      volume: 1,
      distance: 30,
      volumeUnit: VolumeUnit.galUs,
      distanceUnit: DistanceUnit.mi,
      target: EfficiencyUnit.litersPer100Km,
    );
    expect(l100, closeTo(7.84, 0.01));
  });

  test('costs, counts, mileage and averages', () {
    final entries = [
      testEntry(odometer: 1000, date: day(0), volume: 40, totalCost: 6000),
      testEntry(type: EntryType.service, odometer: 1100, date: day(1), totalCost: 20000),
      testEntry(type: EntryType.expense, odometer: 1200, date: day(2), totalCost: 500),
      testEntry(odometer: 1500, date: day(10), volume: 40, totalCost: 6400),
      testEntry(type: EntryType.service, odometer: 2000, date: day(21), totalCost: 10000),
    ];
    final s = computeStats(entries, vehicle, DateRange.allTime);
    expect(s.fuelCost, 12400);
    expect(s.serviceCost, 30000);
    expect(s.otherCost, 500);
    expect(s.totalCost, 42900);
    expect((s.fuelCount, s.serviceCount, s.expenseCount), (2, 2, 1));
    expect(s.mileage, 1000);
    expect(s.trackedDays, 21);
    expect(s.avgDistanceBetweenRefuels, 500);
    expect(s.avgDaysBetweenRefuels, 10);
    expect(s.avgDistanceBetweenServices, 900);
    expect(s.avgDaysBetweenServices, 20);
    expect(s.avgFuelUnitPrice, 155);
  });

  test('date range filters entries inclusively', () {
    final entries = [
      testEntry(odometer: 1000, date: day(0), volume: 40, totalCost: 100),
      testEntry(odometer: 1500, date: day(40), volume: 40, totalCost: 200),
    ];
    final s = computeStats(entries, vehicle, DateRange(from: day(30), to: day(40)));
    expect(s.fuelCost, 200);
    // The segment closing inside the range still uses the earlier full fill.
    expect(s.efficiency, closeTo(8.0, 1e-9));
  });

  test('current odometer falls back to the initial value', () {
    expect(currentOdometer([], testVehicle(initialOdometer: 5000)), 5000);
  });
}
