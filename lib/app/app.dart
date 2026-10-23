import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/splash_overlay.dart';
import '../features/reminders/application/notification_sync.dart';
import '../features/settings/data/settings_repository.dart';
import '../l10n/l10n.dart';
import 'router.dart';
import 'theme.dart';

class GarageApp extends ConsumerWidget {
  const GarageApp({super.key, this.splash = false});

  /// Writes out the logo over the app as it starts.
  final bool splash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).value ?? const AppSettingsState({});
    ref.watch(notificationSyncProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light, predictiveBack: settings.predictiveBack),
      darkTheme: buildTheme(Brightness.dark, predictiveBack: settings.predictiveBack),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
      builder: splash ? (context, child) => SplashOverlay(child: child!) : null,
    );
  }
}
