import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logo_strokes.dart';

/// Background of the app icon and the native launch screen.
const splashColor = Color(0xFF064E66);

/// Writes out the wordmark, then fades away while the app slides in. The app is built only once the
/// word is written and [ready] has completed (its data loaded meanwhile), during a short hold, so the
/// writing never shares frames with the app's first, heaviest build. A tap skips the writing.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child, this.ready, this.onDone});

  final Widget child;

  /// Completes when the app has what it needs for its first screen; waited for at most [maxWait] past the writing.
  final Future<void>? ready;

  /// Called once the splash has gone.
  final VoidCallback? onDone;

  static const write = Duration(milliseconds: 700);

  /// Pause at each pen lift between strokes; none reads as one quick, continuous hand.
  static const penLift = Duration.zero;

  /// Still logo after the app is built, which absorbs its first frames.
  static const hold = Duration(milliseconds: 150);
  static const fade = Duration(milliseconds: 100);

  /// The app's slide into place, starting with the fade.
  static const slide = Duration(milliseconds: 300);

  /// Longest wait for [ready] after the writing (counted from the start); the app is shown then regardless.
  static const maxWait = Duration(seconds: 2);

  /// Time the pen takes over the whole word.
  static final writing = write + penLift * (logoStrokes.length - 1);

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with TickerProviderStateMixin {
  static final _logo = _Logo();

  late final _write = AnimationController(vsync: this, duration: SplashOverlay.writing)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _afterWriting();
    });
  // The hold, then the fade and slide.
  late final _reveal = AnimationController(vsync: this, duration: SplashOverlay.hold + SplashOverlay.slide)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _finish();
    });
  /// [SplashOverlay.ready], or the end of the longest wait for it.
  late final Future<void> _ready = (widget.ready ?? Future<void>.value())
      .timeout(SplashOverlay.writing + SplashOverlay.maxWait, onTimeout: () {})
      .catchError((_) {});
  bool _appShown = false;
  bool _done = false;
  bool _writingDone = false;

  @override
  void initState() {
    super.initState();
    _ready; // starts the clock on the wait
    _write.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_done && MediaQuery.disableAnimationsOf(context)) {
      _write.stop();
      _appShown = _done = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone?.call());
    }
  }

  @override
  void dispose() {
    _write.dispose();
    _reveal.dispose();
    super.dispose();
  }

  Future<void> _afterWriting() async {
    if (_writingDone || _done) return;
    _writingDone = true;
    await _ready;
    if (!mounted || _done) return;
    setState(() => _appShown = true);
    _reveal.forward();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    if (mounted) setState(() {});
    widget.onDone?.call();
  }

  /// Time into the fade and slide, past the hold; negative while holding.
  Duration get _revealed => (SplashOverlay.hold + SplashOverlay.slide) * _reveal.value - SplashOverlay.hold;

  /// Ends the writing at once; the rest follows as usual.
  void _skip() {
    if (_write.isAnimating) _write.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    // The same tree shape throughout, so the app is not rebuilt when the splash goes.
    return Stack(
      children: [
        // The app's background behind it while it slides, instead of the bare window.
        ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AnimatedBuilder(
            animation: _reveal,
            child: _appShown ? widget.child : const SizedBox.expand(),
            builder: (context, child) {
              // Fades in and slides a little from the right, as when a page opens.
              final t = (_revealed.inMicroseconds / SplashOverlay.slide.inMicroseconds).clamp(0.0, 1.0);
              final eased = _done ? 1.0 : Curves.easeOutCubic.transform(t);
              return Opacity(
                opacity: eased,
                child: FractionalTranslation(translation: Offset(0.1 * (1 - eased), 0), child: child),
              );
            },
          ),
        ),
        if (!_done)
          Positioned.fill(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light,
              child: GestureDetector(
                onTap: _skip,
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _reveal,
                  builder: (context, child) {
                    final faded = _revealed.inMicroseconds / SplashOverlay.fade.inMicroseconds;
                    return Opacity(opacity: (1 - faded).clamp(0, 1), child: child);
                  },
                  child: ColoredBox(
                    color: splashColor,
                    child: Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.72,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: AspectRatio(
                            aspectRatio: _logo.bounds.width / _logo.bounds.height,
                            // Repaints alone, every frame of the writing.
                            child: RepaintBoundary(child: CustomPaint(painter: _LogoPainter(_logo, _write))),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The wordmark outline and the pen strokes through it, in logo units.
class _Logo {
  _Logo() {
    final ops = logoGlyph;
    var i = 0;
    while (i < ops.length) {
      switch (ops[i++].toInt()) {
        case 0:
          glyph.moveTo(ops[i++], ops[i++]);
        case 1:
          glyph.lineTo(ops[i++], ops[i++]);
        case 2:
          glyph.cubicTo(ops[i++], ops[i++], ops[i++], ops[i++], ops[i++], ops[i++]);
        default:
          glyph.close();
      }
    }
    bounds = glyph.getBounds().inflate(2);
    for (final points in logoStrokes) {
      // Smooth through the traced points: quadratic segments between their midpoints.
      final path = Path()..moveTo(points[0], points[1]);
      for (var j = 2; j + 3 < points.length; j += 2) {
        path.quadraticBezierTo(
          points[j],
          points[j + 1],
          (points[j] + points[j + 2]) / 2,
          (points[j + 1] + points[j + 3]) / 2,
        );
      }
      path.lineTo(points[points.length - 2], points[points.length - 1]);
      final metric = path.computeMetrics().single;
      paths.add(path);
      strokes.add(metric);
      length += metric.length;
    }
  }

  final glyph = Path();
  late final Rect bounds;
  final paths = <Path>[];
  final strokes = <PathMetric>[];
  double length = 0;
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.logo, this.progress) : super(repaint: progress);

  final _Logo logo;

  /// 0 to 1 over [SplashOverlay.writing].
  final Animation<double> progress;

  /// Pen width in logo units: a little wider than the strokes so their rounded ends are covered.
  static const _pen = 11.0;

  static final _fill = Paint()..color = Colors.white;
  static final _ink = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = _pen
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / logo.bounds.width;
    canvas
      ..scale(scale)
      ..translate(-logo.bounds.left, -logo.bounds.top);
    if (progress.value >= 1) {
      canvas.drawPath(logo.glyph, _fill);
      return;
    }
    // The pen's ink, kept to the outline. It moves at a steady speed and pauses between strokes;
    // finished strokes are drawn whole, and only the one being written is cut to length.
    canvas.clipPath(logo.glyph);
    final time = SplashOverlay.writing * progress.value;
    var start = Duration.zero;
    for (var i = 0; i < logo.strokes.length; i++) {
      final stroke = logo.strokes[i];
      final duration = SplashOverlay.write * (stroke.length / logo.length);
      final local = (time - start).inMicroseconds / duration.inMicroseconds;
      if (local <= 0) break;
      canvas.drawPath(local >= 1 ? logo.paths[i] : stroke.extractPath(0, stroke.length * local), _ink);
      start += duration + SplashOverlay.penLift;
    }
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.progress != progress;
}
