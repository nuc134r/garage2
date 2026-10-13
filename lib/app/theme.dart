import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;

ThemeData buildTheme(Brightness brightness, {bool predictiveBack = false}) {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    // Predictive back on Android is a setting (off by default; the manifest enables the callback):
    // the page follows the back swipe and the previous one is revealed underneath.
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android:
            predictiveBack ? const PredictiveBackPageTransitionsBuilder() : const FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: const FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: const FadeForwardsPageTransitionsBuilder(),
      },
    ),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, scrolledUnderElevation: 2),
    scrollbarTheme: ScrollbarThemeData(radius: const Radius.circular(8), thumbColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: .2))),
  );
}
