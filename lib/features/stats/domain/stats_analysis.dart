import 'dart:math';

import '../../../core/db/database.dart';
import '../../../core/model/enums.dart';
import 'stats_calculator.dart';

/// Insight-level analysis for the statistics screen: comparisons, per-month and per-weekday breakdowns,
/// projections and short findings. Plain Dart over the vehicle's entries.

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _month(DateTime d) => DateTime(d.year, d.month);
DateTime _nextMonth(DateTime m) => DateTime(m.year, m.month + 1);

/// The range a period is compared with: the same calendar dates a year earlier for a calendar year,
/// otherwise the span of the same length right before. Null for an open range (all time).
DateRange? previousRange(DateRange range) {
  final from = range.from, to = range.to;
  if (from == null || to == null) return null;
  if (isCalendarYear(range)) {
    return DateRange(from: DateTime(from.year - 1), to: DateTime(to.year - 1, to.month, to.day, 23, 59, 59));
  }
  final length = to.difference(from);
  return DateRange(from: from.subtract(length), to: from.subtract(const Duration(microseconds: 1)));
}

/// Whether [range] starts on January 1 and ends within the same year (a calendar year, maybe up to today).
bool isCalendarYear(DateRange range) {
  final from = range.from, to = range.to;
  return from != null && to != null && from.month == 1 && from.day == 1 && from.hour == 0 && to.year == from.year;
}

/// January 1 – December 31 of [year], cut at [now] for the current year.
DateRange calendarYear(int year, DateTime now) {
  final end = DateTime(year, 12, 31, 23, 59, 59);
  return DateRange(from: DateTime(year), to: end.isAfter(now) ? now : end);
}

/// Years that have entries, newest first.
List<int> yearsWithEntries(List<Entry> entries) => ({for (final e in entries) e.date.year}.toList()..sort()).reversed.toList();

/// Relative change from [before] to [now]; null when there is nothing to compare with.
double? relativeChange(num? now, num? before) {
  if (now == null || before == null || before == 0) return null;
  return (now - before) / before.abs();
}

/// Distance driven on each day, spreading the distance between two odometer readings evenly over the days
/// between them. Keys are dates without time; days without driving are absent.
Map<DateTime, double> dailyDistance(List<Entry> entries) {
  final readings = sortEntries(entries);
  final out = <DateTime, double>{};
  for (var i = 1; i < readings.length; i++) {
    final a = readings[i - 1], b = readings[i];
    final km = (b.odometer - a.odometer).toDouble();
    if (km <= 0) continue;
    final from = _day(a.date), to = _day(b.date);
    final days = to.difference(from).inDays;
    if (days <= 0) {
      out[to] = (out[to] ?? 0) + km;
      continue;
    }
    final perDay = km / days;
    for (var k = 1; k <= days; k++) {
      final d = DateTime(from.year, from.month, from.day + k);
      out[d] = (out[d] ?? 0) + perDay;
    }
  }
  return out;
}

/// Distance driven within [range].
double distanceIn(Map<DateTime, double> daily, DateRange range) =>
    daily.entries.where((e) => range.contains(e.key)).fold(0.0, (a, e) => a + e.value);

typedef MonthValue = ({DateTime month, double value});

/// The months a chart over [range] spans: from the first to the last month with data, cut to [range].
List<DateTime> _months(Iterable<DateTime> dates, DateRange range) {
  final inRange = dates.where(range.contains).toList();
  if (inRange.isEmpty) return const [];
  final first = _month(inRange.reduce((a, b) => a.isBefore(b) ? a : b));
  final last = _month(inRange.reduce((a, b) => a.isAfter(b) ? a : b));
  return [for (var m = first; !m.isAfter(last); m = _nextMonth(m)) m];
}

/// Distance per calendar month within [range], months without driving included as zero.
List<MonthValue> monthlyDistance(Map<DateTime, double> daily, DateRange range) {
  final sums = <DateTime, double>{};
  for (final MapEntry(key: d, value: v) in daily.entries) {
    if (range.contains(d)) sums[_month(d)] = (sums[_month(d)] ?? 0) + v;
  }
  return [for (final m in _months(daily.keys, range)) (month: m, value: sums[m] ?? 0)];
}

