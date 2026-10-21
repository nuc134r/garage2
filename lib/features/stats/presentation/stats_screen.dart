import 'dart:math';

import 'package:clock/clock.dart';
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
import '../../reminders/data/reminder_repository.dart';
import '../../reminders/domain/notification_plan.dart' show daysUntilDue;
import '../../reminders/domain/reminder_status.dart';
import '../../reminders/presentation/reminder_tile.dart' show reminderStatusText;
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/stats_analysis.dart';
import '../domain/stats_calculator.dart';
import 'stats_charts.dart';

enum StatsTab {
  costs,
  driving,
  fuel,
  service;

  /// The tab that explains a home tile's value.
  static StatsTab of(HomeMetric metric) => switch (metric) {
    HomeMetric.fuelCost || HomeMetric.efficiency || HomeMetric.fuelVolume || HomeMetric.fuelPrice => fuel,
    HomeMetric.totalCost || HomeMetric.otherCost || HomeMetric.costPerDistance => costs,
    HomeMetric.odometer || HomeMetric.mileage => driving,
    HomeMetric.serviceCost => service,
  };

  String label(AppLocalizations l10n, {bool electric = false}) => switch (this) {
    costs => l10n.statsTabCosts,
    driving => l10n.statsTabDriving,
    fuel => electric ? l10n.entryTypeCharging : l10n.entryTypeFuel,
    service => l10n.entryTypeService,
  };
}

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key, required this.vehicleId, this.initialPeriod = StatsPeriod.allTime, this.focus});

  final String vehicleId;
  final StatsPeriod initialPeriod;

  /// The home tile that opened the screen; the screen opens on the tab that explains it.
  final HomeMetric? focus;

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late StatsPeriod _period = widget.initialPeriod;

  /// A calendar year picked from the chips; overrides [_period].
  int? _year;

  /// Set when the user picked their own dates; overrides [_period] and [_year].
  DateTimeRange? _custom;

  DateRange get _range => _custom != null
      ? DateRange.days(_custom!.start, _custom!.end)
      : _year != null
          ? calendarYear(_year!, clock.now())
          : _period.range;

  Future<void> _pickRange() async {
    final now = clock.now();
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
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    final focus = widget.focus;
    final electric = vehicle?.volumeUnit.isEnergy ?? false;

    return DefaultTabController(
      length: StatsTab.values.length,
      initialIndex: focus == null ? 0 : StatsTab.of(focus).index,
      child: Scaffold(
        appBar: AppBar(
          title: Text(vehicle == null ? l10n.statistics : l10n.statisticsFor(vehicle.name)),
          actions: [
            if (vehicles.length >= 2)
              IconButton(
                icon: const Icon(Icons.compare_arrows),
                tooltip: l10n.compareVehicles,
                onPressed: () => context.push(Routes.compareVehicles(widget.vehicleId)),
              ),
          ],
        ),
        body: vehicle == null || entries == null
            ? const Center(child: CircularProgressIndicator())
            : _body(context, vehicle, entries, electric),
      ),
    );
  }

  Widget _periodChips(BuildContext context, List<Entry> entries) {
    final l10n = context.l10n;
    final years = yearsWithEntries(entries);
    Widget chip(String label, bool selected, VoidCallback onTap, {Widget? avatar}) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(label: Text(label), avatar: avatar, selected: selected, onSelected: (_) => onTap()),
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Row(
        children: [
          for (final p in StatsPeriod.values)
            chip(p.label(l10n), _custom == null && _year == null && p == _period, () => setState(() {
                  _period = p;
                  _year = null;
                  _custom = null;
                })),
          if (years.length > 1 || (years.isNotEmpty && years.first != clock.now().year))
            for (final y in years)
              chip('$y', _custom == null && _year == y, () => setState(() {
                    _year = y;
                    _custom = null;
                  })),
          chip(
            _custom == null ? l10n.periodCustom : _customLabel(l10n),
            _custom != null,
            _pickRange,
            avatar: _custom == null ? const Icon(Icons.date_range, size: 18) : null,
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, Vehicle vehicle, List<Entry> entries, bool electric) {
    final l10n = context.l10n;
    final fmt = VehicleFormat.of(context, vehicle);
    final range = _range;
    final data = StatsData(
      vehicle: vehicle,
      entries: entries,
      range: range,
      fmt: fmt,
      names: ref.watch(dictionaryNamesProvider).value ?? const {},
      resets: ref.watch(reminderResetsProvider(vehicle.id)).value ?? const [],
      reminders: ref.watch(reminderStatusesProvider(vehicle.id)).value ?? const [],
    );
    final empty = data.current.entryCount == 0 ? l10n.noDataForPeriod : null;
    final tabs = _TabContent(data);
    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverToBoxAdapter(child: _periodChips(context, entries)),
        if (empty == null) SliverToBoxAdapter(child: SummaryCard(data: data)),
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarHeader(
              TabBar(tabs: [for (final t in StatsTab.values) Tab(text: t.label(l10n, electric: electric))]),
              Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
      ],
      body: TabBarView(
        children: [
          for (final tab in StatsTab.values)
            _TabBody(
              key: PageStorageKey(tab),
              empty: empty,
              children: empty != null
                  ? const []
                  : switch (tab) {
                      StatsTab.costs => tabs.costs(context),
                      StatsTab.driving => tabs.driving(context),
                      StatsTab.fuel => tabs.fuel(context),
                      StatsTab.service => tabs.service(context),
                    },
            ),
        ],
      ),
    );
  }
}

class _TabBarHeader extends SliverPersistentHeaderDelegate {
  _TabBarHeader(this.tabBar, this.background);

  final TabBar tabBar;
  final Color background;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Material(
        color: background,
        elevation: overlapsContent || shrinkOffset > 0 ? 2 : 0,
        child: tabBar,
      );

  @override
  bool shouldRebuild(_TabBarHeader old) => old.tabBar != tabBar || old.background != background;
}

/// One tab's scrollable content inside the [NestedScrollView]; keeps its position while switching tabs.
class _TabBody extends StatefulWidget {
  const _TabBody({super.key, required this.children, this.empty});

  final List<Widget> children;

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
    return Builder(
      builder: (context) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
          if (widget.empty != null)
            SliverFillRemaining(hasScrollBody: false, child: EmptyState(icon: Icons.insights, text: widget.empty!))
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              sliver: SliverList.list(children: widget.children),
            ),
        ],
      ),
    );
  }
}

