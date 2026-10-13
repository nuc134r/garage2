import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/model/enums.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../dictionaries/data/dictionary_repository.dart';
import '../../entries/data/entry_repository.dart';
import '../../entries/presentation/entry_list_item.dart';
import '../../home/domain/home_tiles.dart';
import '../../home/presentation/home_tiles_view.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/stats_calculator.dart';
import 'stats_charts.dart';

enum StatsTab {
  fuel,
  expenses,
  mileage,
  service;

  /// The tab that explains a home tile's value.
  static StatsTab of(HomeMetric metric) => switch (metric) {
    HomeMetric.fuelCost || HomeMetric.efficiency || HomeMetric.fuelVolume || HomeMetric.fuelPrice => fuel,
    HomeMetric.totalCost || HomeMetric.otherCost || HomeMetric.costPerDistance => expenses,
    HomeMetric.odometer || HomeMetric.mileage => mileage,
    HomeMetric.serviceCost => service,
  };

  String label(AppLocalizations l10n) => switch (this) {
    fuel => l10n.entryTypeFuel,
    expenses => l10n.statExpenses,
    mileage => l10n.statMileage,
    service => l10n.entryTypeService,
  };
}

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key, required this.vehicleId, this.initialPeriod = StatsPeriod.allTime, this.focus});

  final String vehicleId;
  final StatsPeriod initialPeriod;

  /// The home tile that opened the screen; shown on top of its tab and flown in as a Hero.
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

  String _customLabel(AppLocalizations l10n) {
    final f = DateFormat.MMMd(l10n.localeName);
    final c = _custom!;
    return c.start == c.end ? f.format(c.start) : '${f.format(c.start)} – ${f.format(c.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicle = ref.watch(vehicleProvider(widget.vehicleId)).value;
    final entries = ref.watch(entriesProvider(widget.vehicleId)).value;
    final focus = widget.focus;

    return DefaultTabController(
      length: StatsTab.values.length,
      initialIndex: focus == null ? 0 : StatsTab.of(focus).index,
      child: Scaffold(
        appBar: AppBar(
          title: Text(vehicle == null ? l10n.statistics : l10n.statisticsFor(vehicle.name)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48 + 48),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
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
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [for (final t in StatsTab.values) Tab(text: t.label(l10n))],
                ),
              ],
            ),
          ),
        ),
        body: vehicle == null || entries == null
            ? const Center(child: CircularProgressIndicator())
            : _body(context, vehicle, entries),
      ),
    );
  }

  Widget _body(BuildContext context, Vehicle vehicle, List<Entry> entries) {
    final l10n = context.l10n;
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
            title: focus.label(l10n),
            period: _custom != null && focus.hasPeriod ? _customLabel(l10n) : tile.effectivePeriod.shortLabel(l10n),
            value: v.value,
            units: v.units,
          ),
        ),
      );
    }
    final data = _TabData(
      stats: stats,
      fmt: fmt,
      entries: entries,
      vehicle: vehicle,
      range: range,
      names: ref.watch(dictionaryNamesProvider).value ?? const {},
    );
    return TabBarView(
      children: [
        for (final tab in StatsTab.values)
          _TabBody(
            header: focus != null && StatsTab.of(focus) == tab ? header : null,
            empty: stats.entryCount == 0 ? l10n.noDataForPeriod : null,
            children: switch (tab) {
              StatsTab.fuel => data.fuel(context),
              StatsTab.expenses => data.expenses(context),
              StatsTab.mileage => data.mileage(context),
              StatsTab.service => data.service(context),
            },
          ),
      ],
    );
  }
}

/// One tab's scrollable content; keeps its scroll position while switching tabs.
class _TabBody extends StatefulWidget {
  const _TabBody({required this.children, this.header, this.empty});

  final List<Widget> children;
  final Widget? header;

  /// Shown instead of [children] when set.
  final String? empty;

  @override
  State<_TabBody> createState() => _TabBodyState();
}

class _TabBodyState extends State<_TabBody> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.empty != null) {
      final empty = EmptyState(icon: Icons.insights, text: widget.empty!);
      return widget.header == null
          ? empty
          : Column(
              children: [
                widget.header!,
                Expanded(child: empty),
              ],
            );
    }
    return ListView(padding: const EdgeInsets.only(top: 4, bottom: 24), children: [?widget.header, ...widget.children]);
  }
}

class _TabData {
  _TabData({
    required this.stats,
    required this.fmt,
    required this.entries,
    required this.vehicle,
    required this.range,
    required this.names,
  });

  final IntervalStats stats;
  final VehicleFormat fmt;
  final List<Entry> entries;
  final Vehicle vehicle;
  final DateRange range;
  final Map<String, String> names;

  String _opt(num? v, String Function(num) f) => v == null ? '—' : f(v);

  static Widget _chart(String title, Widget chart) => Island(
    title: title,
    children: [Padding(padding: const EdgeInsets.fromLTRB(12, 16, 16, 8), child: chart)],
  );