/// Average distance per weekday (Monday first) over the days of [range] that lie between the first and the
/// last odometer reading.
List<double> weekdayAverages(Map<DateTime, double> daily, DateRange range) {
  final sums = List.filled(7, 0.0), counts = List.filled(7, 0);
  final days = daily.keys.where(range.contains).toList()..sort();
  if (days.isEmpty) return sums;
  for (var d = days.first; !d.isAfter(days.last); d = DateTime(d.year, d.month, d.day + 1)) {
    sums[d.weekday - 1] += daily[d] ?? 0;
    counts[d.weekday - 1]++;
  }
  return [for (var i = 0; i < 7; i++) counts[i] == 0 ? 0 : sums[i] / counts[i]];
}

/// All costs divided by the distance driven, per month. Months with little driving (under a third of the
/// median month, e.g. the partial first month) are skipped: a fill-up there would look like a huge cost.
List<TrendPoint> costPerDistanceByMonth(List<Entry> entries, Map<DateTime, double> daily, DateRange range) {
  final costs = {for (final m in monthlyCosts(entries, range, maxMonths: 1000)) m.month: m.total};
  final months = monthlyDistance(daily, range);
  if (months.isEmpty) return const [];
  final sorted = months.map((m) => m.value).toList()..sort();
  final floor = max(1.0, sorted[sorted.length ~/ 2] / 3);
  return [
    for (final m in months)
      if (m.value >= floor && (costs[m.month] ?? 0) > 0) (date: m.month, value: costs[m.month]! / m.value),
  ];
}

/// Running total of costs from the start of [range], as (days since start, total in minor units) steps.
List<(double day, int total)> cumulativeCosts(List<Entry> entries, DateRange range, {DateTime? start}) {
  final from = range.from ?? start;
  if (from == null) return const [];
  final list = entries.where((e) => range.contains(e.date) && e.totalCost > 0).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  var sum = 0;
  return [
    (0, 0),
    for (final e in list) (e.date.difference(from).inHours / 24, sum += e.totalCost),
  ];
}

enum CostKind { fuel, service, expense }

/// A share of the costs: fuel, service, or one expense category.
class CostSlice {
  const CostSlice(this.kind, this.cost, {this.categoryId});

  final CostKind kind;
  final String? categoryId;
  final int cost;
}

/// Where the money went within [range]: fuel, service and each expense category, largest first.
List<CostSlice> costBreakdown(List<Entry> entries, DateRange range) {
  var fuel = 0, service = 0;
  final categories = <String?, int>{};
  for (final e in entries) {
    if (!range.contains(e.date) || e.totalCost <= 0) continue;
    switch (e.type) {
      case EntryType.fuel:
        fuel += e.totalCost;
      case EntryType.service:
        service += e.totalCost;
      case EntryType.expense || EntryType.odometer:
        categories[e.expenseCategoryId] = (categories[e.expenseCategoryId] ?? 0) + e.totalCost;
    }
  }
  return [
    if (fuel > 0) CostSlice(CostKind.fuel, fuel),
    if (service > 0) CostSlice(CostKind.service, service),
    for (final MapEntry(:key, :value) in categories.entries) CostSlice(CostKind.expense, value, categoryId: key),
  ]..sort((a, b) => b.cost.compareTo(a.cost));
}

/// Number of months [range] covers (at least one); for an open range, the span of the entries in it.
double monthsIn(DateRange range, List<Entry> entries) => max(1, monthsSpanned(range, entries));

/// Like [monthsIn], but not rounded up to a month: a week is about 0.23.
double monthsSpanned(DateRange range, List<Entry> entries) {
  var from = range.from, to = range.to;
  if (from == null || to == null) {
    final dates = entries.where((e) => range.contains(e.date)).map((e) => e.date).toList();
    if (dates.isEmpty) return 0;
    from ??= dates.reduce((a, b) => a.isBefore(b) ? a : b);
    to ??= dates.reduce((a, b) => a.isAfter(b) ? a : b);
  }
  return to.difference(from).inHours / 24 / 30.44;
}

