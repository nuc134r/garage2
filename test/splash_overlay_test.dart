import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/widgets/splash_overlay.dart';

void main() {
  Widget app() => const MaterialApp(home: SplashOverlay(child: Text('app')));
  Finder splash() => find.byWidgetPredicate((w) => w is ColoredBox && w.color == splashColor);

  testWidgets('writes the logo over the app, then goes away', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('app'), findsOneWidget, reason: 'the app builds underneath');
    expect(splash(), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(splash(), findsOneWidget);
    await tester.pumpAndSettle();
    expect(splash(), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('a tap skips to the fade', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(splash());
    await tester.pump();
    await tester.pump(SplashOverlay.fade + const Duration(milliseconds: 20));
    await tester.pump();
    expect(splash(), findsNothing);
  });

  testWidgets('skipped when animations are off', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: SplashOverlay(child: Text('app'))),
      ),
    );
    expect(splash(), findsNothing);
  });
}
