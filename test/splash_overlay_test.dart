import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/widgets/logo_strokes.dart';
import 'package:garage/core/widgets/splash_overlay.dart';

void main() {
  Widget app() => const MaterialApp(home: SplashOverlay(child: Text('app')));
  Finder splash() => find.byWidgetPredicate((w) => w is ColoredBox && w.color == splashColor);

  testWidgets('writes the logo over the app, then goes away', (tester) async {
    await tester.pumpWidget(app());
    expect(find.text('app'), findsOneWidget, reason: 'the app builds underneath');
    expect(splash(), findsOneWidget);
    await tester.pump(SplashOverlay.write ~/ 2);
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

  testWidgets('the pen covers the whole logo, so the finished word does not jump', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: const MaterialApp(home: SplashOverlay(child: SizedBox())),
      ),
    );
    Future<List<int>> pixels() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      return (await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 4);
        return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
      }))!;
    }

    final writing = SplashOverlay.write + SplashOverlay.penLift * (logoStrokes.length - 1);
    // Every stroke drawn to its end, but still through the pen.
    await tester.pump(writing - const Duration(microseconds: 1));
    final written = await pixels();
    await tester.pump(const Duration(milliseconds: 20));
    final finished = await pixels();
    var differ = 0;
    for (var i = 0; i < written.length; i += 4) {
      if ((written[i] - finished[i]).abs() > 96) differ++;
    }
    expect(differ, lessThan(20));
    await tester.pumpAndSettle();
  });
}