/// This year's costs extrapolated to the whole year; null before there are three weeks of data in it.
int? projectedYearCost(List<Entry> entries, DateTime now) {
  final start = DateTime(now.year);
  final thisYear = entries.where((e) => !e.date.isBefore(start) && !e.date.isAfter(now)).toList();
  if (thisYear.isEmpty) return null;
  final first = sortEntries(entries).first.date;
  final since = first.isAfter(start) ? first : start;
  final days = now.difference(since).inHours / 24;
  if (days < 21) return null;
  final cost = thisYear.fold(0, (a, e) => a + e.totalCost);
  final daysInYear = DateTime(now.year + 1).difference(start).inDays;
  final remaining = DateTime(now.year + 1).difference(now).inHours / 24;
  return (cost + cost / days * remaining).round().clamp(cost, cost * daysInYear);
}

/// Average distance per day over the last [days] days with readings; null without driving.
double? recentDailyDistance(Map<DateTime, double> daily, DateTime now, {int days = 90}) {
  final from = _day(now).subtract(Duration(days: days));
  final recent = daily.entries.where((e) => e.key.isAfter(from) && !e.key.isAfter(now)).toList();
  if (recent.isEmpty) return null;
  final first = recent.map((e) => e.key).reduce((a, b) => a.isBefore(b) ? a : b);
  final span = max(1, _day(now).difference(first).inDays + 1);
  final total = recent.fold(0.0, (a, e) => a + e.value);
  return total > 0 ? total / span : null;
}

/// When the odometer passes the next round number (multiple of [step]) at the recent pace.
({int odometer, DateTime date})? nextMilestone(int odometer, double? perDay, DateTime now, {int step = 10000}) {
  if (perDay == null || perDay <= 0) return null;
  final target = (odometer ~/ step + 1) * step;
  final days = ((target - odometer) / perDay).ceil();
  if (days > 3 * 365) return null;
  return (odometer: target, date: _day(now).add(Duration(days: days)));
}

/// The calendar month with the most driving in [months].
MonthValue? busiestMonth(List<MonthValue> months) =>
    months.isEmpty ? null : months.reduce((a, b) => b.value > a.value ? b : a);

/// The longest stretch in days between two consecutive entries within [range].
int? longestGap(List<Entry> entries, DateRange range) {
  final dates = entries.where((e) => range.contains(e.date)).map((e) => _day(e.date)).toSet().toList()..sort();
  if (dates.length < 2) return null;
  var best = 0;
  for (var i = 1; i < dates.length; i++) {
    best = max(best, dates[i].difference(dates[i - 1]).inDays);
  }
  return best;
}

// ---------------------------------------------------------------------------------------------------------
// Fuel

/// Price of one volume unit per fill (minor units).
double? unitPrice(Entry e) => e.type == EntryType.fuel && (e.volume ?? 0) > 0 && e.totalCost > 0 ? e.totalCost / e.volume! : null;

/// A centred moving average of [points] over [window] neighbours.
List<TrendPoint> movingAverage(List<TrendPoint> points, {int window = 5}) {
  if (points.length < 3) return points;
  final half = window ~/ 2;
  return [
    for (var i = 0; i < points.length; i++)
      (
        date: points[i].date,
        value: () {
          final lo = max(0, i - half), hi = min(points.length - 1, i + half);
          var s = 0.0;
          for (var k = lo; k <= hi; k++) {
            s += points[k].value;
          }
          return s / (hi - lo + 1);
        }(),
      ),
  ];
}