/// Everything the summary and the tabs show for one vehicle and period, computed once per build.
class StatsData {
  StatsData({
    required this.vehicle,
    required this.entries,
    required this.range,
    required this.fmt,
    required this.names,
    required this.resets,
    required this.reminders,
  });

  final Vehicle vehicle;
  final List<Entry> entries;
  final DateRange range;
  final VehicleFormat fmt;

  /// Dictionary names (stations, fuel types, categories) by id.
  final Map<String, String> names;
  final List<ReminderReset> resets;
  final List<ReminderStatus> reminders;

  late final DateTime now = clock.now();
  /// The period compared with; null for all time.
  late final DateRange? comparedRange = previousRange(range);
  late final IntervalStats current = computeStats(entries, vehicle, range);
  late final IntervalStats? previous = () {
    final p = comparedRange;
    if (p == null) return null;
    final s = computeStats(entries, vehicle, p);
    return s.entryCount == 0 ? null : s;
  }();
  late final Map<DateTime, double> daily = dailyDistance(entries);
  late final double distance = distanceIn(daily, range);
  late final double? previousDistance = previous == null ? null : distanceIn(daily, comparedRange!);
  late final double months = monthsIn(range, entries);

  /// Length of the period in days; for all time, the span of the entries.
  late final double days = () {
    final from = range.from, to = range.to;
    if (from != null && to != null) return max(1.0, to.difference(from).inHours / 24);
    return max(1.0, current.trackedDays.toDouble());
  }();