  List<Widget> fuel(BuildContext context) {
    final l10n = context.l10n;
    final s = stats;
    final efficiency = efficiencyTrend(entries, vehicle, range);
    final price = fuelPriceTrend(entries, range);
    return [
      Island(
        children: [
          ValueTile(label: l10n.statEfficiency, value: _opt(s.efficiency, (v) => fmt.efficiency(v.toDouble()))),
          ValueTile(label: l10n.refuels, value: fmt.number(s.fuelCount)),
          ValueTile(label: l10n.fuelVolumeTotal, value: fmt.volume(s.fuelVolume)),
          ValueTile(label: l10n.fuelCost, value: fmt.money(s.fuelCost)),
          ValueTile(
            label: l10n.avgFuelPrice,
            value: _opt(s.avgFuelUnitPrice, (v) => '${fmt.money(v)}/${fmt.volumeUnit}'),
          ),
          ValueTile(
            label: l10n.avgDistanceBetweenRefuels,
            value: _opt(s.avgDistanceBetweenRefuels, (v) => fmt.distance(v)),
          ),
          ValueTile(
            label: l10n.avgTimeBetweenRefuels,
            value: _opt(s.avgDaysBetweenRefuels, (v) => formatDays(l10n, v.round())),
          ),
        ],
      ),
      if (efficiency.length >= 2)
        _chart(
          '${l10n.chartEfficiency}, ${fmt.efficiencyUnit}',
          TrendChart(points: efficiency, format: (v) => fmt.number(v, maxDigits: 1), averageLabel: l10n.average),
        ),
      if (price.length >= 2)
        _chart(
          '${l10n.chartFuelPrice}, ${fmt.currencySymbol}/${fmt.volumeUnit}',
          TrendChart(points: price, format: (v) => fmt.moneyValue(v), averageLabel: l10n.average),
        ),
    ];
  }

  List<Widget> expenses(BuildContext context) {
    final l10n = context.l10n;
    final s = stats;
    final months = monthlyCosts(entries, range);
    final categories = expensesByCategory(entries, range);
    return [
      Island(
        children: [
          ValueTile(label: l10n.totalCost, value: fmt.money(s.totalCost)),
          ValueTile(label: l10n.fuelCost, value: fmt.money(s.fuelCost)),
          ValueTile(label: l10n.serviceCost, value: fmt.money(s.serviceCost)),
          ValueTile(label: l10n.otherCost, value: fmt.money(s.otherCost)),
          ValueTile(
            label: l10n.costPerDistance('${fmt.currencySymbol}/${fmt.distanceUnit}'),
            value: _opt(s.costPerDistance, (v) => fmt.money(v)),
          ),
        ],
      ),
      if (months.length >= 2)
        _chart('${l10n.chartMonthlyCosts}, ${fmt.currencySymbol}', MonthlyCostsChart(months: months, fmt: fmt)),
      if (categories.isNotEmpty)
        Island(
          title: '${l10n.otherCost} · ${l10n.byCategory}',
          children: [
            for (final (id, cost) in categories)
              ValueTile(label: names[id] ?? l10n.uncategorized, value: fmt.money(cost)),
          ],
        ),
    ];
  }

  List<Widget> mileage(BuildContext context) {
    final l10n = context.l10n;
    final s = stats;
    final odometer = odometerTrend(entries, range);
    return [
      Island(
        children: [
          ValueTile(label: l10n.mileageRecorded, value: fmt.distance(s.mileage)),
          ValueTile(label: l10n.avgDaily, value: _opt(s.avgDailyMileage, (v) => fmt.distance(v))),
          ValueTile(label: l10n.avgMonthly, value: _opt(s.avgMonthlyMileage, (v) => fmt.distance(v))),
          ValueTile(label: l10n.avgYearly, value: _opt(s.avgYearlyMileage, (v) => fmt.distance(v))),
        ],
      ),
      if (odometer.length >= 2)
        _chart(
          '${l10n.chartOdometer}, ${fmt.distanceUnit}',
          TrendChart(points: odometer, format: (v) => fmt.compactNumber(v)),
        ),
      Island(
        title: l10n.general,
        children: [
          ValueTile(label: l10n.entries, value: fmt.number(s.entryCount)),
          ValueTile(label: l10n.trackedPeriod, value: formatDays(l10n, s.trackedDays)),
          if (s.firstDate != null) ValueTile(label: l10n.firstRecord, value: fmt.date(s.firstDate!)),
        ],
      ),
    ];
  }

  List<Widget> service(BuildContext context) {
    final l10n = context.l10n;
    final s = stats;
    final services = entries.where((e) => e.type == EntryType.service && range.contains(e.date)).toList().reversed;
    return [
      Island(
        children: [
          ValueTile(label: l10n.services, value: fmt.number(s.serviceCount)),
          ValueTile(label: l10n.serviceCost, value: fmt.money(s.serviceCost)),
          ValueTile(
            label: l10n.avgDistanceBetweenServices,
            value: _opt(s.avgDistanceBetweenServices, (v) => fmt.distance(v)),
          ),
          ValueTile(
            label: l10n.avgTimeBetweenServices,
            value: _opt(s.avgDaysBetweenServices, (v) => formatDays(l10n, v.round())),
          ),
        ],
      ),
      Island(
        title: l10n.history,
        children: [
          if (services.isEmpty) ListTile(title: Text(l10n.noServicesForPeriod)),
          for (final e in services)
            EntryListItem(entry: e, fmt: fmt, names: names, onTap: () => context.push(Routes.entry(vehicle.id, e.id))),
        ],
      ),
    ];
  }
}
