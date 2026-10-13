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

/// "in 3 months", "in ~2 weeks" (estimated from mileage), "overdue by 5 days", "due today".
/// Falls back to the full status when there is no time estimate (distance interval, no mileage yet).
String reminderDueText(VehicleFormat fmt, ReminderStatus s) {
  final days = s.dueInDays;
  if (days == null) return reminderStatusText(fmt, s);
  final l10n = fmt.l10n;
  if (days == 0) return l10n.dueToday;
  final span = '${s.dueIsEstimated ? '~' : ''}${formatDays(l10n, days.abs())}';
  return days > 0 ? l10n.dueIn(span) : l10n.overdueBy(span);
}

String reminderStatusText(VehicleFormat fmt, ReminderStatus s) {
  final parts = [distanceStatusText(fmt, s), dateStatusText(fmt.l10n, s)].whereType<String>();
  return parts.isEmpty ? fmt.l10n.noInterval : parts.join(' · ');
}

Widget reminderBadge(ThemeData theme, ReminderStatus status, double size) => IconBadge(
      icon: status.isOverdue ? Icons.warning_amber_rounded : Icons.notifications_outlined,
      size: size,
      background: status.isOverdue ? theme.colorScheme.errorContainer : theme.colorScheme.secondaryContainer,
      foreground: status.isOverdue ? theme.colorScheme.onErrorContainer : theme.colorScheme.onSecondaryContainer,
    );

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
      leading: Hero(
        tag: HeroTags.reminderIcon(status.reminder.id),
        child: reminderBadge(theme, status, 40),
      ),
      title: HeroText(status.reminder.name, tag: HeroTags.reminderTitle(status.reminder.id)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reminderDueText(fmt, status),
            style: overdue ? TextStyle(color: theme.colorScheme.error) : null,
          ),
          const SizedBox(height: 6),
          RemainingBar(fraction: status.timeBarFraction, height: 4),
        ],
      ),
    );
  }
}