/// Fuel efficiency per calendar month within [range]: fuel and distance of the full-tank segments closing in
/// the month, so long and short segments weigh by their distance.
List<MonthValue> efficiencyByMonth(List<Entry> entries, Vehicle vehicle, DateRange range) {
  final volume = <DateTime, double>{}, distance = <DateTime, double>{};
  for (final s in fuelSegments(sortEntries(entries))) {
    final d = s.closingEntry.date;
    if (!range.contains(d) || s.distance <= 0) continue;
    volume[_month(d)] = (volume[_month(d)] ?? 0) + s.volume;
    distance[_month(d)] = (distance[_month(d)] ?? 0) + s.distance;
  }
  final months = volume.keys.toList()..sort();
  return [
    for (final m in months)
      if (efficiencyOf(volume[m]!, distance[m]!, vehicle) case final e?) (month: m, value: e),
  ];
}

/// Per-month low, average and high price of one volume unit (minor units) within [range].
List<({DateTime month, double low, double avg, double high})> priceByMonth(List<Entry> entries, DateRange range) {
  final byMonth = <DateTime, List<Entry>>{};
  for (final e in entries) {
    if (unitPrice(e) != null && range.contains(e.date)) byMonth.putIfAbsent(_month(e.date), () => []).add(e);
  }
  final months = byMonth.keys.toList()..sort();
  return [
    for (final m in months)
      () {
        final fills = byMonth[m]!;
        final prices = fills.map((e) => unitPrice(e)!);
        final cost = fills.fold(0, (a, e) => a + e.totalCost);
        final vol = fills.fold(0.0, (a, e) => a + e.volume!);
        return (month: m, low: prices.reduce(min), avg: cost / vol, high: prices.reduce(max));
      }(),
  ];
}

/// Fills grouped by station or fuel type.
class FuelGroup {
  const FuelGroup({required this.id, required this.fills, required this.volume, required this.cost, this.efficiency});

  /// Station or fuel type id; null for fills without one.
  final String? id;
  final int fills;
  final double volume;
  final int cost;

  /// Average efficiency of the full-tank segments closed at this station / with this fuel.
  final double? efficiency;

  double? get avgPrice => volume > 0 ? cost / volume : null;
}

List<FuelGroup> _fuelGroups(List<Entry> entries, Vehicle vehicle, DateRange range, String? Function(Entry) key) {
  final effById = fillEfficiencies(sortEntries(entries), vehicle);
  final groups = <String?, List<Entry>>{};
  for (final e in entries) {
    if (e.type == EntryType.fuel && range.contains(e.date)) groups.putIfAbsent(key(e), () => []).add(e);
  }
  return [
    for (final MapEntry(:key, :value) in groups.entries)
      FuelGroup(
        id: key,
        fills: value.length,
        volume: value.fold(0.0, (a, e) => a + (e.volume ?? 0)),
        cost: value.fold(0, (a, e) => a + e.totalCost),
        efficiency: () {
          final effs = [for (final e in value) ?effById[e.id]];
          return effs.isEmpty ? null : effs.reduce((a, b) => a + b) / effs.length;
        }(),
      ),
  ]..sort((a, b) => b.fills.compareTo(a.fills));
}

/// Fills per station within [range], most visited first.
List<FuelGroup> stationStats(List<Entry> entries, Vehicle vehicle, DateRange range) =>
    _fuelGroups(entries, vehicle, range, (e) => e.placeId);

/// Fills per fuel type within [range], most used first.
List<FuelGroup> fuelTypeStats(List<Entry> entries, Vehicle vehicle, DateRange range) =>
    _fuelGroups(entries, vehicle, range, (e) => e.fuelTypeId);

/// Extremes and habits of the fills within [range].
class FuelFacts {
  const FuelFacts({
    required this.fills,
    required this.partialFills,
    this.avgFill,
    this.cheapest,
    this.dearest,
    this.best,
    this.worst,
    this.rangePerTank,
  });

  final int fills;
  final int partialFills;

  /// Average volume of one fill.
  final double? avgFill;

  /// Fills with the lowest and highest unit price.
  final Entry? cheapest;
  final Entry? dearest;