  /// First day of the period (all time: the first entry).
  late final DateTime start = range.from ?? current.firstDate ?? now;

  double? get costPerDistance => distance > 0 ? current.totalCost / distance : null;
  double? get previousCostPerDistance =>
      previous == null || (previousDistance ?? 0) <= 0 ? null : previous!.totalCost / previousDistance!;

  /// Reminders with the days until due and what the last such service cost, soonest first.
  late final List<({ReminderStatus status, int? days, int? cost})> upcoming = [
    for (final s in reminders)
      (status: s, days: daysUntilDue(s), cost: lastServiceCost(s.reminder.id, entries, resets)),
  ]..sort((a, b) => (a.days ?? 1 << 30).compareTo(b.days ?? 1 << 30));

  late final List<Insight> insights = findInsights(
    entries: entries,
    vehicle: vehicle,
    range: range,
    current: current,
    previous: previous,
    upcoming: [
      for (final u in upcoming)
        if (u.days != null) (name: u.status.reminder.name, days: u.days!, cost: u.cost),
    ],
  );

  String comparisonLabel(AppLocalizations l10n) =>
      isCalendarYear(range) ? l10n.vsYear('${range.from!.year - 1}') : l10n.vsPrevious;

  String costName(AppLocalizations l10n, CostSlice s) => switch (s.kind) {
    CostKind.fuel => fmt.isElectric ? l10n.entryTypeCharging : l10n.fuelCost,
    CostKind.service => l10n.serviceCost,
    CostKind.expense => names[s.categoryId] ?? l10n.uncategorized,
  };
}

/// "↑ 12 %" — red when it got worse, green when better, grey when neither applies.
class Delta extends StatelessWidget {
  const Delta(this.change, {super.key, this.lowerIsBetter, this.suffix});

  final double change;

  /// Null: the direction is neither good nor bad (e.g. distance).
  final bool? lowerIsBetter;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final percent = (change.abs() * 100).round();
    final good = lowerIsBetter == null ? null : (lowerIsBetter! ? change < 0 : change > 0);
    final color = percent == 0 || good == null
        ? theme.colorScheme.onSurfaceVariant
        : good
            ? (dark ? const Color(0xFF5BD69B) : const Color(0xFF1B7F4E))
            : (dark ? const Color(0xFFFF8A80) : const Color(0xFFC62828));
    return Text.rich(
      TextSpan(
        children: [
          if (percent != 0)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(change > 0 ? Icons.arrow_upward : Icons.arrow_downward, size: 13, color: color),
            ),
          TextSpan(text: ' $percent %${suffix == null ? '' : ' $suffix'}'),
        ],
      ),
      style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}

