import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/model/enums.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/dictionaries/presentation/dictionaries_screen.dart';
import '../features/entries/presentation/entry_details_screen.dart';
import '../features/entries/presentation/entry_edit_screen.dart';
import '../features/home/home_screen.dart';
import '../features/reminders/presentation/reminder_details_screen.dart';
import '../features/reminders/presentation/reminder_edit_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/vehicles/presentation/garage_screen.dart';
import '../features/vehicles/presentation/launch_screen.dart';
import '../features/vehicles/presentation/vehicle_edit_screen.dart';

/// Paths used across the app.
abstract final class Routes {
  static const launch = '/';
  static String home(String vid) => '/v/$vid';
  static String stats(String vid) => '/v/$vid/stats';
  static String reminders(String vid) => '/v/$vid/reminders';
  static String newReminder(String vid) => '/v/$vid/reminders/new';
  static String reminder(String vid, String rid) => '/v/$vid/reminders/$rid';
  static String editReminder(String vid, String rid) => '/v/$vid/reminders/$rid/edit';
  static String newEntry(String vid, {EntryType? type}) => '/v/$vid/entries/new${type == null ? '' : '?type=${type.name}'}';
  static String entry(String vid, String eid) => '/v/$vid/entries/$eid';
  static String editEntry(String vid, String eid) => '/v/$vid/entries/$eid/edit';
  static const garage = '/garage';
  static const newVehicle = '/garage/new';
  static String editVehicle(String vid) => '/garage/$vid/edit';
  static const settings = '/settings';
  static const backup = '/settings/backup';
  static const dictionaries = '/settings/dictionaries';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.launch,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const LaunchScreen()),
      GoRoute(
        path: '/v/:vid',
        builder: (_, s) => HomeScreen(vehicleId: s.pathParameters['vid']!),
        routes: [
          GoRoute(path: 'stats', builder: (_, s) => StatsScreen(vehicleId: s.pathParameters['vid']!)),
          GoRoute(
            path: 'reminders',
            builder: (_, s) => RemindersScreen(vehicleId: s.pathParameters['vid']!),
            routes: [
              GoRoute(path: 'new', builder: (_, s) => ReminderEditScreen(vehicleId: s.pathParameters['vid']!)),
              GoRoute(
                path: ':rid',
                builder: (_, s) => ReminderDetailsScreen(vehicleId: s.pathParameters['vid']!, reminderId: s.pathParameters['rid']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, s) => ReminderEditScreen(vehicleId: s.pathParameters['vid']!, reminderId: s.pathParameters['rid']),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'entries/new',
            builder: (_, s) => EntryEditScreen(
              vehicleId: s.pathParameters['vid']!,
              initialType: EntryType.values.asNameMap()[s.uri.queryParameters['type']],
            ),
          ),
          GoRoute(
            path: 'entries/:eid',
            builder: (_, s) => EntryDetailsScreen(vehicleId: s.pathParameters['vid']!, entryId: s.pathParameters['eid']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, s) => EntryEditScreen(vehicleId: s.pathParameters['vid']!, entryId: s.pathParameters['eid']),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/garage',
        builder: (_, _) => const GarageScreen(),
        routes: [
          GoRoute(path: 'new', builder: (_, _) => const VehicleEditScreen()),
          GoRoute(path: ':vid/edit', builder: (_, s) => VehicleEditScreen(vehicleId: s.pathParameters['vid'])),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (_, _) => const SettingsScreen(),
        routes: [
          GoRoute(path: 'backup', builder: (_, _) => const BackupScreen()),
          GoRoute(path: 'dictionaries', builder: (_, _) => const DictionariesScreen()),
        ],
      ),
    ],
  );
});
