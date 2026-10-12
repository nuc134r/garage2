import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, scrolledUnderElevation: 2),
    scrollbarTheme: ScrollbarThemeData(radius: const Radius.circular(8), thumbColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: .2))),
  );
}
