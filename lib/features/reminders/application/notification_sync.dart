import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../core/format/vehicle_format.dart';
import '../../../l10n/l10n.dart';
import '../../settings/data/settings_repository.dart';
import '../../vehicles/data/vehicle_repository.dart';
import '../data/reminder_notifications.dart';
import '../data/reminder_repository.dart';
import '../domain/notification_plan.dart';
import '../presentation/reminder_tile.dart';

/// Android keeps a limited number of alarms per app; schedule the nearest ones.
const _maxScheduled = 60;

/// Reminder statuses across all active vehicles.
final allReminderStatusesProvider = FutureProvider<List<VehicleReminder>>((ref) async {
  final vehicles = await ref.watch(vehiclesProvider.future);
  return [
    for (final v in vehicles)
      for (final s in await ref.watch(reminderStatusesProvider(v.id).future)) (vehicle: v, status: s),
  ];
});

/// Opens the route of a tapped notification.
final notificationTapsProvider = Provider<void>((ref) {
  final router = ref.watch(routerProvider);
  final sub = ref.watch(reminderNotificationsProvider).taps.listen(router.go);
  ref.onDispose(sub.cancel);
});

/// Keeps scheduled notifications in sync with reminders and settings; watched by the app root.
final notificationSyncProvider = Provider<void>((ref) {
  ref.watch(notificationTapsProvider);
  final settings = ref.watch(appSettingsProvider).value;
  final items = ref.watch(allReminderStatusesProvider).value;
  if (settings == null || items == null) return;
  final service = ref.read(reminderNotificationsProvider);
  final repo = ref.read(settingsRepositoryProvider);
  // Serialize runs so a cancel-all never interleaves with another run's scheduling.
  _pending = _pending
      .then((_) => syncNotifications(service: service, settingsRepo: repo, settings: settings, items: items))
      .catchError((Object e) => debugPrint('Notification sync failed: $e'));
});

Future<void> _pending = Future.value();

AppLocalizations localizationsFor(Locale? preferred) {
  final code = (preferred ?? PlatformDispatcher.instance.locale).languageCode;
  final supported = AppLocalizations.supportedLocales.any((l) => l.languageCode == code);
  return lookupAppLocalizations(Locale(supported ? code : 'en'));
}

Future<void> syncNotifications({
  required ReminderNotifications service,
  required SettingsRepository settingsRepo,
  required AppSettingsState settings,
  required List<VehicleReminder> items,
  DateTime? now,
}) async {
  if (!settings.notificationsEnabled) {
    await service.reschedule(const []);
    return;
  }
  final time = now ?? clock.now();
  final l10n = localizationsFor(settings.locale);
  final lead = settings.notifyLeadDays;

  String title(VehicleReminder i) => l10n.notifTitle(i.status.reminder.name, i.vehicle.name);
  String route(VehicleReminder i) => Routes.reminder(i.vehicle.id, i.status.reminder.id);

  if (service.canSchedule) {
    final alerts = planAlerts(items, now: time, leadDays: lead, perVehicle: settings.vehicleNotify).take(_maxScheduled);
    await service.reschedule([
      for (final a in alerts)
        ScheduledNotice(
          id: a.id,
          at: a.at,
          title: title(a.item),
          body: a.kind == AlertKind.due ? l10n.notifDueToday : l10n.dueIn(formatDays(l10n, a.daysBeforeDue)),
          route: route(a.item),
        ),
    ]);
  }

  // Once a day, summarize what is due soon or overdue (the only kind of alert on the web).
  final today = '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}';
  final attention = needingAttention(items, leadDays: lead, perVehicle: settings.vehicleNotify);
  if (attention.isEmpty || settings.lastAttentionDay == today) return;
  await settingsRepo.set(SettingKeys.lastAttentionDay, today);
  final lines = [
    for (final i in attention.take(5)) '${title(i)}: ${reminderStatusText(VehicleFormat(l10n, i.vehicle), i.status)}',
  ];
  await service.showNow(
    id: notificationId('attention'),
    title: attention.length == 1 ? title(attention.single) : l10n.notifAttentionTitle(attention.length),
    body: attention.length == 1 ? reminderStatusText(VehicleFormat(l10n, attention.single.vehicle), attention.single.status) : lines.join('\n'),
    route: attention.length == 1 ? route(attention.single) : Routes.reminders(attention.first.vehicle.id),
  );
}
