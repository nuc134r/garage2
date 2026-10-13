import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../entries/data/entry_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/reminder_repository.dart';
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
              const SizedBox(height: 8),
              RemainingBar(fraction: fraction ?? 1, height: 10),
              const SizedBox(height: 8),
              Text(text ?? '', style: theme.textTheme.titleMedium?.copyWith(color: (fraction ?? 1) < 0 ? theme.colorScheme.error : null)),
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
                dimension(l10n.byDistance, distanceStatusText(fmt, status), status.distanceFraction, l10n.everyInterval(fmt.distance(r.intervalDistance!))),
              if (r.intervalDays != null)
                dimension(l10n.byTime, dateStatusText(l10n, status), status.daysFraction, l10n.everyInterval(formatDays(l10n, r.intervalDays!))),
              if (status.estimatedDaysByDistance != null && status.distanceLeft != null && status.distanceLeft! > 0)
                ValueTile(icon: Icons.schedule, label: l10n.estimatedByMileage, value: '~${formatDays(l10n, status.estimatedDaysByDistance!)}'),
              ValueTile(
                icon: Icons.flag_outlined,
                label: status.baseline.resetEntry == null && !status.baseline.manual ? l10n.countingSince : l10n.lastDone,
                value: '${fmt.date(status.baseline.date)} · ${fmt.distance(status.baseline.odometer)}',
              ),
            ],
          ),
          Island(
            title: l10n.history,
            children: [
              if (history.isEmpty)
                ListTile(title: Text(l10n.reminderHistoryEmpty), subtitle: Text(l10n.reminderHistoryHint)),
              for (final e in history)
                ListTile(
                  leading: const Icon(Icons.build_outlined),
                  title: Text(fmt.date(e.date)),
                  subtitle: Text(fmt.distance(e.odometer)),
                  trailing: e.totalCost == 0 ? null : Text(fmt.money(e.totalCost)),
                  onTap: () => context.push(Routes.entry(vehicleId, e.id)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
