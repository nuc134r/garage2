import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/widgets/splash_overlay.dart';
import '../features/home/application/home_warm_up.dart';
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
      builder: splash ? (context, child) => _Splash(child: child!) : null,
    );
  }
}

/// The splash, with the launch screen's data loading while it writes.
class _Splash extends ConsumerStatefulWidget {
  const _Splash({required this.child});

  final Widget child;

  @override
  ConsumerState<_Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<_Splash> {
  // Keeps the warmed-up data alive until the home screen watches it itself.
  ProviderSubscription<AsyncValue<void>>? _warmUp;
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _warmUp = ref.listenManual(homeWarmUpProvider, (_, _) {});
    _ready = ref.read(homeWarmUpProvider.future);
  }

  @override
  void dispose() {
    _warmUp?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SplashOverlay(
        ready: _ready,
        onDone: () {
          _warmUp?.close();
          _warmUp = null;
        },
        child: widget.child,
      );
}
