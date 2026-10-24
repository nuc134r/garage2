import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/widgets/splash_overlay.dart';

void main() {
  Widget app() => const MaterialApp(home: SplashOverlay(child: Text('app')));
  Finder splash() => find.byWidgetPredicate((w) => w is ColoredBox && w.color == splashColor);

  testWidgets('writes the logo first, then builds the app and goes away', (tester) async {
    await tester.pumpWidget(app());
    expect(splash(), findsOneWidget);
    expect(find.text('app'), findsNothing, reason: 'the app waits for the writing');
    await tester.pump(SplashOverlay.writing ~/ 2);
    expect(find.text('app'), findsNothing);
    await tester.pump(SplashOverlay.writing);
    await tester.pump();
    expect(find.text('app'), findsOneWidget, reason: 'built behind the still logo');
    expect(splash(), findsOneWidget);
    await tester.pumpAndSettle();
    expect(splash(), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });

  testWidgets('waits for the app to be ready after the writing', (tester) async {
    final ready = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: SplashOverlay(ready: ready.future, child: const Text('app')),
      ),
    );
    await tester.pump(SplashOverlay.writing + const Duration(milliseconds: 500));
    expect(find.text('app'), findsNothing);
    ready.complete();
    await tester.pumpAndSettle();
    expect(find.text('app'), findsOneWidget);
    expect(splash(), findsNothing);
  });

  testWidgets('does not wait forever for the app', (tester) async {
    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashOverlay(ready: Completer<void>().future, onDone: () => done = true, child: const Text('app')),
      ),
    );
    await tester.pump(); // the writing starts on the first frame
    await tester.pump(SplashOverlay.writing);
    await tester.pump(SplashOverlay.maxWait);
    await tester.pumpAndSettle();
    expect(find.text('app'), findsOneWidget);
    expect(done, isTrue);
  });

  testWidgets('a tap skips the writing', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(splash());
    await tester.pump();
    expect(find.text('app'), findsOneWidget);
    await tester.pump(SplashOverlay.hold);
    await tester.pump(SplashOverlay.slide + const Duration(milliseconds: 20));
    await tester.pump();
    expect(splash(), findsNothing);
  });

  testWidgets('the app is created once and keeps its state when the splash goes', (tester) async {
    var created = 0;
    await tester.pumpWidget(MaterialApp(home: SplashOverlay(child: _Counted(() => created++))));
    await tester.pumpAndSettle();
    expect(splash(), findsNothing);
    expect(created, 1);
  });

  testWidgets('the app slides in as the splash fades', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(splash());
    await tester.pump();
    await tester.pump(SplashOverlay.hold);
    await tester.pump(SplashOverlay.fade);
    final x = tester.getTopLeft(find.text('app')).dx;
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('app')).dx, lessThan(x));
  });

  testWidgets('skipped when animations are off', (tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(home: SplashOverlay(child: Text('app'))),
      ),
    );
    expect(splash(), findsNothing);
    expect(find.text('app'), findsOneWidget);
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

    final writing = SplashOverlay.writing;
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

class _Counted extends StatefulWidget {
  const _Counted(this.onCreate);

  final VoidCallback onCreate;

  @override
  State<_Counted> createState() => _CountedState();
}

class _CountedState extends State<_Counted> {
  @override
  void initState() {
    super.initState();
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) => const Text('app');
}
