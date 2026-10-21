import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:garage/features/home/home_screen.dart';
import 'package:garage/features/vehicles/data/vehicle_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/app.dart';
import 'package:garage/app/router.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/core/model/enums.dart';
import 'package:garage/features/backup/data/backup_service.dart';
import 'package:garage/features/backup/domain/backup_data.dart';
import 'package:garage/features/backup/domain/sample_data.dart';
import 'package:garage/features/entries/presentation/entry_list_item.dart';
import 'package:garage/features/home/domain/home_tiles.dart';
import 'package:garage/features/settings/data/settings_repository.dart';
import 'package:garage/features/updates/data/update_service.dart';
import 'package:garage/features/updates/domain/release.dart';
import 'package:garage/features/stats/domain/stats_calculator.dart';
import 'package:garage/features/stats/presentation/stats_screen.dart';
import 'package:garage/core/widgets/widgets.dart';
import 'package:garage/l10n/gen/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ota_update/ota_update.dart';

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

  Future<GoRouter> pumpApp(
    WidgetTester tester, {
    Size size = const Size(412, 880),
    Release? update,
    UpdateService? updateService,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appVersionProvider.overrideWith((ref) async => '1.0.0+1'),
        if (update != null) availableUpdateProvider.overrideWith((ref) async => update),
        if (updateService != null) updateServiceProvider.overrideWithValue(updateService),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const GarageApp()));
    await settle(tester);
    return container.read(routerProvider);
  }

  final screens = <String, String Function(BackupData)>{
    'home': (s) => Routes.home(s.vehicles.first.id),
    'stats': (s) => Routes.stats(s.vehicles.first.id),
    'stats from a tile': (s) =>
        Routes.stats(s.vehicles.first.id, period: StatsPeriod.week, focus: HomeMetric.fuelPrice),
    'reminders': (s) => Routes.reminders(s.vehicles.first.id),
    'reminder details': (s) => Routes.reminder(s.vehicles.first.id, s.reminders.first.id),
    'reminder edit': (s) => Routes.editReminder(s.vehicles.first.id, s.reminders.first.id),
    'new entry': (s) => Routes.newEntry(s.vehicles.first.id),
    'entry details': (s) => Routes.entry(s.vehicles.first.id, s.entries.first.id),
    'entry edit': (s) => Routes.editEntry(s.vehicles.first.id, s.entries.first.id),
    'entry with attachment': (s) =>
        Routes.entry(_vehicleOf(s, s.attachments.first.entryId), s.attachments.first.entryId),
    'entry edit with attachment': (s) =>
        Routes.editEntry(_vehicleOf(s, s.attachments.first.entryId), s.attachments.first.entryId),
    'garage': (_) => Routes.garage,
    'vehicle edit': (s) => Routes.editVehicle(s.vehicles.first.id),
    'settings': (_) => Routes.settings,
    'backup': (_) => Routes.backup,
    'dictionaries': (_) => Routes.dictionaries,
    'home tiles': (_) => Routes.homeTiles,
    'app version': (_) => Routes.version,
    'vehicle notifications': (_) => Routes.vehicleNotifications,
    'compare vehicles': (s) => Routes.compareVehicles(s.vehicles.first.id),
    'stats of an electric car': (s) => Routes.stats(s.vehicles.last.id),
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

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('main screens render in ${locale.languageCode}', (tester) async {
      await SettingsRepository(db).set(SettingKeys.locale, locale.languageCode);
      final router = await pumpApp(tester);
      final vid = sample.vehicles.first.id;
      for (final path in [
        Routes.home(vid),
        Routes.stats(vid),
        Routes.reminder(vid, sample.reminders.first.id),
        Routes.newEntry(vid),
        Routes.entry(vid, sample.entries.first.id),
        Routes.editVehicle(vid),
        Routes.settings,
      ]) {
        router.go(path);
        await settle(tester);
        expect(tester.takeException(), isNull, reason: path);
      }
    });
  }

  testWidgets('home shows stat tiles and entries', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.home(sample.vehicles.first.id));
    await settle(tester);
    expect(find.text('Fuel'), findsWidgets);
    expect(find.text('All stats'), findsOneWidget);
    expect(find.text('Honda Civic'), findsOneWidget);
  });

  testWidgets('an electric vehicle charges instead of refuelling', (tester) async {
    final router = await pumpApp(tester);
    final tesla = sample.vehicles.firstWhere((v) => v.volumeUnit == VolumeUnit.kwh).id;
    router.go(Routes.home(tesla));
    await settle(tester);
    expect(find.text('Charging'), findsWidgets);
    expect(find.text('Fuel'), findsNothing);
    expect(find.byIcon(Icons.ev_station), findsWidgets);
    expect(find.textContaining('kWh'), findsWidgets);
  });

  testWidgets('a stat tile opens its tab; an entry flies its icon, title and cost', (tester) async {
    final router = await pumpApp(tester);
    final vid = sample.vehicles.first.id;
    router.go(Routes.home(vid));
    await settle(tester);

    await tester.tap(find.text('Fuel').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // Mid-transition: the page animates in (go_router would otherwise use NoTransitionPage); tiles don't fly.
    final route = ModalRoute.of(tester.element(find.byType(StatsScreen)))!;
    expect(route.animation!.value, inExclusiveRange(0, 1));
    expect(find.descendant(of: find.byType(StatsScreen), matching: find.byType(StatTile)), findsNothing);
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    await settle(tester);
    expect(router.state.uri.path, Routes.stats(vid));
    expect(router.state.uri.queryParameters, {'period': 'month', 'focus': 'fuelCost'});
    expect(DefaultTabController.of(tester.element(find.byType(TabBarView))).index, StatsTab.fuel.index);

    router.pop();
    await settle(tester);
    final entry = tester.widget<EntryListItem>(find.byType(EntryListItem).first).entry;
    Finder costHero() => find.byWidgetPredicate((w) => w is Hero && w.tag == HeroTags.entryCost(entry.id));
    expect(costHero(), findsOneWidget);
    await tester.tap(find.byType(EntryListItem).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    expect(costHero(), findsWidgets, reason: 'the cost flies to the details');
    await settle(tester);
    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(tester.takeException(), isNull);
    await settle(tester);
  });

  testWidgets('odometer suggestions ride on the keyboard and fill the field', (tester) async {
    final router = await pumpApp(tester);
    final vid = sample.vehicles.first.id;
    router.go(Routes.newEntry(vid));
    await settle(tester);
    expect(find.byIcon(Icons.auto_fix_high), findsNothing, reason: 'no keyboard yet');

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await settle(tester);
    expect(find.byIcon(Icons.history), findsOneWidget, reason: 'the last reading');
    final target = tester.getSize(find.ancestor(of: find.byIcon(Icons.history), matching: find.byType(InkWell)));
    expect(target.height, 48, reason: 'a suggestion reacts across the whole strip height');
    expect(target.width, greaterThan(150), reason: 'and across its half of the width');
    await tester.tap(find.byIcon(Icons.auto_fix_high));
    await settle(tester);
    final odometer = tester.widget<TextField>(find.byType(TextField).first).controller!.text;
    final last = sample.entries.where((e) => e.vehicleId == vid).map((e) => e.odometer).reduce(max);
    expect(int.parse(odometer), greaterThan(last), reason: 'the estimate is filled in');
    expect(find.text('Required'), findsNothing, reason: 'only the odometer is checked, not the whole form');
    final focused = FocusManager.instance.primaryFocus!.context!.findAncestorWidgetOfExactType<TextField>();
    expect(focused?.decoration?.labelText, 'Volume', reason: 'picking moves on to the next field');
  });

  testWidgets('the keyboard\'s next action walks through the entry fields', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.newEntry(sample.vehicles.first.id));
    await settle(tester);
    String? focusedLabel() =>
        FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<TextField>()?.decoration?.labelText;
    expect(focusedLabel(), 'Odometer');
    for (final label in ['Odometer', 'Volume', 'Price', 'Total']) {
      final field = tester.widget<TextField>(find.widgetWithText(TextField, label));
      expect(field.textInputAction, TextInputAction.next, reason: '$label shows "next" on the keyboard');
    }
    for (final next in ['Volume', 'Price', 'Total']) {
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await settle(tester);
      expect(focusedLabel(), next);
    }
  });

  testWidgets('the last active vehicle cannot be archived', (tester) async {
    final repo = VehicleRepository(db);
    for (final v in sample.vehicles.skip(1)) {
      await repo.setArchived(v.id, true);
    }
    final router = await pumpApp(tester);
    router.go(Routes.garage);
    await settle(tester);
    await tester.tap(find.byIcon(Icons.more_vert).first);
    await settle(tester);
    await tester.tap(find.text('Archive'));
    await settle(tester);
    expect(find.textContaining('Keep at least one vehicle active'), findsOneWidget);
    final first = (await db.select(db.vehicles).get()).firstWhere((v) => v.id == sample.vehicles.first.id);
    expect(first.archived, isFalse);
  });

  testWidgets('filtering animates the entries in', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.home(sample.vehicles.first.id));
    await settle(tester);
    double opacityOfFirst() => tester
        .widget<FadeTransition>(find.descendant(of: find.byType(EntryAppear).first, matching: find.byType(FadeTransition)).first)
        .opacity
        .value;
    expect(opacityOfFirst(), 1, reason: 'no entrance on first show');
    await tester.tap(find.widgetWithText(FilterChip, 'Service'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(opacityOfFirst(), inExclusiveRange(0, 1), reason: 'the filtered list fades in');
    await settle(tester);
    expect(opacityOfFirst(), 1);
  });

  testWidgets('an entry with attachments keeps its paperclip through the flight', (tester) async {
    final router = await pumpApp(tester);
    final entryId = sample.attachments.first.entryId;
    final vid = _vehicleOf(sample, entryId);
    router.go(Routes.home(vid));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Service'));
    await settle(tester);
    router.push(Routes.entry(vid, entryId));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(
      tester.widgetList<IconBadge>(find.byType(IconBadge)).where((b) => b.attached),
      isNotEmpty,
      reason: 'the badge is on the flying icon from the first frames',
    );
    await settle(tester);
    expect(tester.widgetList<IconBadge>(find.byType(IconBadge)).where((b) => b.attached), isNotEmpty);
  });

  testWidgets('stats: summary, every tab, calendar years and a custom range', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.stats(sample.vehicles.first.id));
    await settle(tester);
    expect(find.text('Cost of ownership'), findsOneWidget);
    expect(find.text('Last 12 months'), findsOneWidget, reason: 'opens on the last 12 months');
    expect(find.textContaining('Costs by month'), findsOneWidget, reason: 'opens on the costs tab');
    for (final (tab, content) in [('Driving', 'Distance by month'), ('Fuel', 'Efficiency per fill'), ('Service', "What's next")]) {
      await tester.tap(find.widgetWithText(Tab, tab));
      await settle(tester);
      expect(find.textContaining(content), findsWidgets, reason: tab);
    }

    final year = find.widgetWithText(ChoiceChip, '${sample.entries.first.date.year}');
    await tester.ensureVisible(year);
    await tester.tap(year);
    await settle(tester);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Custom…'));
    await tester.tap(find.text('Custom…'));
    await settle(tester);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Custom…'), findsNothing, reason: 'the chip shows the picked dates');
  });

  testWidgets('stats compare vehicles side by side', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.stats(sample.vehicles.first.id));
    await settle(tester);
    await tester.tap(find.byIcon(Icons.compare_arrows));
    await settle(tester);
    expect(find.text('Compare vehicles'), findsOneWidget);
    for (final v in sample.vehicles) {
      expect(find.text(v.name), findsWidgets);
    }
  });

  testWidgets('home offers an available update until dismissed', (tester) async {
    const release = Release(version: '9.9.9', pageUrl: '', apks: {'garage-9.9.9.apk': 'https://dl'});
    final router = await pumpApp(tester, update: release);
    router.go(Routes.home(sample.vehicles.first.id));
    await settle(tester);
    expect(find.text('garage 9.9.9 is available'), findsOneWidget);
    await tester.tap(find.text('Later'));
    await settle(tester);
    expect((await SettingsRepository(db).load()).dismissedUpdate, '9.9.9');
  });

  testWidgets('cancelling an update download closes only the progress dialog', (tester) async {
    const release = Release(version: '9.9.9', pageUrl: '', apks: {'garage-9.9.9.apk': 'https://dl'});
    final service = _FakeUpdateService();
    final router = await pumpApp(tester, update: release, updateService: service);
    final home = Routes.home(sample.vehicles.first.id);
    router.go(home);
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Update'));
    await settle(tester);
    service.events.add(OtaEvent(OtaStatus.DOWNLOADING, '40'));
    await settle(tester);
    expect(find.text('40%'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(service.cancelled, isTrue);
    expect(tester.takeException(), isNull);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.textContaining('Update failed'), findsNothing);
    expect(router.state.uri.path, home);
    expect(find.text('Honda Civic'), findsOneWidget);
  });

  testWidgets('notifications can be turned off and timed per vehicle', (tester) async {
    final router = await pumpApp(tester);
    router.go(Routes.vehicleNotifications);
    await settle(tester);
    final civic = sample.vehicles.first;
    expect(find.text('Default: 7 days before'), findsNWidgets(sample.vehicles.length));

    await tester.tap(find.widgetWithText(ListTile, civic.name).first);
    await settle(tester);
    await tester.tap(find.text('2 weeks before'));
    await settle(tester);
    await tester.tap(
      find.descendant(of: find.widgetWithText(ListTile, sample.vehicles.last.name), matching: find.byType(Switch)),
    );
    await settle(tester);

    final prefs = (await SettingsRepository(db).load()).vehicleNotify;
    expect(prefs[civic.id]!.leadDays, 14);
    expect(prefs[sample.vehicles.last.id]!.enabled, isFalse);
    expect(find.text('2 weeks before'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
  });

  testWidgets('reminder history shows service gaps and switches to the interval chart', (tester) async {
    final router = await pumpApp(tester);
    final oil = sample.reminders.firstWhere((r) => r.name == 'Engine oil');
    router.go(Routes.reminder(oil.vehicleId, oil.id));
    await settle(tester);
    expect(find.textContaining(RegExp(r'^\+[\d,]+ km · ')), findsNWidgets(2), reason: 'gaps between three services');

    await tester.tap(find.text('History'));
    await settle(tester);
    await tester.tap(find.text('Intervals').last);
    await settle(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Required: every 7,500 km'), findsOneWidget);
    expect(find.text('Required: every 1 year'), findsOneWidget);
  });

  testWidgets('entry type tiles switch the form', (tester) async {
    final router = await pumpApp(tester, size: const Size(360, 800));
    router.go(Routes.newEntry(sample.vehicles.first.id));
    await settle(tester);
    expect(find.text('Volume'), findsOneWidget, reason: 'new entries start as refuels');
    await tester.tap(find.text('Odometer').first);
    await settle(tester);
    expect(find.text('Volume'), findsNothing);
    expect(tester.takeException(), isNull);
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
String _vehicleOf(BackupData s, String entryId) => s.entries.firstWhere((e) => e.id == entryId).vehicleId;

class _FakeUpdateService extends UpdateService {
  final events = StreamController<OtaEvent>.broadcast();
  var cancelled = false;

  @override
  Future<Stream<OtaEvent>> install(Release release) async => events.stream;

  /// Like the plugin, reports CANCELED right away — while the dialog is still animating out.
  @override
  Future<void> cancel() async {
    cancelled = true;
    events.add(OtaEvent(OtaStatus.CANCELED, 'Call was canceled using cancel()'));
  }
}