/// The top of the statistics: cost of ownership with its change, three key figures with trends, and findings.
class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.data});

  final StatsData data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final d = data, fmt = d.fmt, c = d.current, p = d.previous;
    final change = relativeChange(c.totalCost, p?.totalCost);
    final lowerIsBetter = d.vehicle.efficiencyUnit.lowerIsBetter;
    final sparkRange = DateRange(from: DateTime(d.now.year - 1, d.now.month), to: d.range.to ?? d.now);
    final within = d.range.from == null || d.range.from!.isBefore(sparkRange.from!) ? sparkRange : d.range;

    Widget kpi(String label, String value, double? change, List<double> spark, {bool? lowerIsBetter}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant), maxLines: 1),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: theme.textTheme.titleSmall, maxLines: 1),
              ),
              const SizedBox(height: 4),
              SizedBox(height: 22, child: Sparkline(spark)),
              const SizedBox(height: 2),
              if (change != null) Delta(change, lowerIsBetter: lowerIsBetter) else const Text(''),
            ],
          ),
        );

    // The change in spending is already next to the total.
    final sentences = [for (final i in d.insights.where((i) => i is! CostChangeInsight).take(2)) insightText(l10n, d, i)];
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      color: Color.alphaBlend(
        scheme.primaryContainer.withValues(alpha: theme.brightness == Brightness.dark ? .45 : .6),
        theme.cardTheme.color ?? scheme.surfaceContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.costOfOwnership, style: theme.textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              children: [
                Text(fmt.shortMoney(c.totalCost), style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w500)),
                if (change != null) Delta(change, lowerIsBetter: true, suffix: d.comparisonLabel(l10n)),
              ],
            ),
            Text(
              l10n.perMonthValue(fmt.shortMoney(c.totalCost / d.months)),
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                kpi(
                  l10n.perDistanceUnit(fmt.distanceUnit),
                  d.costPerDistance == null ? '—' : fmt.shortMoney(d.costPerDistance!),
                  relativeChange(d.costPerDistance, d.previousCostPerDistance),
                  [for (final p in costPerDistanceByMonth(d.entries, d.daily, within)) p.value],
                  lowerIsBetter: true,
                ),
                const SizedBox(width: 12),
                kpi(
                  l10n.statDistance,
                  fmt.shortDistance(d.distance),
                  relativeChange(d.distance, d.previousDistance),
                  [for (final m in monthlyDistance(d.daily, within)) m.value],
                ),
                const SizedBox(width: 12),
                kpi(
                  l10n.statEfficiency,
                  c.efficiency == null ? '—' : fmt.efficiency(c.efficiency!),
                  relativeChange(c.efficiency, p?.efficiency),
                  [for (final m in efficiencyByMonth(d.entries, d.vehicle, within)) m.value],
                  lowerIsBetter: lowerIsBetter,
                ),
              ],
            ),
            if (sentences.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: .55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb, size: 18, color: scheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(sentences.join(' '), style: theme.textTheme.bodySmall)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _when(AppLocalizations l10n, int days) => days <= 0
    ? (days == 0 ? l10n.dueToday : l10n.overdueBy(formatDays(l10n, -days)))
    : l10n.dueIn(formatDays(l10n, days));

/// One finding as a sentence.
String insightText(AppLocalizations l10n, StatsData d, Insight insight) => switch (insight) {
  CostShareInsight(:final slice, :final percent) => l10n.insightCostShare(d.costName(l10n, slice), '$percent'),
  CostChangeInsight(:final percent) =>
    percent > 0 ? l10n.insightSpentMore('$percent') : l10n.insightSpentLess('${-percent}'),
  EfficiencyRecordInsight(:final best, :final count) =>
    best ? l10n.insightBestEfficiency(count) : l10n.insightWorstEfficiency(count),
  CheaperStationInsight(:final cheaper, :final dearer, :final percent) =>
    l10n.insightCheaperStation(d.names[cheaper] ?? '?', '$percent', d.names[dearer] ?? '?'),
  UpcomingServiceInsight(:final reminderName, :final days, :final cost) => cost == null
      ? l10n.insightUpcoming(reminderName, _when(l10n, days))
      : l10n.insightUpcomingCost(reminderName, _when(l10n, days), d.fmt.shortMoney(cost)),
};

/// Builders for the four tabs.
class _TabContent {
  _TabContent(this.d);

  final StatsData d;

  VehicleFormat get fmt => d.fmt;

  static Widget _section(BuildContext context, String title, Widget chart, {String? caption}) {
    final theme = Theme.of(context);
    return Island(
      title: title,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (caption != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 10),
                  child: Text(
                    caption,
                    style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              chart,
            ],
          ),
        ),
      ],
    );
  }

  String _opt(num? v, String Function(num) f) => v == null ? '—' : f(v);

  // ----------------------------------------------------------------------------------------------- Costs

  List<Widget> costs(BuildContext context) {
    final l10n = context.l10n;
    final palette = chartPalette(Theme.of(context).brightness);
    final months = monthlyCosts(d.entries, d.range);
    final slices = costBreakdown(d.entries, d.range);
    final perDistance = costPerDistanceByMonth(d.entries, d.daily, d.range);
    final projected = projectedYearCost(d.entries, d.now);
    final nextServices = [
      for (final u in d.upcoming)
        if (u.days != null && u.days! <= 90 && u.cost != null) u,
    ];
    // Fuel and service keep their colours from the monthly chart; categories take the rest in turn.
    var nextCategory = 0;
    Color colorOf(CostSlice s) => switch (s.kind) {
      CostKind.fuel => palette[0],
      CostKind.service => palette[1],
      CostKind.expense => palette[2 + nextCategory++ % (palette.length - 2)],
    };
    return [
      if (months.length >= 2)
        _section(
          context,
          '${l10n.chartMonthlyCosts}, ${fmt.currencySymbol}',
          MonthlyCostsChart(months: months, fmt: fmt, averageLabel: l10n.average),
        ),
      if (slices.isNotEmpty)
        _section(
          context,
          l10n.whereMoneyGoes,
          DonutChart(
            slices: [for (final s in slices) (label: d.costName(l10n, s), value: s.cost, color: colorOf(s))],
            format: fmt.shortMoney,
            total: fmt.shortMoney(d.current.totalCost),
            totalLabel: l10n.periodTotal,
          ),
        ),
      if (perDistance.length >= 2)
        _section(
          context,
          l10n.chartCostPerDistance(fmt.distanceUnit),
          TrendChart(points: perDistance, format: (v) => fmt.shortMoney(v), averageLabel: l10n.average),
          caption: l10n.costPerDistanceHint,
        ),
      if (d.previous != null && d.current.totalCost > 0)
        _section(
          context,
          l10n.chartSpendingVsPrevious,
          CumulativeChart(
            current: cumulativeCosts(d.entries, d.range),
            previous: cumulativeCosts(d.entries, d.comparedRange!),
            start: d.start,
            days: d.days,
            format: fmt.shortMoney,
            axisFormat: fmt.compactMoney,
            currentLabel: l10n.thisPeriod,
            previousLabel: l10n.previousPeriod,
          ),
          caption: l10n.runningTotalHint,
        ),
      Island(
        title: l10n.outlook,
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text(l10n.perMonthValue(fmt.shortMoney(d.current.totalCost / d.months))),
            subtitle: Text(l10n.avgInPeriod),
          ),
          if (projected != null)
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: Text(l10n.projectedYear(fmt.shortMoney(projected), '${d.now.year}')),
              subtitle: Text(l10n.projectedYearHint),
            ),
          for (final u in nextServices)
            ListTile(
              leading: const Icon(Icons.build),
              title: Text(l10n.expectedService(fmt.shortMoney(u.cost!), u.status.reminder.name)),
              subtitle: Text(reminderStatusText(fmt, u.status)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.reminder(d.vehicle.id, u.status.reminder.id)),
            ),
        ],
      ),
    ];
  }

  // --------------------------------------------------------------------------------------------- Driving

  List<Widget> driving(BuildContext context) {
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final months = monthlyDistance(d.daily, d.range);
    final busiest = busiestMonth(months);
    final weekdays = weekdayAverages(d.daily, d.range);
    final odometer = odometerTrend(d.entries, d.range);
    final milestone = nextMilestone(
      currentOdometer(d.entries, d.vehicle),
      recentDailyDistance(d.daily, d.now),
      d.now,
      step: d.vehicle.distanceUnit == DistanceUnit.mi ? 5000 : 10000,
    );
    final gap = longestGap(d.entries, d.range);
    final perDay = d.distance / d.days;
    final monday = DateTime(2024, 1, 1);
    return [
      if (months.length >= 2)
        _section(
          context,
          l10n.chartDistanceByMonth(fmt.distanceUnit),
          ColumnsChart(
            bars: [
              for (final m in months)
                (
                  label: DateFormat.MMM(locale).format(m.month),
                  title: DateFormat.yMMMM(locale).format(m.month),
                  value: m.value,
                ),
            ],
            format: (v) => fmt.compactNumber(v),
            averageLabel: l10n.average,
            highlight: busiest == null ? null : months.indexOf(busiest),
          ),
        ),
      if (d.days >= 14 && d.distance > 0)
        _section(
          context,
          l10n.chartByWeekday(fmt.distanceUnit),
          ColumnsChart(
            height: 150,
            bars: [
              for (var i = 0; i < 7; i++)
                (
                  label: DateFormat.E(locale).format(monday.add(Duration(days: i))),
                  title: DateFormat.EEEE(locale).format(monday.add(Duration(days: i))),
                  value: weekdays[i],
                ),
            ],
            format: (v) => fmt.number(v),
            highlight: weekdays.indexOf(weekdays.reduce(max)),
          ),
        ),
      if (odometer.length >= 2)
        _section(
          context,
          '${l10n.chartOdometer}, ${fmt.distanceUnit}',
          TrendChart(points: odometer, format: (v) => fmt.compactNumber(v)),
        ),
      if (milestone != null)
        Island(
          title: l10n.outlook,
          children: [
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(l10n.milestone(fmt.shortDistance(milestone.odometer), DateFormat.yMMM(locale).format(milestone.date))),
              subtitle: Text(l10n.milestoneHint),
            ),
          ],
        ),
      Island(
        children: [
          ValueTile(label: l10n.mileageRecorded, value: fmt.shortDistance(d.distance)),
          ValueTile(label: l10n.avgDaily, value: fmt.shortDistance(perDay)),
          ValueTile(label: l10n.avgWeekly, value: fmt.shortDistance(perDay * 7)),
          ValueTile(label: l10n.avgMonthly, value: fmt.shortDistance(perDay * 30.44)),
          ValueTile(label: l10n.avgYearly, value: fmt.shortDistance(perDay * 365)),
          if (busiest != null && months.length >= 2)
            ValueTile(
              label: l10n.busiestMonth,
              value: '${DateFormat.yMMM(locale).format(busiest.month)} · ${fmt.shortDistance(busiest.value)}',
            ),
          if (gap != null) ValueTile(label: l10n.longestGap, value: formatDays(l10n, gap)),
        ],
      ),
      Island(
        title: l10n.general,
        children: [
          ValueTile(label: l10n.entries, value: fmt.number(d.current.entryCount)),
          ValueTile(label: l10n.trackedPeriod, value: formatDays(l10n, d.current.trackedDays)),
          if (d.current.firstDate != null) ValueTile(label: l10n.firstRecord, value: fmt.date(d.current.firstDate!)),
        ],
      ),
    ];
  }

  // ------------------------------------------------------------------------------------------------ Fuel

  List<Widget> fuel(BuildContext context) {
    final l10n = context.l10n;
    final electric = fmt.isElectric;
    final s = d.current;
    final sorted = sortEntries(d.entries);
    final effById = fillEfficiencies(sorted, d.vehicle);
    final rated = [
      for (final e in sorted)
        if (effById[e.id] != null && d.range.contains(e.date)) e,
    ]..sort((a, b) => a.date.compareTo(b.date));
    final points = [for (final e in rated) (date: e.date, value: effById[e.id]!)];
    final byMonth = efficiencyByMonth(d.entries, d.vehicle, d.range);
    final prices = priceByMonth(d.entries, d.range);
    final stations = stationStats(d.entries, d.vehicle, d.range);
    final types = fuelTypeStats(d.entries, d.vehicle, d.range);
    final facts = fuelFacts(d.entries, d.vehicle, d.range);
    final unitPriceLabel = '${fmt.currencySymbol}/${fmt.volumeUnit}';
    void open(Entry e) => context.push(Routes.entry(d.vehicle.id, e.id));

    /// A record fill: what it was, when, and its value; opens the entry.
    Widget record(String label, String value, Entry e) => ListTile(
          title: Text(label),
          subtitle: Text(fmt.date(e.date)),
          trailing: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          onTap: () => open(e),
        );

    Widget group(FuelGroup g, String fallback) => ListTile(
          title: Text(d.names[g.id] ?? fallback),
          subtitle: Text([
            l10n.visitsCount(g.fills),
            if (g.avgPrice != null) '${fmt.shortMoney(g.avgPrice!)}/${fmt.volumeUnit}',
            if (g.efficiency != null) fmt.efficiency(g.efficiency!),
          ].join(' · ')),
          trailing: Text(fmt.shortMoney(g.cost), style: Theme.of(context).textTheme.bodyMedium),
        );

    return [
      if (points.length >= 3)
        _section(
          context,
          (electric ? l10n.chartEfficiencyPerCharge : l10n.chartEfficiencyPerFill)(fmt.efficiencyUnit),
          ScatterTrendChart(
            points: points,
            trend: movingAverage(points),
            format: (v) => fmt.number(v, maxDigits: 1),
            averageLabel: l10n.average,
            onTap: (i) => open(rated[i]),
          ),
        ),
      if (byMonth.length >= 2)
        _section(
          context,
          l10n.chartEfficiencyByMonth(fmt.efficiencyUnit),
          ColumnsChart(
            height: 160,
            bars: [
              for (final m in byMonth)
                (
                  label: DateFormat.MMM(l10n.localeName).format(m.month),
                  title: DateFormat.yMMMM(l10n.localeName).format(m.month),
                  value: m.value,
                ),
            ],
            format: (v) => fmt.number(v, maxDigits: 1),
            fromZero: false,
          ),
        ),
      if (prices.length >= 2)
        _section(
          context,
          l10n.chartPricePaid(unitPriceLabel),
          PriceRangeChart(months: prices, format: (v) => fmt.moneyValue(v), legend: (l10n.priceAverage, l10n.priceRange)),
        ),
      if (stations.any((g) => g.id != null))
        Island(
          title: electric ? l10n.chargingStations : l10n.dictFuelStations,
          children: [for (final g in stations) group(g, l10n.noStation)],
        ),
      if (!electric && types.any((g) => g.id != null))
        Island(title: l10n.dictFuelTypes, children: [for (final g in types) group(g, l10n.noFuelType)]),
      Island(
        children: [
          ValueTile(label: l10n.statEfficiency, value: _opt(s.efficiency, (v) => fmt.efficiency(v.toDouble()))),
          ValueTile(label: electric ? l10n.charges : l10n.refuels, value: fmt.number(s.fuelCount)),
          ValueTile(label: electric ? l10n.energyUsed : l10n.fuelVolumeTotal, value: fmt.shortVolume(s.fuelVolume)),
          ValueTile(label: electric ? l10n.entryTypeCharging : l10n.fuelCost, value: fmt.shortMoney(s.fuelCost)),
          ValueTile(
            label: electric ? l10n.avgEnergyPrice : l10n.avgFuelPrice,
            value: _opt(s.avgFuelUnitPrice, (v) => '${fmt.shortMoney(v)}/${fmt.volumeUnit}'),
          ),
          ValueTile(label: electric ? l10n.avgCharge : l10n.avgFill, value: _opt(facts.avgFill, (v) => fmt.shortVolume(v.toDouble()))),
          if (facts.partialFills > 0)
            ValueTile(label: electric ? l10n.partialCharges : l10n.partialFills, value: fmt.number(facts.partialFills)),
          ValueTile(
            label: electric ? l10n.rangePerCharge : l10n.rangePerTank,
            value: _opt(facts.rangePerTank, (v) => fmt.shortDistance(v)),
          ),
          ValueTile(
            label: electric ? l10n.avgTimeBetweenCharges : l10n.avgTimeBetweenRefuels,
            value: _opt(s.avgDaysBetweenRefuels, (v) => formatDays(l10n, v.round())),
          ),
        ],
      ),
      if (facts.cheapest != null || facts.best != null)
        Island(
          children: [
            if (facts.cheapest case final e?) record(l10n.cheapestFill, '${fmt.shortMoney(unitPrice(e)!)}/${fmt.volumeUnit}', e),
            if (facts.dearest case final e?) record(l10n.dearestFill, '${fmt.shortMoney(unitPrice(e)!)}/${fmt.volumeUnit}', e),
            if (facts.best case (final e, final v)) record(l10n.bestEfficiency, fmt.efficiency(v), e),
            if (facts.worst case (final e, final v)) record(l10n.worstEfficiency, fmt.efficiency(v), e),
          ],
        ),
    ];
  }

  // --------------------------------------------------------------------------------------------- Service

  List<Widget> service(BuildContext context) {
    final l10n = context.l10n;
    final s = d.current;
    final events = serviceEvents(d.entries, d.resets, d.range);
    final reminderNames = {for (final r in d.reminders) r.reminder.id: r.reminder.name};
    final rowIds = <String?>[
      for (final r in d.reminders)
        if (events.any((e) => e.reminderIds.contains(r.reminder.id))) r.reminder.id,
      if (events.any((e) => e.reminderIds.every((id) => !reminderNames.containsKey(id)))) null,
    ];
    final dots = [
      for (final e in events)
        for (final id in [
          ...e.reminderIds.where(reminderNames.containsKey),
          if (e.reminderIds.every((id) => !reminderNames.containsKey(id))) null,
        ])
          (
            date: e.entry.date,
            row: rowIds.indexOf(id),
            title: e.entry.note.isNotEmpty ? e.entry.note.split('\n').first : (reminderNames[id] ?? l10n.otherServices),
            entry: e.entry,
          ),
    ];
    final years = serviceCostByYear(d.entries, d.range);
    final history = events.reversed.map((e) => e.entry).toList();
    return [
      if (d.upcoming.isNotEmpty)
        Island(
          title: l10n.whatsNext,
          children: [
            for (final u in d.upcoming)
              ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(u.status.reminder.name),
                subtitle: Text([
                  reminderStatusText(fmt, u.status),
                  if (u.cost != null) l10n.expectedCost(fmt.shortMoney(u.cost!)),
                ].join('\n')),
                isThreeLine: u.cost != null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.reminder(d.vehicle.id, u.status.reminder.id)),
              ),
          ],
        ),
      if (dots.length >= 2)
        _section(
          context,
          l10n.serviceTimeline,
          ServiceTimelineChart(
            rows: [for (final id in rowIds) reminderNames[id] ?? l10n.otherServices],
            events: [for (final x in dots) (date: x.date, row: x.row, title: x.title)],
            onTap: (i) => context.push(Routes.entry(d.vehicle.id, dots[i].entry.id)),
          ),
        ),
      if (years.length >= 2)
        _section(
          context,
          l10n.chartServiceByYear(fmt.currencySymbol),
          ColumnsChart(
            height: 150,
            bars: [for (final y in years) (label: '${y.year}', title: '${y.year}', value: y.cost.toDouble())],
            format: (v) => fmt.compactMoney(v),
          ),
        ),
      Island(
        children: [
          ValueTile(label: l10n.services, value: fmt.number(s.serviceCount)),
          ValueTile(label: l10n.serviceCost, value: fmt.shortMoney(s.serviceCost)),
          ValueTile(
            label: l10n.avgDistanceBetweenServices,
            value: _opt(s.avgDistanceBetweenServices, (v) => fmt.shortDistance(v)),
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
          if (history.isEmpty) ListTile(title: Text(l10n.noServicesForPeriod)),
          for (final e in history)
            EntryListItem(
              entry: e,
              fmt: fmt,
              names: d.names,
              onTap: () => context.push(Routes.entry(d.vehicle.id, e.id)),
            ),
        ],
      ),
    ];
  }
}
