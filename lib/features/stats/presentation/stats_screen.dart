import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../../core/db/database.dart';
import '../../entries/data/entry_repository.dart';
import '../../home/domain/home_tiles.dart';
import '../../home/presentation/home_tiles_view.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/stats_calculator.dart';
import 'stats_charts.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key, required this.vehicleId, this.initialPeriod = StatsPeriod.allTime, this.focus});

  final String vehicleId;
  final StatsPeriod initialPeriod;

  /// The home tile that opened the screen; shown on top and flown in as a Hero.
  final HomeMetric? focus;

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late StatsPeriod _period = widget.initialPeriod;

  /// Set when the user picked their own dates; overrides [_period].
  DateTimeRange? _custom;

  DateRange get _range => _custom == null ? _period.range : DateRange.days(_custom!.start, _custom!.end);

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1950),
      lastDate: now,
      initialDateRange: _custom ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
    );
    if (picked != null) setState(() => _custom = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicle = ref.watch(vehicleProvider(widget.vehicleId)).value;
    final entries = ref.watch(entriesProvider(widget.vehicleId)).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle == null ? l10n.statistics : l10n.statisticsFor(vehicle.name)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                for (final p in StatsPeriod.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.label(l10n)),
                      selected: _custom == null && p == _period,
                      onSelected: (_) => setState(() {
                        _period = p;
                        _custom = null;
                      }),
                    ),
                  ),
                ChoiceChip(
                  avatar: _custom == null ? const Icon(Icons.date_range, size: 18) : null,
                  label: Text(_custom == null ? l10n.periodCustom : _customLabel(l10n)),
                  selected: _custom != null,
                  onSelected: (_) => _pickRange(),
                ),
              ],
            ),
          ),
        ),
      ),
      body: vehicle == null || entries == null
          ? const Center(child: CircularProgressIndicator())
          : _body(context, vehicle, entries),
    );
  }

  Widget _body(BuildContext context, Vehicle vehicle, List<Entry> entries) {
    final fmt = VehicleFormat.of(context, vehicle);
    final range = _range;
    final stats = computeStats(entries, vehicle, range);
    final focus = widget.focus;
    Widget? header;
    if (focus != null) {
      final tile = HomeTile(focus, _period);
      final v = homeTileValue(tile, stats, currentOdometer(entries, vehicle), fmt);
      header = Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Hero(
          tag: HeroTags.statTile(HomeTile(focus, widget.initialPeriod)),
          child: StatTile(
            title: focus.label(context.l10n),
            period: _custom != null && focus.hasPeriod ? _customLabel(context.l10n) : tile.effectivePeriod.shortLabel(context.l10n),
            value: v.value,
            units: v.units,
          ),
        ),
      );
    }
    return _StatsBody(
      stats: stats,
      fmt: fmt,
      header: header,
      months: monthlyCosts(entries, range),
      efficiency: efficiencyTrend(entries, vehicle, range),
      fuelPrice: fuelPriceTrend(entries, range),
    );
  }

  String _customLabel(AppLocalizations l10n) {
    final f = DateFormat.MMMd(l10n.localeName);
    final c = _custom!;
    return c.start == c.end ? f.format(c.start) : '${f.format(c.start)} – ${f.format(c.end)}';
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({
    required this.stats,
    required this.fmt,
    this.header,
    this.months = const [],
    this.efficiency = const [],
    this.fuelPrice = const [],
  });

  final IntervalStats stats;
  final VehicleFormat fmt;
  final Widget? header;
  final List<MonthCosts> months;
  final List<TrendPoint> efficiency;
  final List<TrendPoint> fuelPrice;

  static Widget _chart(String title, Widget chart) => Island(
        title: title,
        children: [Padding(padding: const EdgeInsets.fromLTRB(12, 16, 16, 8), child: chart)],
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = stats;
    if (s.entryCount == 0) {
      final empty = EmptyState(icon: Icons.insights, text: l10n.noDataForPeriod);
      return header == null ? empty : Column(children: [header!, Expanded(child: empty)]);
    }
    String opt(num? v, String Function(num) f) => v == null ? '—' : f(v);
    final perDistance = '${fmt.currencySymbol}/${fmt.distanceUnit}';

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ?header,
        if (months.length >= 2) _chart('${l10n.chartMonthlyCosts}, ${fmt.currencySymbol}', MonthlyCostsChart(months: months, fmt: fmt)),
        Island(
          title: l10n.general,
          children: [
            ValueTile(label: l10n.entries, value: fmt.number(s.entryCount)),
            ValueTile(label: l10n.trackedPeriod, value: formatDays(l10n, s.trackedDays)),
            if (s.firstDate != null) ValueTile(label: l10n.firstRecord, value: fmt.date(s.firstDate!)),
          ],
        ),
        Island(
          title: l10n.statMileage,
          children: [
            ValueTile(label: l10n.mileageRecorded, value: fmt.distance(s.mileage)),
            ValueTile(label: l10n.avgDaily, value: opt(s.avgDailyMileage, (v) => fmt.distance(v))),
            ValueTile(label: l10n.avgMonthly, value: opt(s.avgMonthlyMileage, (v) => fmt.distance(v))),
            ValueTile(label: l10n.avgYearly, value: opt(s.avgYearlyMileage, (v) => fmt.distance(v))),
          ],
        ),
        Island(
          title: l10n.entryTypeFuel,
          children: [
            ValueTile(label: l10n.statEfficiency, value: opt(s.efficiency, (v) => fmt.efficiency(v.toDouble()))),
            ValueTile(label: l10n.refuels, value: fmt.number(s.fuelCount)),
            ValueTile(label: l10n.fuelVolumeTotal, value: fmt.volume(s.fuelVolume)),
            ValueTile(label: l10n.fuelCost, value: fmt.money(s.fuelCost)),
            ValueTile(label: l10n.avgFuelPrice, value: opt(s.avgFuelUnitPrice, (v) => '${fmt.money(v)}/${fmt.volumeUnit}')),
            ValueTile(label: l10n.avgDistanceBetweenRefuels, value: opt(s.avgDistanceBetweenRefuels, (v) => fmt.distance(v))),
            ValueTile(label: l10n.avgTimeBetweenRefuels, value: opt(s.avgDaysBetweenRefuels, (v) => formatDays(l10n, v.round()))),
          ],
        ),
        if (efficiency.length >= 2)
          _chart(
            '${l10n.chartEfficiency}, ${fmt.efficiencyUnit}',
            TrendChart(points: efficiency, format: (v) => fmt.number(v, maxDigits: 1), averageLabel: l10n.average),
          ),
        if (fuelPrice.length >= 2)
          _chart(
            '${l10n.chartFuelPrice}, ${fmt.currencySymbol}/${fmt.volumeUnit}',
            TrendChart(points: fuelPrice, format: (v) => fmt.moneyValue(v), averageLabel: l10n.average),
          ),
        Island(
          title: l10n.statExpenses,
          children: [
            ValueTile(label: l10n.totalCost, value: fmt.money(s.totalCost)),
            ValueTile(label: l10n.fuelCost, value: fmt.money(s.fuelCost)),
            ValueTile(label: l10n.serviceCost, value: fmt.money(s.serviceCost)),
            ValueTile(label: l10n.otherCost, value: fmt.money(s.otherCost)),
            ValueTile(label: l10n.costPerDistance(perDistance), value: opt(s.costPerDistance, (v) => fmt.money(v))),
            ValueTile(label: l10n.services, value: fmt.number(s.serviceCount)),
            ValueTile(label: l10n.avgDistanceBetweenServices, value: opt(s.avgDistanceBetweenServices, (v) => fmt.distance(v))),
            ValueTile(label: l10n.avgTimeBetweenServices, value: opt(s.avgDaysBetweenServices, (v) => formatDays(l10n, v.round()))),
          ],
        ),
      ],
    );
  }
}
