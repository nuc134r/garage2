import 'package:clock/clock.dart';
import '../../../core/db/database.dart';
import '../../../core/model/enums.dart';
import '../../../core/model/units.dart';

/// Inclusive date range; null bounds are open.
class DateRange {
  const DateRange({this.from, this.to});

  /// Whole days from [first] to [last], both inclusive.
  factory DateRange.days(DateTime first, DateTime last) => DateRange(
        from: DateTime(first.year, first.month, first.day),
        to: DateTime(last.year, last.month, last.day + 1).subtract(const Duration(microseconds: 1)),
      );

  factory DateRange.lastDays(int days, {DateTime? now}) {
    final end = now ?? clock.now();
    return DateRange(from: end.subtract(Duration(days: days)), to: end);
  }

  static const allTime = DateRange();

  final DateTime? from;
  final DateTime? to;

  bool contains(DateTime d) => (from == null || !d.isBefore(from!)) && (to == null || !d.isAfter(to!));
}

enum StatsPeriod {
  allTime(null),
  year(365),
  month(30),
  week(7);

  const StatsPeriod(this.days);

  final int? days;

  DateRange get range => days == null ? DateRange.allTime : DateRange.lastDays(days!);
}

/// Sorts entries chronologically by odometer, then date, then creation time.
List<Entry> sortEntries(Iterable<Entry> entries) {
  final list = entries.toList();
  list.sort((a, b) {
    final c = a.odometer.compareTo(b.odometer);
    if (c != 0) return c;
    final d = a.date.compareTo(b.date);
    if (d != 0) return d;
    return a.createdAt.compareTo(b.createdAt);
  });
  return list;
}

/// A fuel consumption segment between two full-tank fills.
class FuelSegment {
  const FuelSegment({required this.closingEntry, required this.volume, required this.distance});

  /// The full-tank fill that closes the segment.
  final Entry closingEntry;

  /// Fuel added after the opening fill, up to and including the closing one.
  final double volume;
  final int distance;
}

/// Full-tank method: fuel consumed between two full fills is everything added
/// after the first one, up to and including the second.
List<FuelSegment> fuelSegments(List<Entry> sortedEntries) {
  final segments = <FuelSegment>[];
  Entry? lastFull;
  double pending = 0;
  for (final e in sortedEntries) {
    if (e.type != EntryType.fuel) continue;
    final volume = e.volume ?? 0;
    if (lastFull == null) {
      if (e.fullTank) lastFull = e;
      continue;
    }
    pending += volume;
    if (e.fullTank) {
      final distance = e.odometer - lastFull.odometer;
      if (distance > 0 && pending > 0) {
        segments.add(FuelSegment(closingEntry: e, volume: pending, distance: distance));
      }
      lastFull = e;
      pending = 0;
    }
  }
  return segments;
}

/// Efficiency per closing fill, keyed by entry id, in the vehicle's efficiency unit.
Map<String, double> fillEfficiencies(List<Entry> sortedEntries, Vehicle vehicle) {
  return {
    for (final s in fuelSegments(sortedEntries))
      s.closingEntry.id: ?_efficiency(s.volume, s.distance.toDouble(), vehicle),
  };
}

double? _efficiency(double volume, double distance, Vehicle v) => convertEfficiency(
      volume: volume,
      distance: distance,
      volumeUnit: v.volumeUnit,
      distanceUnit: v.distanceUnit,
      target: v.efficiencyUnit,
    );

class IntervalStats {
  const IntervalStats({
    required this.entryCount,
    required this.fuelCount,
    required this.serviceCount,
    required this.expenseCount,
    required this.firstOdometer,
    required this.lastOdometer,
    required this.firstDate,
    required this.lastDate,
    required this.fuelCost,
    required this.serviceCost,
    required this.otherCost,
    required this.fuelVolume,
    required this.efficiency,
    required this.avgDistanceBetweenRefuels,
    required this.avgDaysBetweenRefuels,
    required this.avgDistanceBetweenServices,
    required this.avgDaysBetweenServices,
  });

