import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/reminder_repository.dart';
import 'reminder_tile.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final vehicle = ref.watch(vehicleProvider(vehicleId)).value;
    final statuses = ref.watch(reminderStatusesProvider(vehicleId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reminders), bottom: vehicle == null ? null : _VehicleSubtitle(vehicle.name)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_alert),
        label: Text(l10n.newReminder),
        onPressed: () => context.push(Routes.newReminder(vehicleId)),
      ),
      body: vehicle == null
          ? const Center(child: CircularProgressIndicator())
          : AsyncBuilder(
              statuses,
              builder: (list) {
                if (list.isEmpty) return EmptyState(icon: Icons.notifications_none, text: l10n.noReminders);
                final fmt = VehicleFormat.of(context, vehicle);
                return ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [
                    Island(
                      children: [
                        for (final s in list)
                          ReminderTile(
                            status: s,
                            fmt: fmt,
                            onTap: () => context.push(Routes.reminder(vehicleId, s.reminder.id)),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _VehicleSubtitle extends StatelessWidget implements PreferredSizeWidget {
  const _VehicleSubtitle(this.name);

  final String name;

  @override
  Size get preferredSize => const Size.fromHeight(20);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 72, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(name, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }
}
