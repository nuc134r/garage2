import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logo_strokes.dart';

/// Background of the app icon and the native launch screen.
const splashColor = Color(0xFF064E66);

/// Writes out the wordmark over the starting app, as if by hand, then fades away while the app
/// slides in. The app builds underneath meanwhile. A tap skips to the end.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  static const write = Duration(milliseconds: 700);
  /// Pause at each pen lift between strokes; none reads as one quick, continuous hand.
  static const penLift = Duration.zero;
  static const hold = Duration(milliseconds: 150);
  static const fade = Duration(milliseconds: 100);

  /// The app's slide into place, starting with the fade.
  static const slide = Duration(milliseconds: 300);

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with SingleTickerProviderStateMixin {
  static final _logo = _Logo();
  static final _writing = SplashOverlay.write + SplashOverlay.penLift * (logoStrokes.length - 1);
  static final _revealStart = _writing + SplashOverlay.hold;
  static final _total = _revealStart + SplashOverlay.slide;

  late final _controller = AnimationController(vsync: this, duration: _total)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _done = true);
    })
    ..forward();
  bool _done = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_done && MediaQuery.disableAnimationsOf(context)) _done = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() {
    final revealStart = _revealStart.inMicroseconds / _total.inMicroseconds;
    if (_controller.value < revealStart) _controller.forward(from: revealStart);
  }

  /// Time since the reveal began, from 0 (splash still up) to the end.
  Duration get _revealed => Duration(microseconds: (_controller.value * _total.inMicroseconds).round()) - _revealStart;

  @override
  Widget build(BuildContext context) {
    // The same tree shape throughout, so the app is not rebuilt when the splash goes.
    return Stack(
      children: [
        // The app's background behind it while it slides, instead of the bare window.
        ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: AnimatedBuilder(
            animation: _controller,
            child: widget.child,
            builder: (context, child) {
              // Fades in and slides a little from the right, as when a page opens.
              final t = _done ? 1.0 : (_revealed.inMicroseconds / SplashOverlay.slide.inMicroseconds).clamp(0.0, 1.0);
              final eased = Curves.easeOutCubic.transform(t);
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
                  animation: _controller,
                  builder: (context, _) {
                    final t = _controller.value * _total.inMicroseconds;
                    final opacity = 1 - _revealed.inMicroseconds / SplashOverlay.fade.inMicroseconds;
                    return Opacity(
                      opacity: opacity.clamp(0, 1),
                      child: ColoredBox(
                        color: splashColor,
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.72,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 360),
                              child: AspectRatio(
                                aspectRatio: _logo.bounds.width / _logo.bounds.height,
                                child: CustomPaint(painter: _LogoPainter(_logo, Duration(microseconds: t.round()))),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
      strokes.add(metric);
      length += metric.length;
    }
  }

  final glyph = Path();
  late final Rect bounds;
  final strokes = <PathMetric>[];
  double length = 0;
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.logo, this.time);

  final _Logo logo;
  final Duration time;

  /// Pen width in logo units: a little wider than the strokes so their rounded ends are covered.
  static const _pen = 11.0;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / logo.bounds.width;
    canvas
      ..scale(scale)
      ..translate(-logo.bounds.left, -logo.bounds.top);
    final ink = Paint()..color = Colors.white;

    // Pen moves at a steady speed and pauses between strokes.
    var start = Duration.zero;
    final drawn = Path();
    var finished = true;
    for (final stroke in logo.strokes) {
      final duration = SplashOverlay.write * (stroke.length / logo.length);
      final local = ((time - start).inMicroseconds / duration.inMicroseconds).clamp(0.0, 1.0);
      if (local > 0) drawn.addPath(stroke.extractPath(0, stroke.length * local), Offset.zero);
      if (local < 1) finished = false;
      start += duration + SplashOverlay.penLift;
    }
    if (finished) {
      canvas.drawPath(logo.glyph, ink);
      return;
    }
    // The pen's ink, kept to the outline.
    canvas
      ..clipPath(logo.glyph)
      ..drawPath(
        drawn,
        ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = _pen
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.time != time;
}
