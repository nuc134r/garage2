import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/widgets/keyboard_restorer.dart';

void main() {
  Future<void> openField(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: KeyboardRestorer(enabled: true, child: Scaffold(body: TextField(autofocus: true))),
      ),
    );
    await tester.pump();
  }

  /// Leaves the app and comes back, as switching to another app does.
  Future<void> switchAway(WidgetTester tester, {required bool keyboardOpen}) async {
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardOpen ? 300 : 0);
    for (final state in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    tester.view.viewInsets = FakeViewPadding.zero; // the system closed the keyboard
    tester.testTextInput.log.clear();
    for (final state in [AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump(KeyboardRestorer.delay);
  }

  bool keyboardRequested(WidgetTester tester) =>
      tester.testTextInput.log.any((call) => call.method == 'TextInput.show');

  testWidgets('reopens the keyboard when coming back to a focused field', (tester) async {
    addTearDown(tester.view.reset);
    await openField(tester);
    await switchAway(tester, keyboardOpen: true);
    expect(keyboardRequested(tester), isTrue);
  });

  testWidgets('leaves it closed if it was closed when leaving', (tester) async {
    addTearDown(tester.view.reset);
    await openField(tester);
    await switchAway(tester, keyboardOpen: false);
    expect(keyboardRequested(tester), isFalse);
  });

  testWidgets('leaves it closed once the field has lost focus', (tester) async {
    addTearDown(tester.view.reset);
    await openField(tester);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await switchAway(tester, keyboardOpen: true);
    expect(keyboardRequested(tester), isFalse);
  });
}
