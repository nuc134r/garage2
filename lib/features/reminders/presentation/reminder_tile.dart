import 'package:flutter/material.dart';

import '../../../core/format/vehicle_format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../l10n/l10n.dart';
import '../domain/reminder_status.dart';

/// "in 1 200 km", "overdue by 300 km" — null when the reminder has no distance interval.
String? distanceStatusText(VehicleFormat fmt, ReminderStatus s) {
  final left = s.distanceLeft;
  if (left == null) return null;
  return left >= 0 ? fmt.l10n.dueIn(fmt.distance(left)) : fmt.l10n.overdueBy(fmt.distance(-left));
}

String? dateStatusText(AppLocalizations l10n, ReminderStatus s) {
  final left = s.daysLeft;
  if (left == null) return null;
  if (left == 0) return l10n.dueToday;
  return left > 0 ? l10n.dueIn(formatDays(l10n, left)) : l10n.overdueBy(formatDays(l10n, -left));
}

String reminderStatusText(VehicleFormat fmt, ReminderStatus s) {
  final parts = [distanceStatusText(fmt, s), dateStatusText(fmt.l10n, s)].whereType<String>();
  return parts.isEmpty ? fmt.l10n.noInterval : parts.join(' · ');
}

class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.status, required this.fmt, this.onTap});

  final ReminderStatus status;
  final VehicleFormat fmt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overdue = status.isOverdue;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        overdue ? Icons.warning_amber_rounded : Icons.notifications_outlined,
        color: overdue ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text(status.reminder.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reminderStatusText(fmt, status),
            style: overdue ? TextStyle(color: theme.colorScheme.error) : null,
          ),
          const SizedBox(height: 6),
          RemainingBar(fraction: status.minFraction, height: 4),
        ],
      ),
    );
  }
}
