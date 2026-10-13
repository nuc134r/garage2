import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/app.dart';
import 'package:garage/app/router.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/features/backup/data/backup_service.dart';
import 'package:garage/features/backup/domain/backup_data.dart';
import 'package:garage/features/backup/domain/sample_data.dart';
import 'package:garage/features/home/domain/home_tiles.dart';
import 'package:garage/features/settings/data/settings_repository.dart';
import 'package:garage/features/stats/domain/stats_calculator.dart';
import 'package:garage/features/stats/presentation/stats_screen.dart';
import 'package:garage/core/widgets/widgets.dart';
import 'package:go_router/go_router.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late BackupData sample;

  setUp(() async {
    db = memoryDb();
    sample = buildSampleData();
    await BackupService(db).import(sample, ImportStrategy.merge);
  });

  tearDown(() => db.close());

  Future<GoRouter> pumpApp(WidgetTester tester, {Size size = const Size(412, 880)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      appVersionProvider.overrideWith((ref) async => '1.0.0+1'),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const GarageApp()));
    await settle(tester);
    return container.read(routerProvider);
  }

  final screens = <String, String Function(BackupData)>{
    'home': (s) => Routes.home(s.vehicles.first.id),
    'stats': (s) => Routes.stats(s.vehicles.first.id),
    'stats from a tile': (s) => Routes.stats(s.vehicles.first.id, period: StatsPeriod.week, focus: HomeMetric.fuelPrice),
    'reminders': (s) => Routes.reminders(s.vehicles.first.id),
    'reminder details': (s) => Routes.reminder(s.vehicles.first.id, s.reminders.first.id),
    'reminder edit': (s) => Routes.editReminder(s.vehicles.first.id, s.reminders.first.id),
    'new entry': (s) => Routes.newEntry(s.vehicles.first.id),
    'entry details': (s) => Routes.entry(s.vehicles.first.id, s.entries.first.id),
    'entry edit': (s) => Routes.editEntry(s.vehicles.first.id, s.entries.first.id),
    'entry with attachment': (s) => Routes.entry(_vehicleOf(s, s.attachments.first.entryId), s.attachments.first.entryId),
    'entry edit with attachment': (s) => Routes.editEntry(_vehicleOf(s, s.attachments.first.entryId), s.attachments.first.entryId),
    'garage': (_) => Routes.garage,
    'vehicle edit': (s) => Routes.editVehicle(s.vehicles.first.id),
    'settings': (_) => Routes.settings,
    'backup': (_) => Routes.backup,
    'dictionaries': (_) => Routes.dictionaries,
    'home tiles': (_) => Routes.homeTiles,
  };

  for (final size in const [Size(412, 880), Size(1280, 800)]) {
    for (final MapEntry(key: name, value: path) in screens.entries) {
      testWidgets('$name renders at ${size.width.toInt()}px', (tester) async {
        final router = await pumpApp(tester, size: size);
        router.go(path(sample));
        await settle(tester);
        expect(tester.takeException(), isNull);
        expect(find.byType(ErrorWidget), findsNothing);
      });
    }
  }

  testWidgets('home shows stat tiles and entries', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.home(sample.vehicles.first.id));
    await settle(tester);
    expect(find.text('Fuel'), findsWidgets);
    expect(find.text('All stats'), findsOneWidget);
    expect(find.text('Hyundai i30 N'), findsOneWidget);
  });

  testWidgets('opening an entry and a stat tile flies their heroes', (tester) async {
    final router = await pumpApp(tester);
    final vid = sample.vehicles.first.id;
    router.go(Routes.home(vid));
    await settle(tester);

    await tester.tap(find.text('Fuel').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Mid-transition: the page animates in (go_router would otherwise use NoTransitionPage) and the tile flies.
    final route = ModalRoute.of(tester.element(find.byType(StatsScreen)))!;
    expect(route.animation!.value, inExclusiveRange(0, 1));
    expect(find.byType(StatTile), findsWidgets);
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    await settle(tester);
    expect(router.state.uri.path, Routes.stats(vid));
    expect(router.state.uri.queryParameters, {'period': 'month', 'focus': 'fuelCost'});
    expect(DefaultTabController.of(tester.element(find.byType(TabBarView))).index, StatsTab.fuel.index);

    router.pop();
    await settle(tester);
    await tester.tap(find.byType(ListTile).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    await settle(tester);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    await settle(tester);
  });

  testWidgets('stats: charts render and a custom range can be picked', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.stats(sample.vehicles.first.id));
    await settle(tester);
    expect(find.textContaining('Efficiency trend'), findsOneWidget, reason: 'opens on the fuel tab');
    for (final (tab, content) in [('Expenses', 'Costs by month'), ('Mileage', 'Odometer'), ('Service', 'History')]) {
      await tester.tap(find.widgetWithText(Tab, tab));
      await settle(tester);
      expect(find.textContaining(content), findsWidgets, reason: tab);
    }

    await tester.ensureVisible(find.text('Custom…'));
    await tester.tap(find.text('Custom…'));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Custom…'), findsNothing, reason: 'the chip shows the picked dates');
  });

  testWidgets('home tiles follow the setting', (tester) async {
    await SettingsRepository(db).set(SettingKeys.homeTiles, 'fuelVolume:week,odometer:allTime,mileage:year');
    final router = await pumpApp(tester);
    router.go(Routes.home(sample.vehicles.first.id));
    await settle(tester);
    expect(find.text('Fuel volume'), findsOneWidget);
    expect(find.text('7d'), findsOneWidget);
    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('1y'), findsOneWidget);
    expect(find.text('Efficiency'), findsNothing);
  });
}

/// Pumps frames while letting real async work (the database) complete.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _vehicleOf(BackupData s, String entryId) => s.entries.firstWhere((e) => e.id == entryId).vehicleId;
