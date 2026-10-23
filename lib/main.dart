import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'features/reminders/application/notification_sync.dart';
import 'features/reminders/data/reminder_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the browser address bar in sync with push/pop navigation.
  GoRouter.optionURLReflectsImperativeAPIs = true;
  final notifications = await PluginReminderNotifications.create(
    channelName: localizationsFor(null).notifChannelName,
  );
  runApp(ProviderScope(
    overrides: [reminderNotificationsProvider.overrideWithValue(notifications)],
    child: const GarageApp(splash: true),
  ));
}
