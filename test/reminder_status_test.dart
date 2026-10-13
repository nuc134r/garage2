import 'package:drift/drift.dart' show Value;
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

  test('counts from the hand-entered last done values', () {
    final reminder = testReminder(distance: 1000, days: 100, createdAt: day(50))
        .copyWith(lastDoneDate: Value(day(0)), lastDoneOdometer: const Value(9900));
    final entries = [testEntry(type: EntryType.odometer, odometer: 10500, date: day(50))];
    final s = computeReminderStatus(reminder: reminder, vehicle: vehicle, entries: entries, resets: [], now: day(60));
    expect(s.baseline.manual, isTrue);
    expect(s.distanceLeft, 400);
    expect(s.daysLeft, 40);
  });

  test('last done date alone takes the odometer known then', () {
    final reminder = testReminder(distance: 1000, createdAt: day(50)).copyWith(lastDoneDate: Value(day(5)));
    final entries = [
      testEntry(type: EntryType.odometer, odometer: 10000, date: day(0)),
      testEntry(type: EntryType.odometer, odometer: 10600, date: day(50)),
    ];
    final s = computeReminderStatus(reminder: reminder, vehicle: vehicle, entries: entries, resets: [], now: day(50));
    expect(s.baseline.odometer, 10000);
    expect(s.distanceLeft, 400);
  });

  test('a later service entry overrides the hand-entered values', () {
    final reminder = testReminder(distance: 1000, createdAt: day(0)).copyWith(lastDoneDate: Value(day(0)), lastDoneOdometer: const Value(9000));
    final service = testEntry(id: 's1', type: EntryType.service, odometer: 10800, date: day(20));
    final s = computeReminderStatus(
      reminder: reminder,
      vehicle: vehicle,
      entries: [service],
      resets: [const ReminderReset(entryId: 's1', reminderId: 'r1')],
      now: day(30),
    );
    expect(s.baseline.resetEntry?.id, 's1');
    expect(s.distanceLeft, 1000);
  });

  group('time domain', () {
    final entries = [
      testEntry(type: EntryType.odometer, odometer: 10000, date: day(0)),
      testEntry(type: EntryType.odometer, odometer: 10250, date: day(10)), // 25 km/day
    ];

    test('mileage runs out first: estimated days and the distance fraction', () {
      final r = testReminder(distance: 1000, days: 365, createdAt: day(0));
      final s = computeReminderStatus(reminder: r, vehicle: vehicle, entries: entries, resets: [], now: day(10));
      expect(s.estimatedDaysByDistance, 30); // 750 km left
      expect(s.dueInDays, 30);
      expect(s.dueIsEstimated, isTrue);
      expect(s.dueFraction, 0.75);
    });

    test('the calendar runs out first: real days and the date fraction', () {
      final r = testReminder(distance: 10000, days: 40, createdAt: day(0));
      final s = computeReminderStatus(reminder: r, vehicle: vehicle, entries: entries, resets: [], now: day(10));
      expect(s.dueInDays, 30);
      expect(s.dueIsEstimated, isFalse);
      expect(s.dueFraction, 0.75);
    });

    test('no time estimate without a date interval or mileage history', () {
      final r = testReminder(distance: 1000, createdAt: day(0));
      final s = computeReminderStatus(reminder: r, vehicle: vehicle, entries: [entries.first], resets: [], now: day(10));
      expect(s.dueInDays, isNull);
      expect(s.dueFraction, s.minFraction);
    });
  });

  test('gaps between the services that reset a reminder', () {
    final a = testEntry(id: 'a', type: EntryType.service, odometer: 10000, date: day(0));
    final b = testEntry(id: 'b', type: EntryType.service, odometer: 17200, date: day(300));
    final c = testEntry(id: 'c', type: EntryType.service, odometer: 25000, date: day(700));
    final other = testEntry(id: 'x', type: EntryType.service, odometer: 20000, date: day(500));
    final resets = [
      for (final id in ['c', 'a', 'b']) ReminderReset(entryId: id, reminderId: 'r1'),
      const ReminderReset(entryId: 'x', reminderId: 'r2'),
    ];
    final gaps = serviceGaps('r1', [c, other, a, b], resets);
    expect(gaps.map((g) => (g.distance, g.days)), [(7200, 300), (7800, 400)]);
    expect(serviceGaps('r2', [c, other, a, b], resets), isEmpty);
  });
}