  final int entryCount;
  final int fuelCount;
  final int serviceCount;
  final int expenseCount;
  final int? firstOdometer;
  final int? lastOdometer;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Costs in currency minor units.
  final int fuelCost;
  final int serviceCost;
  final int otherCost;

  final double fuelVolume;

  /// In the vehicle's efficiency unit; null when there is not enough data.
  final double? efficiency;

  final double? avgDistanceBetweenRefuels;
  final double? avgDaysBetweenRefuels;
  final double? avgDistanceBetweenServices;
  final double? avgDaysBetweenServices;

  int get totalCost => fuelCost + serviceCost + otherCost;

  int get mileage => (firstOdometer != null && lastOdometer != null) ? lastOdometer! - firstOdometer! : 0;

  int get trackedDays => (firstDate != null && lastDate != null) ? lastDate!.difference(firstDate!).inDays : 0;

  double? get avgDailyMileage => trackedDays > 0 ? mileage / trackedDays : null;
  double? get avgMonthlyMileage => avgDailyMileage == null ? null : avgDailyMileage! * 30;
  double? get avgYearlyMileage => avgDailyMileage == null ? null : avgDailyMileage! * 365;

  /// Average price of one volume unit, in minor units.
  double? get avgFuelUnitPrice => fuelVolume > 0 ? fuelCost / fuelVolume : null;

  /// Total cost per one distance unit, in minor units.
  double? get costPerDistance => mileage > 0 ? totalCost / mileage : null;
}

IntervalStats computeStats(List<Entry> entries, Vehicle vehicle, DateRange range) {
  final all = sortEntries(entries);
  final inRange = all.where((e) => range.contains(e.date)).toList();

  int fuelCost = 0, serviceCost = 0, otherCost = 0, fuelCount = 0, serviceCount = 0, expenseCount = 0;
  double fuelVolume = 0;
  for (final e in inRange) {
    switch (e.type) {
      case EntryType.fuel:
        fuelCount++;
        fuelCost += e.totalCost;
        fuelVolume += e.volume ?? 0;
      case EntryType.service:
        serviceCount++;
        serviceCost += e.totalCost;
      case EntryType.expense:
        expenseCount++;
        otherCost += e.totalCost;
      case EntryType.odometer:
        break;
    }
  }

  final segments = fuelSegments(all).where((s) => range.contains(s.closingEntry.date)).toList();
  final segVolume = segments.fold<double>(0, (a, s) => a + s.volume);
  final segDistance = segments.fold<int>(0, (a, s) => a + s.distance);

  DateTime? minDate, maxDate;
  for (final e in inRange) {
    if (minDate == null || e.date.isBefore(minDate)) minDate = e.date;
    if (maxDate == null || e.date.isAfter(maxDate)) maxDate = e.date;
  }

  final refuels = inRange.where((e) => e.type == EntryType.fuel).toList();
  final services = inRange.where((e) => e.type == EntryType.service).toList();

  return IntervalStats(
    entryCount: inRange.length,
    fuelCount: fuelCount,
    serviceCount: serviceCount,
    expenseCount: expenseCount,
    firstOdometer: inRange.isEmpty ? null : inRange.first.odometer,
    lastOdometer: inRange.isEmpty ? null : inRange.last.odometer,
    firstDate: minDate,
    lastDate: maxDate,
    fuelCost: fuelCost,
    serviceCost: serviceCost,
    otherCost: otherCost,
    fuelVolume: fuelVolume,
    efficiency: _efficiency(segVolume, segDistance.toDouble(), vehicle),
    avgDistanceBetweenRefuels: _avgGap(refuels, (a, b) => (b.odometer - a.odometer).toDouble()),
    avgDaysBetweenRefuels: _avgGap(refuels, (a, b) => b.date.difference(a.date).inHours / 24),
    avgDistanceBetweenServices: _avgGap(services, (a, b) => (b.odometer - a.odometer).toDouble()),
    avgDaysBetweenServices: _avgGap(services, (a, b) => b.date.difference(a.date).inHours / 24),
  );
}

