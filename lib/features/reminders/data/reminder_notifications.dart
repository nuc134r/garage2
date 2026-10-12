import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// A notification to schedule (Android) — already localized.
class ScheduledNotice {
  const ScheduledNotice({required this.id, required this.at, required this.title, required this.body, required this.route});

  final int id;
  final DateTime at;
  final String title;
  final String body;

  /// Route opened when the notification is tapped.
  final String route;
}

/// Platform notifications. Android schedules ahead of time; the web can only show immediately.
abstract class ReminderNotifications {
  /// Whether notifications can be scheduled while the app is closed.
  bool get canSchedule;

  /// Routes from tapped notifications while the app is running.
  Stream<String> get taps;

  /// Route of the notification that launched the app, if any (consumed once).
  String? takeLaunchRoute();

  Future<bool> requestPermission();

  Future<void> reschedule(List<ScheduledNotice> notices);

  Future<void> showNow({required int id, required String title, required String body, required String route});
}

class NoopReminderNotifications implements ReminderNotifications {
  @override
  bool get canSchedule => false;

  @override
  Stream<String> get taps => const Stream.empty();

  @override
  String? takeLaunchRoute() => null;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> reschedule(List<ScheduledNotice> notices) async {}

  @override
  Future<void> showNow({required int id, required String title, required String body, required String route}) async {}
}

class PluginReminderNotifications implements ReminderNotifications {
  PluginReminderNotifications._();

  static const _channelId = 'reminders';

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  String? _launchRoute;

  /// Initializes the plugin; falls back to a no-op implementation when unsupported.
  static Future<ReminderNotifications> create({required String channelName}) async {
    final self = PluginReminderNotifications._();
    try {
      final ok = await self._plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@drawable/ic_stat_notification'),
          web: WebInitializationSettings(),
        ),
        onDidReceiveNotificationResponse: (r) {
          if (r.payload case final route? when route.isNotEmpty) self._taps.add(route);
        },
      );
      if (ok != true) return NoopReminderNotifications();
      if (!kIsWeb) {
        tzdata.initializeTimeZones();
        final zone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zone.identifier));
        final launch = await self._plugin.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp ?? false) self._launchRoute = launch!.notificationResponse?.payload;
        await self._plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(AndroidNotificationChannel(_channelId, channelName, importance: Importance.defaultImportance));
      }
      return self;
    } catch (e) {
      debugPrint('Notifications unavailable: $e');
      return NoopReminderNotifications();
    }
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelId,
          category: AndroidNotificationCategory.reminder,
          icon: '@drawable/ic_stat_notification',
          color: Color(0xFF173C51),
        ),
      );

  @override
  bool get canSchedule => !kIsWeb;

  @override
  Stream<String> get taps => _taps.stream;

  @override
  String? takeLaunchRoute() {
    final route = _launchRoute;
    _launchRoute = null;
    return route;
  }

  @override
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      return await _plugin.resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ??
          false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> reschedule(List<ScheduledNotice> notices) async {
    if (!canSchedule) return;
    await _plugin.cancelAllPendingNotifications();
    for (final n in notices) {
      await _plugin.zonedSchedule(
        id: n.id,
        scheduledDate: tz.TZDateTime.from(n.at, tz.local),
        notificationDetails: _details(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: n.title,
        body: n.body,
        payload: n.route,
      );
    }
  }

  @override
  Future<void> showNow({required int id, required String title, required String body, required String route}) =>
      _plugin.show(id: id, title: title, body: body, notificationDetails: _details(), payload: route);
}

/// Overridden in `main()` with the initialized implementation.
final reminderNotificationsProvider = Provider<ReminderNotifications>((ref) => NoopReminderNotifications());
