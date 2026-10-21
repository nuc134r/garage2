import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/core/model/enums.dart';
import 'package:garage/features/stats/domain/stats_analysis.dart';
import 'package:garage/features/stats/domain/stats_calculator.dart';

import 'helpers.dart';

void main() {
  final vehicle = testVehicle();
  DateTime d(int month, int day) => DateTime(2025, month, day);

  group('previousRange', () {
    test('same length right before', () {
      final r = DateRange(from: d(3, 1), to: d(3, 31));
      final p = previousRange(r)!;
      expect(p.to!.isBefore(r.from!), isTrue);
      expect(r.to!.difference(r.from!), p.to!.difference(p.from!) + const Duration(microseconds: 1));
    });

    test('a calendar year compares with the same dates a year earlier', () {
      final r = calendarYear(2026, DateTime(2026, 10, 16, 9));
      expect(isCalendarYear(r), isTrue);
      final p = previousRange(r)!;
      expect(p.from, DateTime(2025));
      expect((p.to!.month, p.to!.day), (10, 16));
    });

    test('none for all time', () => expect(previousRange(DateRange.allTime), isNull));
  });

  test('relativeChange', () {
    expect(relativeChange(120, 100), closeTo(.2, 1e-9));
    expect(relativeChange(80, 100), closeTo(-.2, 1e-9));
    expect(relativeChange(5, 0), isNull);
    expect(relativeChange(null, 3), isNull);
  });

  group('distance', () {
    final entries = [
      testEntry(odometer: 1000, date: d(1, 30)),
      testEntry(odometer: 1300, date: d(2, 2)), // 100 km/day on Jan 31, Feb 1, Feb 2
      testEntry(odometer: 1350, date: d(2, 2)), // same day
    ];
    final daily = dailyDistance(entries);

    test('spreads the distance between readings over the days', () {
      expect(daily[d(1, 31)], closeTo(100, 1e-9));
      expect(daily[d(2, 1)], closeTo(100, 1e-9));
      expect(daily[d(2, 2)], closeTo(150, 1e-9));
      expect(daily[d(1, 30)], isNull);
    });

    test('per month and in a range', () {
      expect(monthlyDistance(daily, DateRange.allTime).map((m) => (m.month.month, m.value.round())), [
        (1, 100),
        (2, 250),
      ]);
      expect(distanceIn(daily, DateRange.days(d(2, 1), d(2, 28))), closeTo(250, 1e-9));
    });

    test('weekday averages cover every day between readings', () {
      final avg = weekdayAverages(daily, DateRange.allTime);
      expect(avg.length, 7);
      expect(avg.reduce((a, b) => a + b), closeTo(350, 1e-9)); // each weekday seen once
    });

    test('milestone at the recent pace', () {
      final m = nextMilestone(9500, 50, DateTime(2025, 1, 1))!;
      expect(m.odometer, 10000);
      expect(m.date, DateTime(2025, 1, 11));
      expect(nextMilestone(9500, null, DateTime(2025)), isNull);
    });
  });

  group('odometer estimate', () {
    final readings = [
      testEntry(odometer: 1000, date: d(1, 1)),
      testEntry(odometer: 1500, date: d(1, 11)), // 50 km a day
    ];

    test('adds the recent daily distance for the days since the last reading', () {
      expect(estimateOdometer(readings, d(1, 15)), 1700);
    });

    test('never passes a later reading', () {
      expect(estimateOdometer(readings, d(1, 15), upTo: 1600), 1600);
    });

    test('none on the day of the last reading or before any', () {
      expect(estimateOdometer(readings, d(1, 11)), isNull);
      expect(estimateOdometer(readings, DateTime(2024, 12, 1)), isNull);
    });
  });

  group('costs', () {
    final entries = [
      testEntry(odometer: 0, date: d(1, 1), totalCost: 5000, volume: 40),
      testEntry(odometer: 500, date: d(1, 15), type: EntryType.service, totalCost: 3000),
      _expense(600, d(2, 1), 1000, 'parking'),
      _expense(700, d(2, 2), 500, 'wash'),
      testEntry(odometer: 1000, date: d(2, 20), totalCost: 4000, volume: 35),
    ];

    test('breakdown by kind and category, largest first', () {
      final slices = costBreakdown(entries, DateRange.allTime);
      expect(slices.map((s) => (s.kind, s.categoryId, s.cost)), [
        (CostKind.fuel, null, 9000),
        (CostKind.service, null, 3000),
        (CostKind.expense, 'parking', 1000),
        (CostKind.expense, 'wash', 500),
      ]);
    });

    test('running total starts at zero and ends at the sum', () {
      final steps = cumulativeCosts(entries, DateRange(from: d(1, 1), to: d(3, 1)));
      expect(steps.first, (0.0, 0));
      expect(steps.last.$2, 13500);
      expect(steps.map((s) => s.$1), orderedEquals([...steps.map((s) => s.$1)]..sort()));
    });

    test('cost per distance skips a month with little driving', () {
      final list = [
        testEntry(odometer: 0, date: d(1, 28), totalCost: 5000),
        testEntry(odometer: 30, date: d(1, 31), totalCost: 5000), // 30 km in January
        testEntry(odometer: 1030, date: d(2, 28), totalCost: 5000),
        testEntry(odometer: 2030, date: d(3, 31), totalCost: 5000),
      ];
      final points = costPerDistanceByMonth(list, dailyDistance(list), DateRange.allTime);
      expect(points.map((p) => p.date.month), [2, 3]);
    });

    test('cost per distance by month', () {
      final points = costPerDistanceByMonth(entries, dailyDistance(entries), DateRange.allTime);
      expect(points, isNotEmpty);
      expect(points.every((p) => p.value > 0), isTrue);
    });

    test('yearly projection extrapolates the year so far', () {
      final year = [
        testEntry(odometer: 0, date: DateTime(2025, 1, 1), totalCost: 1000),
        testEntry(odometer: 100, date: DateTime(2025, 3, 1), totalCost: 1000),
      ];
      final p = projectedYearCost(year, DateTime(2025, 7, 2))!;
      expect(p, inInclusiveRange(3800, 4200)); // 2000 in half a year
      expect(projectedYearCost(year, DateTime(2025, 1, 10)), isNull, reason: 'too early to tell');
    });

    test('months in a range', () {
      expect(monthsIn(DateRange(from: d(1, 1), to: d(7, 1)), entries), closeTo(5.95, .05));
    });
  });

  group('fuel', () {
    // Full tanks every 500 km; 40 l (8.0), 35 l (7.0), then a partial and a full one.
    final entries = [
      testEntry(
        odometer: 0,
        date: d(1, 1),
        totalCost: 4000,
        volume: 40,
        id: 'a',
      ).copyWith(placeId: const Value('shell')),
      testEntry(
        odometer: 500,
        date: d(1, 10),
        totalCost: 4000,
        volume: 40,
        id: 'b',
      ).copyWith(placeId: const Value('shell')),
      testEntry(
        odometer: 1000,
        date: d(1, 20),
        totalCost: 3150,
        volume: 35,
        id: 'c',
      ).copyWith(placeId: const Value('bp')),
      testEntry(
        odometer: 1200,
        date: d(2, 1),
        totalCost: 1000,
        volume: 10,
        id: 'd',
        fullTank: false,
      ).copyWith(placeId: const Value('bp')),
      testEntry(
        odometer: 1500,
        date: d(2, 10),
        totalCost: 3000,
        volume: 30,
        id: 'e',
      ).copyWith(placeId: const Value('bp')),
    ];

    test('facts: extremes, partial fills and range per tank', () {
      final f = fuelFacts(entries, vehicle, DateRange.allTime);
      expect(f.fills, 5);
      expect(f.partialFills, 1);
      expect(f.cheapest!.id, 'c'); // 90 per litre
      expect(f.dearest!.id, isIn(['a', 'b', 'd', 'e'])); // 100 per litre
      expect(f.best!.$1.id, 'c'); // 7.0 l/100km
      expect(f.best!.$2, closeTo(7, 1e-9));
      expect(f.worst!.$1.id, isIn(['b', 'e'])); // both 8.0 l/100km
      expect(f.rangePerTank, closeTo(500, 1e-9));
    });

    test('stations: visits, price and efficiency', () {
      final s = {for (final g in stationStats(entries, vehicle, DateRange.allTime)) g.id: g};
      expect(s['bp']!.fills, 3);
      expect(s['shell']!.avgPrice, closeTo(100, 1e-9));
      expect(s['bp']!.efficiency, closeTo(7.5, 1e-9)); // c 7.0 and e 8.0
    });

    test('efficiency and price by month', () {
      final eff = efficiencyByMonth(entries, vehicle, DateRange.allTime);
      expect(eff.map((m) => m.month.month), [1, 2]);
      expect(eff.first.value, closeTo(7.5, 1e-9)); // 75 l over 1000 km
      final price = priceByMonth(entries, DateRange.allTime);
      expect(price.first.low, closeTo(90, 1e-9));
      expect(price.first.high, closeTo(100, 1e-9));
    });

    test('moving average keeps the dates and smooths', () {
      final pts = [for (var i = 0; i < 5; i++) (date: d(1, i + 1), value: i.isEven ? 10.0 : 0.0)];
      final avg = movingAverage(pts, window: 3);
      expect(avg.map((p) => p.date), pts.map((p) => p.date));
      expect(avg[2].value, closeTo(10 / 3, 1e-9));
    });
  });

  group('service', () {
    final oil = testEntry(odometer: 100, date: d(3, 1), type: EntryType.service, totalCost: 8000, id: 'oil1');
    final oil2 = testEntry(odometer: 900, date: d(9, 1), type: EntryType.service, totalCost: 8500, id: 'oil2');
    final tyres = testEntry(
      odometer: 500,
      date: DateTime(2026, 4, 1),
      type: EntryType.service,
      totalCost: 20000,
      id: 't',
    );
    final resets = [
      const ReminderReset(entryId: 'oil1', reminderId: 'r-oil'),
      const ReminderReset(entryId: 'oil2', reminderId: 'r-oil'),
    ];

    test('events carry their reminders, oldest first', () {
      final ev = serviceEvents([oil2, tyres, oil], resets, DateRange.allTime);
      expect(ev.map((e) => e.entry.id), ['oil1', 'oil2', 't']);
      expect(ev.map((e) => e.reminderIds.join()), ['r-oil', 'r-oil', '']);
    });

    test('cost per year and of the last reset', () {
      expect(serviceCostByYear([oil, oil2, tyres], DateRange.allTime), [
        (year: 2025, cost: 16500),
        (year: 2026, cost: 20000),
      ]);
      expect(lastServiceCost('r-oil', [oil, oil2], resets), 8500);
      expect(lastServiceCost('none', [oil], resets), isNull);
    });
  });

  group('insights', () {
    test('cost share, change and upcoming service', () {
      final entries = [
        testEntry(odometer: 0, date: d(1, 1), totalCost: 9000, volume: 40),
        _expense(100, d(1, 5), 1000, 'parking'),
      ];
      final range = DateRange(from: d(1, 1), to: d(1, 31));
      final current = computeStats(entries, vehicle, range);
      final previous = computeStats(
        [testEntry(odometer: 0, date: d(1, 1), totalCost: 5000)],
        vehicle,
        DateRange.allTime,
      );
      final found = findInsights(
        entries: entries,
        vehicle: vehicle,
        range: range,
        current: current,
        previous: previous,
        upcoming: [(name: 'Engine oil', days: 20, cost: 8500), (name: 'Far', days: 200, cost: null)],
      );
      expect(found.first, isA<UpcomingServiceInsight>().having((i) => i.reminderName, 'name', 'Engine oil'));
      expect(found.whereType<CostChangeInsight>().single.percent, 100);
      expect(found.whereType<CostShareInsight>().single.percent, 90);
    });

    test('efficiency record after enough fills', () {
      final entries = [
        for (var i = 0; i < 8; i++) testEntry(odometer: i * 500, date: d(1, 1 + i * 3), volume: i == 7 ? 30 : 40),
      ];
      final found = findInsights(
        entries: entries,
        vehicle: vehicle,
        range: DateRange.allTime,
        current: computeStats(entries, vehicle, DateRange.allTime),
      );
      expect(found.whereType<EfficiencyRecordInsight>().single.best, isTrue);
    });
  });
}

Entry _expense(int odometer, DateTime date, int cost, String category) => testEntry(
  odometer: odometer,
  date: date,
  type: EntryType.expense,
  totalCost: cost,
).copyWith(expenseCategoryId: Value(category));
