import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/model/enums.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/dictionaries/presentation/dictionaries_screen.dart';
import '../features/entries/presentation/entry_details_screen.dart';
import '../features/entries/presentation/entry_edit_screen.dart';
import '../features/home/domain/home_tiles.dart';
import '../features/home/home_screen.dart';
import '../features/home/presentation/home_tiles_screen.dart';
import '../features/reminders/presentation/reminder_details_screen.dart';
import '../features/reminders/presentation/reminder_edit_screen.dart';
import '../features/reminders/presentation/reminders_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/updates/presentation/version_screen.dart';
import '../features/stats/domain/stats_calculator.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/vehicles/presentation/garage_screen.dart';
import '../features/vehicles/presentation/launch_screen.dart';
import '../features/vehicles/presentation/vehicle_edit_screen.dart';

/// Paths used across the app.
abstract final class Routes {
  static const launch = '/';
  static String home(String vid) => '/v/$vid';
  static String stats(String vid, {StatsPeriod? period, HomeMetric? focus}) {
    final query = {'period': ?period?.name, 'focus': ?focus?.name};
    return Uri(path: '/v/$vid/stats', queryParameters: query.isEmpty ? null : query).toString();
  }
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
  static const homeTiles = '/settings/home-tiles';
  static const version = '/settings/version';
}

/// Every route gets an explicit [MaterialPage]: go_router 18 detects the app type by looking for
/// `package:material_ui`'s MaterialApp, misses Flutter's, and would fall back to pages without
/// transitions (which also disables Hero flights and the predictive back animation).
GoRoute _route(String path, Widget Function(GoRouterState state) build, {List<RouteBase> routes = const []}) => GoRoute(
      path: path,
      pageBuilder: (_, state) => MaterialPage<void>(
        key: state.pageKey,
        name: state.uri.path,
        arguments: state.extra,
        restorationId: state.pageKey.value,
        child: build(state),
      ),
      routes: routes,
    );

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.launch,
    routes: [
      _route('/', (_) => const LaunchScreen()),
      _route(
        '/v/:vid',
        (s) => HomeScreen(vehicleId: s.pathParameters['vid']!),
        routes: [
          _route(
            'stats',
            (s) => StatsScreen(
              vehicleId: s.pathParameters['vid']!,
              initialPeriod: StatsPeriod.values.asNameMap()[s.uri.queryParameters['period']] ?? StatsPeriod.allTime,
              focus: HomeMetric.values.asNameMap()[s.uri.queryParameters['focus']],
            ),
          ),
          _route(
            'reminders',
            (s) => RemindersScreen(vehicleId: s.pathParameters['vid']!),
            routes: [
              _route('new', (s) => ReminderEditScreen(vehicleId: s.pathParameters['vid']!)),
              _route(
                ':rid',
                (s) => ReminderDetailsScreen(vehicleId: s.pathParameters['vid']!, reminderId: s.pathParameters['rid']!),
                routes: [
                  _route(
                    'edit',
                    (s) => ReminderEditScreen(vehicleId: s.pathParameters['vid']!, reminderId: s.pathParameters['rid']),
                  ),
                ],
              ),
            ],
          ),
          _route(
            'entries/new',
            (s) => EntryEditScreen(
              vehicleId: s.pathParameters['vid']!,
              initialType: EntryType.values.asNameMap()[s.uri.queryParameters['type']],
            ),
          ),
          _route(
            'entries/:eid',
            (s) => EntryDetailsScreen(vehicleId: s.pathParameters['vid']!, entryId: s.pathParameters['eid']!),
            routes: [
              _route(
                'edit',
                (s) => EntryEditScreen(vehicleId: s.pathParameters['vid']!, entryId: s.pathParameters['eid']),
              ),
            ],
          ),
        ],
      ),
      _route(
        '/garage',
        (_) => const GarageScreen(),
        routes: [
          _route('new', (_) => const VehicleEditScreen()),
          _route(':vid/edit', (s) => VehicleEditScreen(vehicleId: s.pathParameters['vid'])),
        ],
      ),
      _route(
        '/settings',
        (_) => const SettingsScreen(),
        routes: [
          _route('backup', (_) => const BackupScreen()),
          _route('dictionaries', (_) => const DictionariesScreen()),
          _route('home-tiles', (_) => const HomeTilesScreen()),
          _route('version', (_) => const VersionScreen()),
        ],
      ),
    ],
  );
});
