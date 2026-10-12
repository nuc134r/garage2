import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/app.dart';
import 'package:garage/app/router.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/features/backup/data/backup_service.dart';
import 'package:garage/features/backup/domain/backup_data.dart';
import 'package:garage/features/backup/domain/sample_data.dart';
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
    'reminders': (s) => Routes.reminders(s.vehicles.first.id),
    'reminder details': (s) => Routes.reminder(s.vehicles.first.id, s.reminders.first.id),
    'reminder edit': (s) => Routes.editReminder(s.vehicles.first.id, s.reminders.first.id),
    'new entry': (s) => Routes.newEntry(s.vehicles.first.id),
    'entry details': (s) => Routes.entry(s.vehicles.first.id, s.entries.first.id),
    'entry edit': (s) => Routes.editEntry(s.vehicles.first.id, s.entries.first.id),
    'garage': (_) => Routes.garage,
    'vehicle edit': (s) => Routes.editVehicle(s.vehicles.first.id),
    'settings': (_) => Routes.settings,
    'backup': (_) => Routes.backup,
    'dictionaries': (_) => Routes.dictionaries,
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
}

/// Pumps frames while letting real async work (the database) complete.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
