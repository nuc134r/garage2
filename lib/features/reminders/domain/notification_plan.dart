import '../../../core/db/database.dart';
import 'reminder_status.dart';

enum AlertKind { dueSoon, due }

/// A reminder status together with its vehicle.
typedef VehicleReminder = ({Vehicle vehicle, ReminderStatus status});

/// A notification to schedule for a future moment.
class PlannedAlert {
  const PlannedAlert({required this.item, required this.kind, required this.at, required this.daysBeforeDue});

  final VehicleReminder item;
  final AlertKind kind;
  final DateTime at;

  /// 0 for the "due" alert, the lead time for "due soon".
  final int daysBeforeDue;

  /// Stable across runs, so rescheduling replaces the same notification.
  int get id => notificationId('${item.status.reminder.id}:${kind.name}');
}

/// Days until the reminder is due: by date, or estimated from mileage. Null when unknown.
/// Zero or negative means due now / overdue.
int? daysUntilDue(ReminderStatus s) {
  final candidates = <int>[
    ?s.daysLeft,
    if (s.distanceLeft != null && s.distanceLeft! <= 0) 0,
    if (s.distanceLeft != null && s.distanceLeft! > 0) ?s.estimatedDaysByDistance,
  ];
  if (candidates.isEmpty) return null;
  return candidates.reduce((a, b) => a < b ? a : b);
}

/// Future alerts: one [leadDays] before the due date and one on the due date, at [hour] local time.
List<PlannedAlert> planAlerts(List<VehicleReminder> items, {required DateTime now, int leadDays = 7, int hour = 10}) {
  final today = DateTime(now.year, now.month, now.day);
  final alerts = <PlannedAlert>[];
  for (final item in items) {
    final days = daysUntilDue(item.status);
    if (days == null) continue;
    final due = today.add(Duration(days: days, hours: hour));
    if (due.isAfter(now)) {
      alerts.add(PlannedAlert(item: item, kind: AlertKind.due, at: due, daysBeforeDue: 0));
    }
    if (leadDays > 0) {
      final soon = due.subtract(Duration(days: leadDays));
      if (soon.isAfter(now)) {
        alerts.add(PlannedAlert(item: item, kind: AlertKind.dueSoon, at: soon, daysBeforeDue: leadDays));
      }
    }
  }
  alerts.sort((a, b) => a.at.compareTo(b.at));
  return alerts;
}

/// Reminders that need attention right now: due within [leadDays] or overdue.
List<VehicleReminder> needingAttention(List<VehicleReminder> items, {int leadDays = 7}) => [
      for (final item in items)
        if (daysUntilDue(item.status) case final d? when d <= leadDays) item,
    ]..sort((a, b) => daysUntilDue(a.status)!.compareTo(daysUntilDue(b.status)!));

/// 31-bit FNV-1a hash; Android notification ids must fit in a signed int.
int notificationId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
