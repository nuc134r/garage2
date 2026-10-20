import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../entries/data/entry_repository.dart';
import '../../home/presentation/home_tiles_view.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../domain/stats_analysis.dart';
import '../domain/stats_calculator.dart';

/// Statistics → Compare vehicles: the key figures of every vehicle side by side for one period.
class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key, this.currentId});

  /// The vehicle the screen was opened from; highlighted.
  final String? currentId;

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

/// One vehicle's figures for the period.
class _Figures {
  _Figures(this.vehicle, List<Entry> entries, DateRange range) {
    final stats = computeStats(entries, vehicle, range);
    distance = distanceIn(dailyDistance(entries), range);
    total = stats.totalCost;
    monthly = stats.entryCount == 0 ? null : total / monthsIn(range, entries);
    perDistance = distance > 0 ? total / distance : null;
    efficiency = stats.efficiency;
  }

  final Vehicle vehicle;
  late final double distance;
  late final int total;
  late final double? monthly;
  late final double? perDistance;
  late final double? efficiency;
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  StatsPeriod _period = StatsPeriod.year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vehicles = ref.watch(vehiclesProvider).value ?? const [];
    final range = _period.range;
    final figures = [
      for (final v in vehicles)
        if (ref.watch(entriesProvider(v.id)).value case final entries?) _Figures(v, entries, range),
    ];
    var mixed = false;

    /// One metric: a row per vehicle with a bar against the largest value among vehicles in the same units.
    Widget metric(
      String title,
      double? Function(_Figures f) value,
      String Function(VehicleFormat fmt, double v) format,
      String Function(Vehicle v) unitKey,
    ) {
      final groups = <String, double>{};
      for (final f in figures) {
        final v = value(f);
        if (v != null && v > 0) {
          final key = unitKey(f.vehicle);
          groups[key] = max(groups[key] ?? 0, v);
        }
      }
      if (groups.length > 1) mixed = true;
      final theme = Theme.of(context);
      return Island(
        title: title,
        children: [
          for (final f in figures)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  VehicleAvatar(f.vehicle, radius: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                f.vehicle.name,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: f.vehicle.id == widget.currentId ? FontWeight.w600 : null,
                                ),
                              ),
                            ),
                            Text(
                              value(f) == null ? '—' : format(VehicleFormat.of(context, f.vehicle), value(f)!),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            value: value(f) == null ? 0 : value(f)! / (groups[unitKey(f.vehicle)] ?? 1),
                            color: f.vehicle.id == widget.currentId
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondary,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    final sections = [
      metric(
        l10n.statCostPerDistance,
        (f) => f.perDistance,
        (fmt, v) => '${fmt.shortMoney(v)}/${fmt.distanceUnit}',
        (v) => '${v.currencyCode}/${v.distanceUnit.name}',
      ),
      metric(l10n.monthlyCost, (f) => f.monthly, (fmt, v) => fmt.shortMoney(v), (v) => v.currencyCode),
      metric(l10n.totalCost, (f) => f.total.toDouble(), (fmt, v) => fmt.shortMoney(v), (v) => v.currencyCode),
      metric(l10n.statDistance, (f) => f.distance, (fmt, v) => fmt.shortDistance(v), (v) => v.distanceUnit.name),
      metric(l10n.statEfficiency, (f) => f.efficiency, (fmt, v) => fmt.efficiency(v), (v) => v.efficiencyUnit.name),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.compareVehicles)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              children: [
                for (final p in StatsPeriod.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.label(l10n)),
                      selected: p == _period,
                      onSelected: (_) => setState(() => _period = p),
                    ),
                  ),
              ],
            ),
          ),
          ...sections,
          if (mixed)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                l10n.compareUnitsDiffer,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }
}
