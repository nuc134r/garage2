import 'package:flutter_test/flutter_test.dart';
import 'package:garage/features/reminders/domain/notification_plan.dart';
import 'package:garage/features/reminders/domain/reminder_status.dart';

import 'helpers.dart';

void main() {
  final vehicle = testVehicle();
  final now = DateTime(2025, 6, 1, 12);

  VehicleReminder item({int? daysLeft, int? distanceLeft, int? estimatedDays, String id = 'r1'}) {
    final reminder = testReminder(id: id, distance: distanceLeft == null ? null : 1000, days: daysLeft == null ? null : 100, createdAt: now);
    return (
      vehicle: vehicle,
      status: ReminderStatus(
        reminder: reminder,
        baseline: ReminderBaseline(odometer: 0, date: now),
        daysLeft: daysLeft,
        distanceLeft: distanceLeft,
        estimatedDaysByDistance: estimatedDays,
      ),
    );
  }

  group('daysUntilDue', () {
    test('uses the earlier of date and mileage estimate', () {
      expect(daysUntilDue(item(daysLeft: 30, distanceLeft: 500, estimatedDays: 10).status), 10);
      expect(daysUntilDue(item(daysLeft: 5, distanceLeft: 500, estimatedDays: 10).status), 5);
    });

    test('distance already exceeded means due now', () {
      expect(daysUntilDue(item(daysLeft: 30, distanceLeft: -20).status), 0);
    });

    test('unknown without date interval or mileage estimate', () {
      expect(daysUntilDue(item(distanceLeft: 500).status), isNull);
    });
  });

  test('plans a due-soon and a due alert at 10:00', () {
    final alerts = planAlerts([item(daysLeft: 20)], now: now, leadDays: 7);
    expect(alerts.map((a) => (a.kind, a.at)), [
      (AlertKind.dueSoon, DateTime(2025, 6, 14, 10)),
      (AlertKind.due, DateTime(2025, 6, 21, 10)),
    ]);
  });

  test('skips alerts in the past', () {
    final alerts = planAlerts([item(daysLeft: 3), item(id: 'r2', daysLeft: -4)], now: now, leadDays: 7);
    expect(alerts.single.kind, AlertKind.due);
    expect(alerts.single.at, DateTime(2025, 6, 4, 10));
  });

  test('ids are stable and distinct per reminder and kind', () {
    final a = planAlerts([item(daysLeft: 20)], now: now);
    final b = planAlerts([item(daysLeft: 25)], now: now);
    expect(a.map((x) => x.id), b.map((x) => x.id));
    expect(a[0].id, isNot(a[1].id));
    expect(notificationId('x'), inInclusiveRange(0, 0x7FFFFFFF));
  });

  test('needing attention: overdue first, then soon; far ones excluded', () {
    final list = needingAttention([
      item(id: 'far', daysLeft: 60),
      item(id: 'soon', daysLeft: 5),
      item(id: 'over', daysLeft: -3),
    ], leadDays: 7);
    expect(list.map((i) => i.status.reminder.id), ['over', 'soon']);
  });
}
