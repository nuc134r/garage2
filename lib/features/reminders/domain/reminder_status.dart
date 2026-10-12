import '../../../core/db/database.dart';
import '../../stats/domain/stats_calculator.dart';

/// Where a reminder's interval starts counting from.
class ReminderBaseline {
  const ReminderBaseline({required this.odometer, required this.date, this.resetEntry});

  final int odometer;
  final DateTime date;

  /// The service entry that last reset the reminder, if any.
  final Entry? resetEntry;
}

class ReminderStatus {
  const ReminderStatus({
    required this.reminder,
    required this.baseline,
    this.distanceLeft,
    this.distanceFraction,
    this.daysLeft,
    this.daysFraction,
    this.estimatedDaysByDistance,
  });

  final Reminder reminder;
  final ReminderBaseline baseline;

  /// Distance until due; negative when overdue.
  final int? distanceLeft;

  /// Remaining share of the distance interval (1 = just reset, <0 = overdue).
  final double? distanceFraction;

  /// Days until due; negative when overdue.
  final int? daysLeft;
  final double? daysFraction;

  /// Days until the distance interval runs out at the average daily mileage.
  final int? estimatedDaysByDistance;

  double get minFraction {
    final values = [distanceFraction, daysFraction].whereType<double>();
    return values.isEmpty ? 1 : values.reduce((a, b) => a < b ? a : b);
  }

  bool get isOverdue => minFraction < 0;
  bool get isDueSoon => minFraction < 0.1;
}

ReminderBaseline reminderBaseline({
  required Reminder reminder,
  required Vehicle vehicle,
  required List<Entry> sortedEntries,
  required List<ReminderReset> resets,
}) {
  final resetEntryIds = {for (final r in resets) if (r.reminderId == reminder.id) r.entryId};
  final resetEntries = sortedEntries.where((e) => resetEntryIds.contains(e.id));
  if (resetEntries.isNotEmpty) {
    final last = resetEntries.last;
    return ReminderBaseline(odometer: last.odometer, date: last.date, resetEntry: last);
  }
  // Never reset: count from when the reminder was created, at the odometer known then.
  final before = sortedEntries.where((e) => !e.date.isAfter(reminder.createdAt));
  final odometer = before.isNotEmpty
      ? before.last.odometer
      : (sortedEntries.isNotEmpty ? sortedEntries.first.odometer : vehicle.initialOdometer);
  return ReminderBaseline(odometer: odometer, date: reminder.createdAt);
}

ReminderStatus computeReminderStatus({
  required Reminder reminder,
  required Vehicle vehicle,
  required List<Entry> entries,
  required List<ReminderReset> resets,
  DateTime? now,
}) {
  final sorted = sortEntries(entries);
  final today = now ?? DateTime.now();
  final baseline = reminderBaseline(reminder: reminder, vehicle: vehicle, sortedEntries: sorted, resets: resets);

  int? distanceLeft, daysLeft, estimatedDays;
  double? distanceFraction, daysFraction;

  final interval = reminder.intervalDistance;
  if (interval != null && interval > 0) {
    final driven = currentOdometer(sorted, vehicle) - baseline.odometer;
    distanceLeft = interval - driven;
    distanceFraction = distanceLeft / interval;
    final daily = computeStats(sorted, vehicle, DateRange.allTime).avgDailyMileage;
    if (daily != null && daily > 0) estimatedDays = (distanceLeft / daily).round();
  }

  final days = reminder.intervalDays;
  if (days != null && days > 0) {
    final passed = today.difference(baseline.date).inDays;
    daysLeft = days - passed;
    daysFraction = daysLeft / days;
  }

  return ReminderStatus(
    reminder: reminder,
    baseline: baseline,
    distanceLeft: distanceLeft,
    distanceFraction: distanceFraction,
    daysLeft: daysLeft,
    daysFraction: daysFraction,
    estimatedDaysByDistance: estimatedDays,
  );
}

/// Preset reminder kinds; names are localized in the UI by [key].
class ReminderPreset {
  const ReminderPreset(this.key, this.distance, this.months);

  final String key;
  final int distance;
  final int months;

  static const all = [
    ReminderPreset('engineOil', 7500, 12),
    ReminderPreset('transmissionFluid', 30000, 24),
    ReminderPreset('fuelFilter', 30000, 36),
    ReminderPreset('timingBelt', 90000, 48),
    ReminderPreset('powerSteeringFluid', 60000, 60),
    ReminderPreset('brakeFluid', 30000, 24),
    ReminderPreset('belts', 60000, 24),
    ReminderPreset('coolant', 30000, 60),
    ReminderPreset('sparkPlugs', 30000, 24),
    ReminderPreset('valveAdjustment', 90000, 48),
  ];
}
