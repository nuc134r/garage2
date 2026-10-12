import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../settings/data/settings_repository.dart';
import '../../stats/domain/stats_calculator.dart';
import '../domain/home_tiles.dart';

extension HomeMetricLabel on HomeMetric {
  String label(AppLocalizations l10n) => switch (this) {
        HomeMetric.fuelCost => l10n.statFuel,
        HomeMetric.efficiency => l10n.statEfficiency,
        HomeMetric.odometer => l10n.statMileage,
        HomeMetric.totalCost => l10n.statExpenses,
        HomeMetric.serviceCost => l10n.serviceCost,
        HomeMetric.otherCost => l10n.otherCost,
        HomeMetric.mileage => l10n.statDistance,
        HomeMetric.fuelVolume => l10n.statFuelVolume,
        HomeMetric.fuelPrice => l10n.statFuelPrice,
        HomeMetric.costPerDistance => l10n.statCostPerDistance,
      };
}

extension StatsPeriodLabel on StatsPeriod {
  String label(AppLocalizations l10n) => switch (this) {
        StatsPeriod.allTime => l10n.periodAllTime,
        StatsPeriod.year => l10n.periodYear,
        StatsPeriod.month => l10n.periodMonth,
        StatsPeriod.week => l10n.periodWeek,
      };

  String shortLabel(AppLocalizations l10n) => switch (this) {
        StatsPeriod.allTime => l10n.periodTotal,
        StatsPeriod.year => l10n.period1y,
        StatsPeriod.month => l10n.period30d,
        StatsPeriod.week => l10n.period7d,
      };
}

/// Formatted value and units of a tile.
({String value, String units}) homeTileValue(HomeTile tile, IntervalStats s, int odometer, VehicleFormat fmt) {
  String money(num? minor) => minor == null ? '—' : fmt.moneyValue(minor);
  final cur = fmt.currencySymbol;
  return switch (tile.metric) {
    HomeMetric.fuelCost => (value: money(s.fuelCost), units: cur),
    HomeMetric.efficiency => (value: s.efficiency == null ? '—' : fmt.number(s.efficiency!, maxDigits: 1), units: fmt.efficiencyUnit),
    HomeMetric.odometer => (value: fmt.number(odometer), units: fmt.distanceUnit),
    HomeMetric.totalCost => (value: money(s.totalCost), units: cur),
    HomeMetric.serviceCost => (value: money(s.serviceCost), units: cur),
    HomeMetric.otherCost => (value: money(s.otherCost), units: cur),
    HomeMetric.mileage => (value: fmt.number(s.mileage), units: fmt.distanceUnit),
    HomeMetric.fuelVolume => (value: fmt.number(s.fuelVolume, maxDigits: 1), units: fmt.volumeUnit),
    HomeMetric.fuelPrice => (value: money(s.avgFuelUnitPrice), units: '$cur/${fmt.volumeUnit}'),
    HomeMetric.costPerDistance => (value: money(s.costPerDistance), units: '$cur/${fmt.distanceUnit}'),
  };
}

/// The configurable grid of stat tiles on the home screen, two per row.
class HomeStatTiles extends ConsumerWidget {
  const HomeStatTiles({super.key, required this.vehicle, required this.entries, required this.onOpenStats});

  final Vehicle vehicle;
  final List<Entry> entries;
  final void Function(HomeTile tile) onOpenStats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final fmt = VehicleFormat.of(context, vehicle);
    final tiles = ref.watch(appSettingsProvider).value?.homeTiles ?? defaultHomeTiles;
    if (tiles.isEmpty) return const SizedBox.shrink();

    final stats = <StatsPeriod, IntervalStats>{};
    // Hero tags must be unique on a page; a repeated tile simply doesn't fly.
    final heroTiles = <HomeTile>{};
    final odometer = currentOdometer(entries, vehicle);

    Widget build(int i) {
      final tile = tiles[i];
      final period = tile.effectivePeriod;
      final s = stats.putIfAbsent(period, () => computeStats(entries, vehicle, period.range));
      final v = homeTileValue(tile, s, odometer, fmt);
      final statTile = StatTile(
        title: tile.metric.label(l10n),
        period: period.shortLabel(l10n),
        value: v.value,
        units: v.units,
        onTap: () => onOpenStats(tile),
        onLongPress: () async {
          final edited = await showHomeTileEditor(context, tile);
          if (edited == null) return;
          await saveHomeTiles(ref, [...tiles]..[i] = edited);
        },
      );
      return heroTiles.add(tile) ? Hero(tag: HeroTags.statTile(tile), child: statTile) : statTile;
    }

    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: build(i)),
                if (i + 1 < tiles.length) ...[
                  const SizedBox(width: 8),
                  Expanded(child: build(i + 1)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

Future<void> saveHomeTiles(WidgetRef ref, List<HomeTile> tiles) =>
    ref.read(settingsRepositoryProvider).set(SettingKeys.homeTiles, encodeHomeTiles(tiles));

/// Lets the user pick a tile's value and period; returns null when dismissed.
Future<HomeTile?> showHomeTileEditor(BuildContext context, HomeTile initial) {
  return showModalBottomSheet<HomeTile>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _HomeTileEditor(initial: initial),
  );
}

class _HomeTileEditor extends StatefulWidget {
  const _HomeTileEditor({required this.initial});

  final HomeTile initial;

  @override
  State<_HomeTileEditor> createState() => _HomeTileEditorState();
}

class _HomeTileEditorState extends State<_HomeTileEditor> {
  late var _tile = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.editTile, style: theme.textTheme.titleLarge),
            ),
            if (_tile.metric.hasPeriod) ...[
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SectionTitle(l10n.tilePeriod)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in StatsPeriod.values)
                      ChoiceChip(
                        label: Text(p.label(l10n)),
                        selected: p == _tile.period,
                        onSelected: (_) => setState(() => _tile = _tile.copyWith(period: p)),
                      ),
                  ],
                ),
              ),
            ],
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SectionTitle(l10n.tileValue)),
            Flexible(
              child: RadioGroup<HomeMetric>(
                groupValue: _tile.metric,
                onChanged: (m) => setState(() => _tile = _tile.copyWith(metric: m)),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final m in HomeMetric.values) RadioListTile(value: m, title: Text(m.label(l10n))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => Navigator.pop(context, _tile), child: Text(l10n.save)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
