import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/app/theme.dart';

void main() {
  test('predictive back is off unless the setting turns it on', () {
    PageTransitionsBuilder android(ThemeData t) => t.pageTransitionsTheme.builders[TargetPlatform.android]!;
    expect(android(buildTheme(Brightness.dark)), isA<FadeForwardsPageTransitionsBuilder>());
    expect(android(buildTheme(Brightness.dark, predictiveBack: true)), isA<PredictiveBackPageTransitionsBuilder>());
  });
}
