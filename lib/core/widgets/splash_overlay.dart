import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logo_strokes.dart';

/// Background of the app icon and the native launch screen.
const splashColor = Color(0xFF064E66);

/// Writes out the wordmark over the starting app, as if by hand, then fades away.
/// The app builds underneath meanwhile. A tap skips it.
class SplashOverlay extends StatefulWidget {
  const SplashOverlay({super.key, required this.child});

  final Widget child;

  static const write = Duration(milliseconds: 700);
  static const penLift = Duration(milliseconds: 25);
  static const hold = Duration(milliseconds: 150);
  static const fade = Duration(milliseconds: 100);

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay> with SingleTickerProviderStateMixin {
  static final _logo = _Logo();
  static final _writing = SplashOverlay.write + SplashOverlay.penLift * (logoStrokes.length - 1);
  static final _total = _writing + SplashOverlay.hold + SplashOverlay.fade;

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
    final fadeStart = 1 - SplashOverlay.fade.inMicroseconds / _total.inMicroseconds;
    if (_controller.value < fadeStart) _controller.forward(from: fadeStart);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return widget.child;
    return Stack(
      children: [
        widget.child,
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
                  final fadeStart = (_total - SplashOverlay.fade).inMicroseconds;
                  final opacity = t <= fadeStart ? 1.0 : 1 - (t - fadeStart) / SplashOverlay.fade.inMicroseconds;
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
