// Renders the README screenshots into docs/screenshots: `bash tool/screenshots.sh`.
// Skipped in a plain `flutter test`. The sample data and the clock are fixed, so the output only changes with the UI.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/app.dart';
import 'package:garage/app/router.dart';
import 'package:garage/core/db/database.dart';
import 'package:garage/features/backup/data/backup_service.dart';
import 'package:garage/features/backup/domain/backup_data.dart';
import 'package:garage/features/backup/domain/sample_data.dart';
import 'package:garage/features/settings/data/settings_repository.dart';
import 'package:garage/features/updates/data/update_service.dart';

import 'helpers.dart';

const _enabled = bool.fromEnvironment('SCREENSHOTS');
const _outDir = 'docs/screenshots';
final _now = DateTime(2026, 10, 16, 10, 24);
const _fontDir = '/bin/cache/artifacts/material_fonts';

const _phone = Size(412, 892);
const _desktop = Size(1280, 800);

void main() {
  setUpAll(() async {
    if (!_enabled) return;
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '/opt/flutter';
    Future<ByteData> font(String name) async =>
        ByteData.sublistView(await File('$flutterRoot$_fontDir/$name').readAsBytes());
    await (FontLoader('Roboto')
          ..addFont(font('Roboto-Regular.ttf'))
          ..addFont(font('Roboto-Medium.ttf'))
          ..addFont(font('Roboto-Bold.ttf')))
        .load();
    await (FontLoader('MaterialIcons')..addFont(font('MaterialIcons-Regular.otf'))).load();
  });

  final shots =
      <
        String,
        ({Size size, ThemeMode theme, String Function(BackupData) path, Future<void> Function(WidgetTester)? act})
      >{
        'home': (size: _phone, theme: ThemeMode.dark, path: (s) => Routes.home(s.vehicles.first.id), act: null),
        'stats': (size: _phone, theme: ThemeMode.dark, path: (s) => Routes.stats(s.vehicles.first.id), act: null),
        'reminder': (
          size: _phone,
          theme: ThemeMode.dark,
          path: (s) => Routes.reminder(s.vehicles.first.id, s.reminders.first.id),
          act: null,
        ),
        'entry': (
          size: _phone,
          theme: ThemeMode.light,
          path: (s) => Routes.entry(s.vehicles.first.id, _lastRefuel(s).id),
          act: null,
        ),
        'new_entry': (
          size: _phone,
          theme: ThemeMode.light,
          path: (s) => Routes.newEntry(s.vehicles.first.id),
          act: null,
        ),
        'vehicle': (size: _phone, theme: ThemeMode.light, path: (s) => Routes.editVehicle(s.vehicles.first.id), act: null),
        'desktop': (size: _desktop, theme: ThemeMode.dark, path: (s) => Routes.home(s.vehicles.first.id), act: null),
      };

  for (final MapEntry(key: name, value: shot) in shots.entries) {
    testWidgets('screenshot $name', skip: !_enabled, (tester) async {
      // Real shadows instead of the test default's solid outlines.
      debugDisableShadows = false;
      try {
        await withClock(Clock.fixed(_now), () async {
          final db = memoryDb();
          addTearDown(db.close);
          final sample = buildSampleData(now: _now);
          await BackupService(db).import(sample, ImportStrategy.merge);
          await SettingsRepository(db).set(SettingKeys.themeMode, shot.theme.name);
          await SettingsRepository(db).set(SettingKeys.lastVehicleId, sample.vehicles.first.id);

          final phone = shot.size == _phone;
          final dpr = phone ? 2.5 : 1.5;
          tester.view.physicalSize = shot.size * dpr;
          tester.view.devicePixelRatio = dpr;
          if (phone) tester.view.padding = FakeViewPadding(top: _statusBar * dpr, bottom: 16 * dpr);
          addTearDown(tester.view.reset);

          final container = ProviderContainer(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              appVersionProvider.overrideWith((ref) async => '2.6.0'),
              availableUpdateProvider.overrideWith((ref) async => null),
            ],
          );
          addTearDown(container.dispose);
          final key = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: key,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: _Frame(
                  phone: phone,
                  dark: shot.theme == ThemeMode.dark,
                  child: UncontrolledProviderScope(container: container, child: const GarageApp()),
                ),
              ),
            ),
          );
          await settle(tester);
          container.read(routerProvider).go(shot.path(sample));
          await settle(tester);
          await shot.act?.call(tester);
          await settle(tester);

          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: dpr);
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            await Directory(_outDir).create(recursive: true);
            await File('$_outDir/$name.png').writeAsBytes(bytes!.buffer.asUint8List());
          });
        });
      } finally {
        debugDisableShadows = true;
      }
    });
  }
}

Entry _lastRefuel(BackupData s) =>
    (s.entries.where((e) => e.vehicleId == s.vehicles.first.id && e.volume != null).toList()
          ..sort((a, b) => b.date.compareTo(a.date)))
        .first;

const _statusBar = 32.0;

/// Rounded corners and an Android-like status bar for phone shots; a plain window for desktop.
class _Frame extends StatelessWidget {
  const _Frame({required this.phone, required this.dark, required this.child});

  final bool phone;
  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!phone) return ClipRRect(borderRadius: BorderRadius.circular(12), child: child);
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _statusBar,
            child: Builder(
              builder: (context) {
                final color = dark ? Colors.white : Colors.black87;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        '10:24',
                        style: TextStyle(fontFamily: 'Roboto', fontSize: 14, fontWeight: FontWeight.w500, color: color),
                      ),
                      const Spacer(),
                      Icon(Icons.signal_cellular_alt, size: 16, color: color),
                      const SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: color),
                      const SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 16, color: color),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
