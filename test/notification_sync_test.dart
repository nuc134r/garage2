import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/features/reminders/application/notification_sync.dart';
import 'package:garage/features/reminders/data/reminder_notifications.dart';
import 'package:garage/features/reminders/domain/notification_plan.dart';
import 'package:garage/features/reminders/domain/reminder_status.dart';
import 'package:garage/features/settings/data/settings_repository.dart';

import 'helpers.dart';

class FakeNotifications implements ReminderNotifications {
  FakeNotifications({this.canSchedule = true});

  @override
  final bool canSchedule;

  final scheduled = <List<ScheduledNotice>>[];
  final shown = <({String title, String body, String route})>[];

  @override
  Stream<String> get taps => const Stream.empty();

  @override
  String? takeLaunchRoute() => null;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> reschedule(List<ScheduledNotice> notices) async => scheduled.add(notices);

  @override
  Future<void> showNow({required int id, required String title, required String body, required String route}) async =>
      shown.add((title: title, body: body, route: route));
}

void main() {
  late AppDatabase db;
  late SettingsRepository repo;
  final now = DateTime(2025, 6, 1, 12);
  final vehicle = testVehicle();

  VehicleReminder item(String id, int daysLeft) => (
        vehicle: vehicle,
        status: ReminderStatus(
          reminder: testReminder(id: id, days: 100, createdAt: now),
          baseline: ReminderBaseline(odometer: 0, date: now),
          daysLeft: daysLeft,
          daysFraction: daysLeft / 100,
        ),
      );

  setUp(() {
    db = memoryDb();
    repo = SettingsRepository(db);
  });
  tearDown(() => db.close());

  Future<void> sync(FakeNotifications fake, List<VehicleReminder> items) async =>
      syncNotifications(service: fake, settingsRepo: repo, settings: await repo.load(), items: items, now: now);

  test('disabled: cancels everything and shows nothing', () async {
    final fake = FakeNotifications();
    await sync(fake, [item('a', -1)]);
    expect(fake.scheduled.single, isEmpty);
    expect(fake.shown, isEmpty);
  });

  test('enabled: schedules future alerts and shows a daily summary once', () async {
    await repo.set(SettingKeys.notifications, 'true');
    await repo.set(SettingKeys.locale, 'en');
    final fake = FakeNotifications();
    final items = [item('later', 20), item('overdue', -2)];

    await sync(fake, items);
    expect(fake.scheduled.single.map((n) => n.at), [DateTime(2025, 6, 14, 10), DateTime(2025, 6, 21, 10)]);
    expect(fake.scheduled.single.first.body, 'in 7 days');
    expect(fake.shown.single.title, 'Oil · Test');
    expect(fake.shown.single.body, contains('overdue by 2 days'));
    expect(fake.shown.single.route, '/v/v1/reminders/overdue');

    await sync(fake, items);
    expect(fake.shown, hasLength(1), reason: 'summary is shown at most once a day');
  });

  test('web: no scheduling, summary only', () async {
    await repo.set(SettingKeys.notifications, 'true');
    final fake = FakeNotifications(canSchedule: false);
    await sync(fake, [item('a', 3), item('b', 5)]);
    expect(fake.scheduled, isEmpty);
    expect(fake.shown.single.route, '/v/v1/reminders');
  });
}
