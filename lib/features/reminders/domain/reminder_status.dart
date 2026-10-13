import '../../../core/db/database.dart';
import '../../stats/domain/stats_calculator.dart';

/// Where a reminder's interval starts counting from.
class ReminderBaseline {
  const ReminderBaseline({required this.odometer, required this.date, this.resetEntry, this.manual = false});

  final int odometer;
  final DateTime date;

  /// The service entry that last reset the reminder, if any.
  final Entry? resetEntry;

  /// Taken from the reminder's hand-entered "last done" values.
  final bool manual;
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

  /// Days until due in the time domain: the sooner of the date interval and the distance
  /// interval estimated at the average daily mileage. Null when neither is known.
  int? get dueInDays {
    final d = daysLeft, e = estimatedDaysByDistance;
    if (d == null) return e;
    if (e == null) return d;
    return d < e ? d : e;
  }

  /// [dueInDays] comes from the mileage estimate rather than the calendar.
  bool get dueIsEstimated => dueInDays != null && dueInDays != daysLeft;

  /// Remaining share of the interval that runs out first in time ([dueInDays]).
  double get dueFraction {
    if (dueInDays == null) return minFraction;
    return (dueIsEstimated ? distanceFraction : daysFraction) ?? minFraction;
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
  int odometerAt(DateTime date) {
    final before = sortedEntries.where((e) => !e.date.isAfter(date));
    return before.isNotEmpty
        ? before.last.odometer
        : (sortedEntries.isNotEmpty ? sortedEntries.first.odometer : vehicle.initialOdometer);
  }

  // Entered by hand: "last done" before the reminder was tracked here.
  ReminderBaseline? manual;
  if (reminder.lastDoneDate != null || reminder.lastDoneOdometer != null) {
    final date = reminder.lastDoneDate ?? reminder.createdAt;
    manual = ReminderBaseline(odometer: reminder.lastDoneOdometer ?? odometerAt(date), date: date, manual: true);
  }

  final resetEntryIds = {for (final r in resets) if (r.reminderId == reminder.id) r.entryId};
  final resetEntries = sortedEntries.where((e) => resetEntryIds.contains(e.id));
  if (resetEntries.isNotEmpty) {
    final last = resetEntries.last;
    final fromEntry = ReminderBaseline(odometer: last.odometer, date: last.date, resetEntry: last);
    // A later hand-entered date wins (e.g. work done elsewhere and not recorded as an entry).
    return manual != null && manual.date.isAfter(last.date) && manual.odometer >= last.odometer ? manual : fromEntry;
  }
  // Never reset: count from the hand-entered values, else from creation at the odometer known then.
  return manual ?? ReminderBaseline(odometer: odometerAt(reminder.createdAt), date: reminder.createdAt);
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

/// Distance and time between two consecutive services that reset a reminder.
class ServiceGap {
  const ServiceGap({required this.from, required this.to});

  final Entry from;
  final Entry to;

  int get distance => to.odometer - from.odometer;
  int get days => DateTime(to.date.year, to.date.month, to.date.day)
      .difference(DateTime(from.date.year, from.date.month, from.date.day))
      .inDays;
}

/// Gaps between the services that reset [reminder], oldest first.
List<ServiceGap> serviceGaps(String reminderId, List<Entry> entries, List<ReminderReset> resets) {
  final ids = {for (final r in resets) if (r.reminderId == reminderId) r.entryId};
  final services = sortEntries(entries.where((e) => ids.contains(e.id)));
  return [for (var i = 1; i < services.length; i++) ServiceGap(from: services[i - 1], to: services[i])];
}