double? _avgGap(List<Entry> sorted, double Function(Entry a, Entry b) gap) {
  if (sorted.length < 2) return null;
  double sum = 0;
  for (var i = 1; i < sorted.length; i++) {
    sum += gap(sorted[i - 1], sorted[i]);
  }
  return sum / (sorted.length - 1);
}

/// Latest known odometer value for a vehicle.
int currentOdometer(List<Entry> entries, Vehicle vehicle) =>
    entries.fold(vehicle.initialOdometer, (m, e) => e.odometer > m ? e.odometer : m);

/// Costs of one calendar month, in currency minor units.
class MonthCosts {
  const MonthCosts(this.month, {this.fuel = 0, this.service = 0, this.other = 0});

  /// First day of the month.
  final DateTime month;
  final int fuel;
  final int service;
  final int other;

  int get total => fuel + service + other;
}

/// Costs per month within [range], including empty months between the first and last entry.
/// At most [maxMonths] (the latest ones) are returned.
List<MonthCosts> monthlyCosts(List<Entry> entries, DateRange range, {int maxMonths = 24}) {
  final inRange = entries.where((e) => range.contains(e.date) && e.totalCost != 0).toList();
  if (inRange.isEmpty) return const [];
  DateTime monthOf(DateTime d) => DateTime(d.year, d.month);
  final sums = <DateTime, List<int>>{};
  for (final e in inRange) {
    final s = sums.putIfAbsent(monthOf(e.date), () => [0, 0, 0]);
    switch (e.type) {
      case EntryType.fuel:
        s[0] += e.totalCost;
      case EntryType.service:
        s[1] += e.totalCost;
      case EntryType.expense || EntryType.odometer:
        s[2] += e.totalCost;
    }
  }
  final first = sums.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  final last = sums.keys.reduce((a, b) => a.isAfter(b) ? a : b);
  final months = <MonthCosts>[];
  for (var m = first; !m.isAfter(last); m = DateTime(m.year, m.month + 1)) {
    final s = sums[m];
    months.add(s == null ? MonthCosts(m) : MonthCosts(m, fuel: s[0], service: s[1], other: s[2]));
  }
  return months.length > maxMonths ? months.sublist(months.length - maxMonths) : months;
}

/// A dated value for trend charts.
typedef TrendPoint = ({DateTime date, double value});

/// Efficiency of each full-tank segment closing within [range], oldest first.
List<TrendPoint> efficiencyTrend(List<Entry> entries, Vehicle vehicle, DateRange range) {
  final sorted = sortEntries(entries);
  final byId = fillEfficiencies(sorted, vehicle);
  return [
    for (final e in sorted)
      if (byId[e.id] != null && range.contains(e.date)) (date: e.date, value: byId[e.id]!),
  ]..sort((a, b) => a.date.compareTo(b.date));
}

/// Price of one volume unit at each fill within [range] (minor units), oldest first.
List<TrendPoint> fuelPriceTrend(List<Entry> entries, DateRange range) => [
      for (final e in entries)
        if (e.type == EntryType.fuel && (e.volume ?? 0) > 0 && e.totalCost > 0 && range.contains(e.date))
          (date: e.date, value: e.totalCost / e.volume!),
    ]..sort((a, b) => a.date.compareTo(b.date));

/// Odometer readings within [range], oldest first.
List<TrendPoint> odometerTrend(List<Entry> entries, DateRange range) => [
      for (final e in sortEntries(entries))
        if (range.contains(e.date)) (date: e.date, value: e.odometer.toDouble()),
    ];

/// Other-expense totals per category id (null = uncategorized) within [range], largest first.
List<(String? categoryId, int cost)> expensesByCategory(List<Entry> entries, DateRange range) {
  final sums = <String?, int>{};
  for (final e in entries) {
    if (e.type != EntryType.expense || !range.contains(e.date)) continue;
    sums[e.expenseCategoryId] = (sums[e.expenseCategoryId] ?? 0) + e.totalCost;
  }
  return [for (final s in sums.entries) (s.key, s.value)]..sort((a, b) => b.$2.compareTo(a.$2));
}
