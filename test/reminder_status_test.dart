import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/core/model/enums.dart';
import 'package:garage/features/reminders/domain/reminder_status.dart';

import 'helpers.dart';

void main() {
  final vehicle = testVehicle();
  DateTime day(int d) => DateTime(2025, 1, 1).add(Duration(days: d));

  test('counts from creation when never reset', () {
    final reminder = testReminder(distance: 1000, days: 100, createdAt: day(0));
    final entries = [
      testEntry(type: EntryType.odometer, odometer: 10000, date: day(0)),
      testEntry(type: EntryType.odometer, odometer: 10250, date: day(10)),
    ];
    final s = computeReminderStatus(reminder: reminder, vehicle: vehicle, entries: entries, resets: [], now: day(25));
    expect(s.distanceLeft, 750);
    expect(s.distanceFraction, 0.75);
    expect(s.daysLeft, 75);
    expect(s.minFraction, 0.75);
    expect(s.estimatedDaysByDistance, 30); // 25 km/day
    expect(s.isOverdue, isFalse);
  });

  test('a service entry resets the reminder', () {
    final reminder = testReminder(distance: 1000, createdAt: day(0));
    final service = testEntry(id: 's1', type: EntryType.service, odometer: 10800, date: day(20));
    final entries = [
      testEntry(type: EntryType.odometer, odometer: 10000, date: day(0)),
      service,
      testEntry(type: EntryType.odometer, odometer: 11000, date: day(30)),
    ];
    final s = computeReminderStatus(
      reminder: reminder,
      vehicle: vehicle,
      entries: entries,
      resets: [const ReminderReset(entryId: 's1', reminderId: 'r1')],
      now: day(30),
    );
    expect(s.baseline.resetEntry?.id, 's1');
    expect(s.distanceLeft, 800);
  });

  test('overdue by date wins over distance', () {
    final reminder = testReminder(distance: 10000, days: 30, createdAt: day(0));
    final s = computeReminderStatus(
      reminder: reminder,
      vehicle: vehicle,
      entries: [testEntry(odometer: 100, date: day(0))],
      resets: [],
      now: day(45),
    );
    expect(s.daysLeft, -15);
    expect(s.isOverdue, isTrue);
    expect(s.minFraction, -0.5);
  });
}