  /// Closing fills of the most and least efficient segments, with their efficiency.
  final (Entry, double)? best;
  final (Entry, double)? worst;

  /// Average distance between two full-tank fills.
  final double? rangePerTank;
}

FuelFacts fuelFacts(List<Entry> entries, Vehicle vehicle, DateRange range) {
  final fills = entries.where((e) => e.type == EntryType.fuel && range.contains(e.date)).toList();
  final priced = fills.where((e) => unitPrice(e) != null).toList();
  final sorted = sortEntries(entries);
  final segments = fuelSegments(sorted).where((s) => range.contains(s.closingEntry.date) && s.distance > 0).toList();
  final effById = fillEfficiencies(sorted, vehicle);
  final rated = [for (final s in segments) if (effById[s.closingEntry.id] case final e?) (s.closingEntry, e)];
  final lowerIsBetter = vehicle.efficiencyUnit.lowerIsBetter;
  (Entry, double)? pick(bool best) => rated.isEmpty
      ? null
      : rated.reduce((a, b) => (best == lowerIsBetter ? b.$2 < a.$2 : b.$2 > a.$2) ? b : a);
  final volumes = fills.map((e) => e.volume ?? 0).where((v) => v > 0).toList();
  return FuelFacts(
    fills: fills.length,
    partialFills: fills.where((e) => !e.fullTank).length,
    avgFill: volumes.isEmpty ? null : volumes.reduce((a, b) => a + b) / volumes.length,
    cheapest: priced.isEmpty ? null : priced.reduce((a, b) => unitPrice(b)! < unitPrice(a)! ? b : a),
    dearest: priced.isEmpty ? null : priced.reduce((a, b) => unitPrice(b)! > unitPrice(a)! ? b : a),
    best: pick(true),
    worst: pick(false),
    rangePerTank: segments.isEmpty ? null : segments.fold(0, (a, s) => a + s.distance) / segments.length,
  );
}

// ---------------------------------------------------------------------------------------------------------
// Service

/// A service entry with the reminders it reset.
typedef ServiceEvent = ({Entry entry, List<String> reminderIds});

/// Service entries within [range], oldest first, with the reminders each one reset.
List<ServiceEvent> serviceEvents(List<Entry> entries, List<ReminderReset> resets, DateRange range) {
  final byEntry = <String, List<String>>{};
  for (final r in resets) {
    byEntry.putIfAbsent(r.entryId, () => []).add(r.reminderId);
  }
  return [
    for (final e in entries.where((e) => e.type == EntryType.service && range.contains(e.date)).toList()
      ..sort((a, b) => a.date.compareTo(b.date)))
      (entry: e, reminderIds: byEntry[e.id] ?? const []),
  ];
}

/// Service costs per calendar year within [range], oldest first.
List<({int year, int cost})> serviceCostByYear(List<Entry> entries, DateRange range) {
  final sums = <int, int>{};
  for (final e in entries) {
    if (e.type == EntryType.service && range.contains(e.date)) sums[e.date.year] = (sums[e.date.year] ?? 0) + e.totalCost;
  }
  final years = sums.keys.toList()..sort();
  return [for (final y in years) (year: y, cost: sums[y]!)];
}

/// The cost of the last service that reset [reminderId]; null when it was never done or was free.
int? lastServiceCost(String reminderId, List<Entry> entries, List<ReminderReset> resets) {
  final ids = {for (final r in resets) if (r.reminderId == reminderId) r.entryId};
  final done = entries.where((e) => ids.contains(e.id) && e.totalCost > 0).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return done.isEmpty ? null : done.first.totalCost;
}

// ---------------------------------------------------------------------------------------------------------
// Insights

/// A short finding about the period, rendered as one sentence.
sealed class Insight {
  const Insight();
}

/// One kind of cost made up most of the spending.
class CostShareInsight extends Insight {
  const CostShareInsight(this.slice, this.percent);

  final CostSlice slice;
  final int percent;
}

/// Spending changed noticeably compared with the previous period.
class CostChangeInsight extends Insight {
  const CostChangeInsight(this.percent);

