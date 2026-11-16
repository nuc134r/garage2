import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Reopens the keyboard after the user switches away and back, as long as it was open when they left
/// and the text field still has focus. Android closes it with the window, and the focused field does not
/// ask for it again, so looking something up in another app meant tapping the field once more.
class KeyboardRestorer extends StatefulWidget {
  const KeyboardRestorer({super.key, required this.child, this.enabled});

  final Widget child;

  /// Defaults to Android apps (not the web).
  final bool? enabled;

  /// Wait after resuming, for the window to take focus again before the keyboard is asked for.
  static const delay = Duration(milliseconds: 150);

  @override
  State<KeyboardRestorer> createState() => _KeyboardRestorerState();
}

class _KeyboardRestorerState extends State<KeyboardRestorer> with WidgetsBindingObserver {
  bool _keyboardWasOpen = false;
  Timer? _timer;

  bool get _enabled => widget.enabled ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled) return;
    switch (state) {
      case AppLifecycleState.inactive:
        // The first step out, while the keyboard is still on screen; later steps keep what it saw.
        if (!_keyboardWasOpen) _keyboardWasOpen = _keyboardOpen;
      case AppLifecycleState.resumed:
        final reopen = _keyboardWasOpen;
        _keyboardWasOpen = false;
        if (reopen) {
          _timer?.cancel();
          _timer = Timer(KeyboardRestorer.delay, _reopen);
        }
      case AppLifecycleState.paused || AppLifecycleState.hidden || AppLifecycleState.detached:
        break;
    }
  }

  bool get _keyboardOpen {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    return views.isNotEmpty && views.first.viewInsets.bottom > 0;
  }

  void _reopen() {
    if (!mounted) return;
    final field = FocusManager.instance.primaryFocus?.context?.findAncestorStateOfType<EditableTextState>();
    field?.requestKeyboard();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
