import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/db/database.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../entries/data/entry_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../../stats/presentation/stats_charts.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder_status.dart';
import 'reminder_tile.dart';

class ReminderDetailsScreen extends ConsumerWidget {
  const ReminderDetailsScreen({super.key, required this.vehicleId, required this.reminderId});

  final String vehicleId;
  final String reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final vehicle = ref.watch(vehicleProvider(vehicleId)).value;
    final statuses = ref.watch(reminderStatusesProvider(vehicleId)).value;
    final entries = ref.watch(entriesProvider(vehicleId)).value ?? const [];
    final resets = ref.watch(reminderResetsProvider(vehicleId)).value ?? const [];

    if (vehicle == null || statuses == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final status = statuses.where((s) => s.reminder.id == reminderId).firstOrNull;
    if (status == null) {
      return Scaffold(appBar: AppBar(), body: EmptyState(icon: Icons.search_off, text: l10n.reminderNotFound));
    }
    final r = status.reminder;
    final fmt = VehicleFormat.of(context, vehicle);
    final resetIds = {for (final x in resets) if (x.reminderId == r.id) x.entryId};
    final history = entries.where((e) => resetIds.contains(e.id)).toList().reversed;

    Widget dimension(String label, String? text, double? fraction, String interval) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(label, style: theme.textTheme.labelLarge)),
                  Text(interval, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: 12),
              RemainingBar(fraction: fraction ?? 1, height: 10, label: text),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
            onPressed: () async {
              final ok = await confirm(context, title: l10n.deleteReminderTitle(r.name), action: l10n.delete, destructive: true);
              if (!ok) return;
              await ref.read(reminderRepositoryProvider).delete(r.id);
              if (context.mounted) context.pop();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit_outlined),
        label: Text(l10n.edit),
        onPressed: () => context.push(Routes.editReminder(vehicleId, r.id)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Center(child: Hero(tag: HeroTags.reminderIcon(r.id), child: reminderBadge(theme, status, 72))),
          const SizedBox(height: 12),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: HeroText(r.name, tag: HeroTags.reminderTitle(r.id), style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            ),
          ),
          Center(
            child: Text(
              reminderDueText(fmt, status),
              style: theme.textTheme.bodyMedium?.copyWith(color: status.isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          Island(
            title: l10n.status,
            children: [
              if (r.intervalDistance != null)
                dimension(
                  l10n.byDistance,
                  // "in 2,100 km (~6 weeks)" — the time estimate from the average daily mileage.
                  [
                    distanceStatusText(fmt, status),
                    if (status.estimatedDaysByDistance != null && (status.distanceLeft ?? 0) > 0)
                      '(~${formatDays(l10n, status.estimatedDaysByDistance!)})',
                  ].whereType<String>().join(' '),
                  status.distanceFraction,
                  l10n.everyInterval(fmt.distance(r.intervalDistance!)),
                ),
              if (r.intervalDays != null)
                dimension(l10n.byTime, dateStatusText(l10n, status), status.daysFraction, l10n.everyInterval(formatDays(l10n, r.intervalDays!))),
            ],
          ),
          _HistorySection(
            reminder: r,
            history: history.toList(),
            gaps: serviceGaps(r.id, entries, resets),
            fmt: fmt,
            onOpen: (e) => context.push(Routes.entry(vehicleId, e.id)),
          ),
        ],
      ),
    );
  }
}

enum _HistoryView { list, chart }

/// Services that reset the reminder, as a list with the gaps between them or as interval columns.
class _HistorySection extends StatefulWidget {
  const _HistorySection({
    required this.reminder,
    required this.history,
    required this.gaps,
    required this.fmt,
    required this.onOpen,
  });

  final Reminder reminder;

  /// Newest first.
  final List<Entry> history;

  /// Oldest first.
  final List<ServiceGap> gaps;
  final VehicleFormat fmt;
  final void Function(Entry entry) onOpen;

  @override
  State<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<_HistorySection> {
  _HistoryView _view = _HistoryView.list;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final fmt = widget.fmt;
    final r = widget.reminder;
    final history = widget.history;
    final labels = {_HistoryView.list: l10n.history, _HistoryView.chart: l10n.intervals};

    String gapText(Entry newer, Entry older) => [
          '+${fmt.distance(newer.odometer - older.odometer)}',
          formatDays(l10n, DateUtils.dateOnly(newer.date).difference(DateUtils.dateOnly(older.date)).inDays),
        ].join(' · ');

    final List<Widget> content;
    if (history.isEmpty) {
      content = [ListTile(title: Text(l10n.reminderHistoryEmpty), subtitle: Text(l10n.reminderHistoryHint))];
    } else if (_view == _HistoryView.list) {
      content = [
        for (final (i, e) in history.indexed) ...[
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: Text(fmt.date(e.date)),
            subtitle: Text(fmt.distance(e.odometer)),
            trailing: e.totalCost == 0 ? null : Text(fmt.money(e.totalCost)),
            onTap: () => widget.onOpen(e),
          ),
          if (i + 1 < history.length)
            // Centred between the two services it separates.
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Center(
                child: Text(
                  gapText(e, history[i + 1]),
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                ),
              ),
            ),
        ],
      ];
    } else if (widget.gaps.isEmpty) {
      content = [ListTile(title: Text(l10n.intervalsNeedTwo))];
    } else {
      final dates = [for (final g in widget.gaps) DateFormat.yMMM(l10n.localeName).format(g.to.date)];
      Widget chart(String title, List<double> values, double required, String Function(double) format, String every) =>
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                IntervalColumnsChart(
                  values: values,
                  labels: dates,
                  required: required,
                  format: format,
                  requiredLabel: l10n.requiredInterval(every),
                ),
              ],
            ),
          );
      content = [
        if (r.intervalDistance != null)
          chart(
            l10n.byDistance,
            [for (final g in widget.gaps) g.distance.toDouble()],
            r.intervalDistance!.toDouble(),
            (v) => fmt.compactNumber(v),
            fmt.distance(r.intervalDistance!),
          ),
        if (r.intervalDays != null)
          chart(
            l10n.byTime,
            [for (final g in widget.gaps) g.days / 30.44],
            r.intervalDays! / 30.44,
            (v) => '${fmt.number(v, maxDigits: 1)} ${l10n.unitMonthsShort}',
            formatDays(l10n, r.intervalDays!),
          ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The section title doubles as the switch between the list and the chart.
          DropdownButtonHideUnderline(
            child: DropdownButton<_HistoryView>(
              value: _view,
              isDense: true,
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
              borderRadius: BorderRadius.circular(12),
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary),
              iconEnabledColor: theme.colorScheme.primary,
              items: [for (final v in _HistoryView.values) DropdownMenuItem(value: v, child: Text(labels[v]!))],
              onChanged: (v) => setState(() => _view = v!),
            ),
          ),
          Card(margin: EdgeInsets.zero, clipBehavior: Clip.antiAlias, child: Column(children: content)),
        ],
      ),
    );
  }
}