  /// Positive: spent more.
  final int percent;
}

/// The latest full-tank segment was the best (or worst) in [count] segments.
class EfficiencyRecordInsight extends Insight {
  const EfficiencyRecordInsight({required this.best, required this.count});

  final bool best;
  final int count;
}

/// One station was cheaper than another on average.
class CheaperStationInsight extends Insight {
  const CheaperStationInsight({required this.cheaper, required this.dearer, required this.percent});

  final String cheaper;
  final String dearer;
  final int percent;
}

/// A reminder comes due soon; [cost] is what the last such service cost.
class UpcomingServiceInsight extends Insight {
  const UpcomingServiceInsight({required this.reminderName, required this.days, this.cost});

  final String reminderName;
  final int days;
  final int? cost;
}

/// Findings for the summary, most telling first.
List<Insight> findInsights({
  required List<Entry> entries,
  required Vehicle vehicle,
  required DateRange range,
  required IntervalStats current,
  IntervalStats? previous,
  List<({String name, int days, int? cost})> upcoming = const [],
}) {
  final out = <Insight>[];

  final soon = upcoming.where((u) => u.days <= 45).toList()..sort((a, b) => a.days.compareTo(b.days));
  if (soon.isNotEmpty) {
    out.add(UpcomingServiceInsight(reminderName: soon.first.name, days: soon.first.days, cost: soon.first.cost));
  }

  final sorted = sortEntries(entries);
  final effById = fillEfficiencies(sorted, vehicle);
  final effs = [for (final s in fuelSegments(sorted)) ?effById[s.closingEntry.id]];
  if (effs.length >= 6) {
    final last = effs.last, recent = effs.sublist(max(0, effs.length - 12));
    final lower = vehicle.efficiencyUnit.lowerIsBetter;
    final best = lower ? recent.reduce(min) : recent.reduce(max);
    final worst = lower ? recent.reduce(max) : recent.reduce(min);
    if (last == best) out.add(EfficiencyRecordInsight(best: true, count: recent.length));
    if (last == worst) out.add(EfficiencyRecordInsight(best: false, count: recent.length));
  }

  final change = relativeChange(current.totalCost, previous?.totalCost);
  if (change != null && change.abs() >= .15) out.add(CostChangeInsight((change * 100).round()));

  final slices = costBreakdown(entries, range);
  final total = slices.fold(0, (a, s) => a + s.cost);
  if (total > 0 && slices.first.cost / total >= .5) {
    out.add(CostShareInsight(slices.first, (slices.first.cost / total * 100).round()));
  }

  final stations = stationStats(entries, vehicle, range).where((s) => s.id != null && s.fills >= 3 && s.avgPrice != null).toList()
    ..sort((a, b) => a.avgPrice!.compareTo(b.avgPrice!));
  if (stations.length >= 2) {
    final diff = 1 - stations.first.avgPrice! / stations.last.avgPrice!;
    if (diff >= .02) {
      out.add(CheaperStationInsight(cheaper: stations.first.id!, dearer: stations.last.id!, percent: (diff * 100).round()));
    }
  }
  return out;
}

/// The odometer on [date] estimated from the reading before it and the average daily distance of the
/// 90 days up to that reading; null without a reading before [date] or recent driving. Never above
/// [upTo] (a later reading).
int? estimateOdometer(List<Entry> entries, DateTime date, {int? upTo}) {
  final day = _day(date);
  final before = entries.where((e) => !_day(e.date).isAfter(day)).toList();
  if (before.isEmpty) return null;
  final last = before.reduce((a, b) => b.odometer > a.odometer ? b : a);
  final days = day.difference(_day(last.date)).inDays;
  final perDay = recentDailyDistance(dailyDistance(before), last.date);
  if (days <= 0 || perDay == null) return null;
  var estimate = last.odometer + (perDay * days).round();
  if (upTo != null && estimate > upTo) estimate = upTo;
  return estimate > last.odometer ? estimate : null;
}
