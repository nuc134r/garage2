import 'dart:convert';

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

/// A vehicle's notification preferences; vehicles without any use [VehicleNotify.defaults].
class VehicleNotify {
  const VehicleNotify({this.enabled = true, this.leadDays});

  static const defaults = VehicleNotify();

  final bool enabled;

  /// How many days in advance to notify; null means the app-wide setting.
  final int? leadDays;

  bool get isDefault => enabled && leadDays == null;

  int lead(int appDefault) => leadDays ?? appDefault;
}

/// Parses the per-vehicle preferences setting: `{"<vehicle id>": {"enabled": false, "leadDays": 14}}`.
Map<String, VehicleNotify> parseVehicleNotify(String? raw) {
  if (raw == null || raw.isEmpty) return const {};
  try {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final MapEntry(:key, :value) in json.entries)
        if (value is Map<String, dynamic>)
          key: VehicleNotify(enabled: value['enabled'] != false, leadDays: (value['leadDays'] as num?)?.toInt()),
    };
  } on FormatException {
    return const {};
  } on TypeError {
    return const {};
  }
}

/// Inverse of [parseVehicleNotify]; vehicles on the defaults are left out.
String encodeVehicleNotify(Map<String, VehicleNotify> prefs) => jsonEncode({
      for (final MapEntry(:key, :value) in prefs.entries)
        if (!value.isDefault) key: {'enabled': value.enabled, 'leadDays': ?value.leadDays},
    });

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
/// [perVehicle] turns a vehicle's alerts off or gives it its own lead time.
List<PlannedAlert> planAlerts(
  List<VehicleReminder> items, {
  required DateTime now,
  int leadDays = 7,
  int hour = 10,
  Map<String, VehicleNotify> perVehicle = const {},
}) {
  final today = DateTime(now.year, now.month, now.day);
  final alerts = <PlannedAlert>[];
  for (final item in items) {
    final prefs = perVehicle[item.vehicle.id] ?? VehicleNotify.defaults;
    if (!prefs.enabled) continue;
    final lead = prefs.lead(leadDays);
    final days = daysUntilDue(item.status);
    if (days == null) continue;
    final due = today.add(Duration(days: days, hours: hour));
    if (due.isAfter(now)) {
      alerts.add(PlannedAlert(item: item, kind: AlertKind.due, at: due, daysBeforeDue: 0));
    }
    if (lead > 0) {
      final soon = due.subtract(Duration(days: lead));
      if (soon.isAfter(now)) {
        alerts.add(PlannedAlert(item: item, kind: AlertKind.dueSoon, at: soon, daysBeforeDue: lead));
      }
    }
  }
  alerts.sort((a, b) => a.at.compareTo(b.at));
  return alerts;
}

/// Reminders that need attention right now: due within their vehicle's lead time or overdue.
List<VehicleReminder> needingAttention(
  List<VehicleReminder> items, {
  int leadDays = 7,
  Map<String, VehicleNotify> perVehicle = const {},
}) =>
    [
      for (final item in items)
        if (perVehicle[item.vehicle.id] ?? VehicleNotify.defaults case final prefs when prefs.enabled)
          if (daysUntilDue(item.status) case final d? when d <= prefs.lead(leadDays)) item,
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
