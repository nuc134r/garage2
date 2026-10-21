import 'dart:math';

import 'package:flutter/material.dart';

import '../model/enums.dart';

/// Design language of a drawing: rounded 2000s shapes, or the 2010s' high beltline, sloping roof and slim
/// lamps.
enum _Era { noughties, tens }

/// Each body type is drawn in the generation that suits it best.
_Era _eraOf(BodyType body) => body == BodyType.hatchback ? _Era.noughties : _Era.tens;

/// A rounded corner of a car outline: a point in metres (x from the rear bumper, y up from the ground)
/// and how much it is rounded off, also in metres.
typedef _Corner = (double x, double y, double round);

/// Side view of a typical modern car of one body type, built from real dimensions so every drawing is at
/// the same scale.
class _Spec {
  const _Spec({
    required this.wheels,
    required this.wheelRadius,
    required this.sill,
    required this.outline,
    required this.glass,
    this.pillars = const [],
    this.roofRails = false,
    this.cladding = false,
  });

  /// X of the rear and front wheel centres.
  final (double, double) wheels;
  final double wheelRadius;

  /// Height of the body's lower edge between the wheels.
  final double sill;

  /// Body outline from the lower rear corner over the roof to the lower front corner. The last three
  /// corners are the end of the hood, the front face and the lower front corner.
  final List<_Corner> outline;

  /// Side windows (daylight opening), split by [pillars] (x of their centres).
  final List<_Corner> glass;
  final List<double> pillars;
  final bool roofRails;

  /// Unpainted plastic around the arches and along the bottom.
  final bool cladding;

  double get length => outline.map((c) => c.$1).reduce(max);
  double get hoodY => outline[outline.length - 3].$2;
}

// Proportions follow common cars: Camry, Golf (2000s), Passat estate, Civic coupe, RAV4/Tiguan, Hilux
// (with a shorter bed) and Carnival.
const _specs = <BodyType, _Spec>{
  // ------------------------------------------------------------------------------------------------ sedan
  BodyType.sedan: _Spec(
    wheels: (1.10, 3.90),
    wheelRadius: .345,
    sill: .28,
    outline: [
      (.10, .28, .08),
      (0, .58, .14),
      (.04, .96, .10),
      (.70, 1.02, .25),
      (1.45, 1.36, .45),
      (2.58, 1.41, .45),
      (3.52, .99, .08),
      (4.70, .82, .30),
      (4.85, .56, .18),
      (4.77, .28, .08),
    ],
    glass: [(.94, 1.03, .02), (1.52, 1.31, .22), (2.55, 1.36, .30), (3.43, 1.00, .03), (1.36, .98, .05)],
    pillars: [2.20],
  ),
  // -------------------------------------------------------------------------------------------- hatchback
  BodyType.hatchback: _Spec(
    wheels: (.74, 3.32),
    wheelRadius: .315,
    sill: .26,
    outline: [
      (.08, .26, .07),
      (0, .56, .10),
      (.04, .98, .10),
      (.16, 1.36, .20),
      (.60, 1.43, .30),
      (2.15, 1.44, .55),
      (2.98, .96, .10),
      (4.06, .82, .28),
      (4.20, .54, .14),
      (4.12, .26, .07),
    ],
    glass: [(.62, .96, .04), (.70, 1.36, .15), (2.12, 1.38, .32), (2.88, .96, .04)],
    pillars: [1.75],
  ),
  // ------------------------------------------------------------------------------------------------ wagon
  BodyType.wagon: _Spec(
    wheels: (1.10, 3.90),
    wheelRadius: .345,
    sill: .28,
    outline: [
      (.08, .28, .07),
      (0, .60, .12),
      (.06, 1.08, .12),
      (.32, 1.36, .30),
      (1.40, 1.42, .45),
      (2.55, 1.43, .45),
      (3.42, 1.00, .08),
      (4.68, .84, .30),
      (4.85, .58, .16),
      (4.77, .28, .07),
    ],
    glass: [(.40, 1.04, .02), (.55, 1.32, .20), (2.50, 1.38, .30), (3.35, 1.01, .03), (1.25, .99, .05)],
    pillars: [1.12, 2.25],
    roofRails: true,
  ),
  // ------------------------------------------------------------------------------------------------ coupe
  BodyType.coupe: _Spec(
    wheels: (1.05, 3.85),
    wheelRadius: .35,
    sill: .26,
    outline: [
      (.10, .26, .07),
      (0, .56, .14),
      (.04, .94, .10),
      (.40, .98, .25),
      (1.60, 1.26, .70),
      (2.35, 1.32, .45),
      (3.30, .96, .08),
      (4.55, .80, .30),
      (4.70, .54, .18),
      (4.62, .26, .07),
    ],
    glass: [(.82, .99, .02), (1.70, 1.25, .35), (2.32, 1.28, .30), (3.22, .96, .03), (1.25, .95, .05)],
  ),
  // -------------------------------------------------------------------------------------------------- SUV
  BodyType.suv: _Spec(
    wheels: (.99, 3.68),
    wheelRadius: .37,
    sill: .40,
    outline: [
      (.08, .40, .08),
      (0, .76, .14),
      (.06, 1.18, .12),
      (.28, 1.54, .30),
      (1.30, 1.62, .45),
      (2.50, 1.63, .45),
      (3.30, 1.16, .10),
      (4.45, 1.00, .35),
      (4.60, .70, .18),
      (4.52, .40, .08),
    ],
    glass: [(.40, 1.16, .02), (.58, 1.48, .20), (2.46, 1.56, .30), (3.20, 1.16, .03), (1.25, 1.12, .05)],
    pillars: [1.10, 2.18],
    roofRails: true,
    cladding: true,
  ),
  // ----------------------------------------------------------------------------------------------- pickup
  BodyType.pickup: _Spec(
    wheels: (1.03, 4.11),
    wheelRadius: .38,
    sill: .46,
    outline: [
      (.06, .46, .08),
      (0, 1.10, .05),
      (1.50, 1.10, .03),
      (1.56, 1.74, .15),
      (2.70, 1.78, .45),
      (3.42, 1.22, .10),
      (4.82, 1.08, .35),
      (5.03, .76, .18),
      (4.95, .46, .10),
    ],
    glass: [(1.68, 1.20, .04), (1.72, 1.62, .10), (2.66, 1.68, .30), (3.32, 1.21, .04)],
    pillars: [2.40],
    cladding: true,
  ),
  // -------------------------------------------------------------------------------------------------- van
  BodyType.van: _Spec(
    wheels: (1.0, 4.06),
    wheelRadius: .35,
    sill: .36,
    outline: [
      (.08, .36, .08),
      (0, .70, .14),
      (.05, 1.26, .15),
      (.30, 1.64, .35),
      (2.80, 1.70, .60),
      (3.95, 1.18, .15),
      (4.84, 1.00, .30),
      (5.0, .70, .18),
      (4.92, .36, .08),
    ],
    glass: [(.32, 1.14, .02), (.45, 1.58, .20), (2.75, 1.64, .35), (3.80, 1.16, .03), (1.10, 1.12, .05)],
    pillars: [1.20, 2.10, 3.05],
  ),
};

/// Drawing units per metre: the longest car (pickup, 5.3 m) fills the 100-unit width with a margin.
const _scale = 100 / 5.5;

/// Ground line in the 100×44 box.
const _ground = 41.0;

typedef _At = Offset Function(double x, double y);

/// Position of the car in the box: centred horizontally by its length.
_At _mapper(_Spec s) {
  final left = (100 - s.length * _scale) / 2;
  return (x, y) => Offset(left + x * _scale, _ground - y * _scale);
}

/// Adds a polyline with rounded corners: each corner is cut [round] metres back along its edges and joined
/// with a curve through the corner. [before] and [after] are the neighbours of the first and last corner;
/// without them the polyline is closed.
void _rounded(Path path, List<_Corner> corners, _At at, {Offset? before, Offset? after}) {
  final points = [for (final c in corners) at(c.$1, c.$2)];
  for (var i = 0; i < corners.length; i++) {
    final v = points[i];
    final prev = i > 0 ? points[i - 1] : (before ?? points.last);
    final next = i < corners.length - 1 ? points[i + 1] : (after ?? points.first);
    final toPrev = prev - v, toNext = next - v;
    final r = min(corners[i].$3 * _scale, min(toPrev.distance, toNext.distance) / 2);
    final a = v + toPrev / toPrev.distance * r;
    final b = v + toNext / toNext.distance * r;
    if (i == 0 && before == null) {
      path.moveTo(a.dx, a.dy);
    } else {
      path.lineTo(a.dx, a.dy);
    }
    path.quadraticBezierTo(v.dx, v.dy, b.dx, b.dy);
  }
}

Path _polygon(List<Offset> points) => Path()..addPolygon(points, true);

final _bodyCache = <_Spec, Path>{};
final _glassCache = <_Spec, Path>{};

/// Body outline with arches cut around the wheels.
Path _body(_Spec s) => _bodyCache.putIfAbsent(s, () {
  final at = _mapper(s);
  final arch = s.wheelRadius * 1.14;
  final h = sqrt(max(0, arch * arch - pow(s.sill - s.wheelRadius, 2)));
  final (rear, front) = s.wheels;
  final path = Path();
  final start = at(rear - h, s.sill);
  path.moveTo(start.dx, start.dy);
  _rounded(path, s.outline, at, before: start, after: at(front + h, s.sill));
  for (final x in [front, rear]) {
    final right = at(x + h, s.sill), left = at(x - h, s.sill);
    path.lineTo(right.dx, right.dy);
    path.arcToPoint(left, radius: Radius.circular(arch * _scale), largeArc: s.sill < s.wheelRadius, clockwise: false);
  }
  return path..close();
});

Path _glass(_Spec s) => _glassCache.putIfAbsent(s, () {
  final path = Path();
  _rounded(path, s.glass, _mapper(s));
  return path..close();
});

/// A small side view of a car in the vehicle's colour.
class CarPainter extends CustomPainter {
  const CarPainter({required this.body, required this.color, required this.brightness});

  final BodyType body;
  final Color color;
  final Brightness brightness;

  /// Width / height of the drawing.
  static const aspectRatio = 100 / 44;

  @override
  void paint(Canvas canvas, Size size) {
    final era = _eraOf(body);
    final s = _specs[body]!;
    final at = _mapper(s);
    final dark = brightness == Brightness.dark;
    final scale = size.width / 100;
    canvas.save();
    canvas.translate(0, (size.height - 44 * scale) / 2);
    canvas.scale(scale);

    final hsl = HSLColor.fromColor(color);
    final l = hsl.lightness;
    Color shade(double d) => hsl.withLightness((l + d).clamp(0.0, 1.0)).toColor();
    // Dark paint gets a lighter edge so a black car stays visible on a dark background.
    final edge = l < .3 ? shade(.22) : shade(-.2);
    final length = s.length, hood = s.hoodY;

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, _ground + .4), width: length * _scale * .96, height: 2.2),
      Paint()
        ..color = Colors.black.withValues(alpha: dark ? .55 : .18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, .9),
    );

    final bodyPath = _body(s);
    final bounds = bodyPath.getBounds();
    _wheels(canvas, s, at);

    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [shade(.07), color, shade(-.06)],
          stops: const [0, .55, 1],
        ).createShader(bounds),
    );

    final glass = _glass(s);
    final gb = glass.getBounds();

    canvas.save();
    canvas.clipPath(bodyPath);
    // Lower body: rocker panel, or unpainted plastic on crossovers and trucks.
    final low = at(0, s.sill + (s.cladding ? .2 : .13)).dy;
    canvas.drawRect(
      Rect.fromLTRB(0, low, 100, 44),
      Paint()..color = s.cladding ? const Color(0xFF2B2F33) : Colors.black.withValues(alpha: .15),
    );
    if (s.cladding) {
      for (final x in [s.wheels.$1, s.wheels.$2]) {
        canvas.drawCircle(
          at(x, s.wheelRadius),
          s.wheelRadius * 1.14 * _scale + .9,
          Paint()
            ..color = const Color(0xFF2B2F33)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
      }
    }
    final light = Paint()
      ..color = (l > .7 ? Colors.black : Colors.white).withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .45
      ..strokeCap = StrokeCap.round;
    final crease = Paint()
      ..color = edge.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = .32
      ..strokeCap = StrokeCap.round;
    switch (era) {
      case _Era.noughties:
        // A straight shoulder line under the windows.
        canvas.drawLine(Offset(gb.left - 1, gb.bottom + 2), Offset(at(length - .35, 0).dx, gb.bottom + 2.3), light);
      case _Era.tens:
        // Rising shoulder line from the front wing to the tail lamp, and a sculpted lower door line.
        final a = at(length - .5, hood - .06), m = at(length * .5, hood - .02), b = at(.15, hood + .12);
        canvas.drawPath(
          Path()
            ..moveTo(a.dx, a.dy)
            ..quadraticBezierTo(m.dx, m.dy, b.dx, b.dy),
          light,
        );
        final from = at(s.wheels.$2 - s.wheelRadius * 1.3, s.sill + .16);
        final to = at(s.wheels.$1 + s.wheelRadius * 1.25, s.sill + .30);
        canvas.drawPath(
          Path()
            ..moveTo(from.dx, from.dy)
            ..quadraticBezierTo((from.dx + to.dx) / 2, from.dy - .2, to.dx, to.dy),
          crease,
        );
    }
    // Door shut lines below the pillars and at the front door's leading edge.
    for (final x in [...s.pillars, s.glass.map((c) => c.$1).reduce(max) + .08]) {
      final p = at(x, 0).dx;
      canvas.drawLine(Offset(p, gb.bottom + .3), Offset(p, low + .8), crease);
    }
    _lamps(canvas, s, at, era);
    canvas.restore();

    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        // About half a pixel wherever it is drawn, so small avatars keep a visible edge.
        ..strokeWidth = max(.45, .6 / scale)
        ..strokeJoin = StrokeJoin.round,
    );

    // Tinted glass with a soft reflection.
    canvas.drawPath(
      glass,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark ? const [Color(0xFF55646F), Color(0xFF2A333A)] : const [Color(0xFF4E5E6B), Color(0xFF283139)],
        ).createShader(gb),
    );
    canvas.save();
    canvas.clipPath(glass);
    canvas.drawPath(
      _polygon([
        Offset(gb.left + gb.width * .55, gb.top),
        Offset(gb.left + gb.width * .72, gb.top),
        Offset(gb.left + gb.width * .60, gb.bottom),
        Offset(gb.left + gb.width * .43, gb.bottom),
      ]),
      Paint()..color = Colors.white.withValues(alpha: .10),
    );
    // Pillars: body-coloured in the 2000s, gloss black in the 2010s.
    final pillar = Paint()
      ..color = era == _Era.tens ? const Color(0xFF15181A) : shade(-.04)
      ..strokeWidth = 1.6;
    for (final x in s.pillars) {
      final p = at(x, 0).dx;
      canvas.drawLine(Offset(p, gb.top - .5), Offset(p, gb.bottom + .5), pillar);
    }
    canvas.restore();
    // A chrome window surround on 2010s cars.
    if (era == _Era.tens) {
      canvas.drawPath(
        glass,
        Paint()
          ..color = const Color(0xFFD7DCE0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .45,
      );
    }

    if (s.roofRails) {
      final roof = s.outline.map((c) => c.$2).reduce(max) + .03;
      final glassXs = s.glass.map((c) => c.$1);
      canvas.drawLine(
        at(glassXs.reduce(min) + .2, roof),
        at(glassXs.reduce(max) - .7, roof),
        Paint()
          ..color = const Color(0xFF30363B)
          ..strokeWidth = era == _Era.tens ? .7 : 1.0
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  /// The same large two-tone alloys on every car.
  void _wheels(Canvas canvas, _Spec s, _At at) {
    final r = s.wheelRadius * _scale;
    for (final x in [s.wheels.$1, s.wheels.$2]) {
      final c = at(x, s.wheelRadius);
      canvas.drawCircle(c, r * 1.1, Paint()..color = const Color(0xFF15181B));
      canvas.drawCircle(c, r, Paint()..color = const Color(0xFF202427));
      // Large two-tone alloy on a low-profile tyre.
      canvas.drawCircle(c, r * .76, Paint()..color = const Color(0xFF3B4247));
      final spoke = Paint()
        ..color = const Color(0xFFD5DADE)
        ..strokeWidth = r * .1
        ..strokeCap = StrokeCap.round;
      for (var k = 0; k < 5; k++) {
        final a = -pi / 2 + k * 2 * pi / 5;
        for (final d in [-.12, .12]) {
          canvas.drawLine(
            c + Offset(cos(a + d), sin(a + d)) * r * .14,
            c + Offset(cos(a + d * .5), sin(a + d * .5)) * r * .7,
            spoke,
          );
        }
      }
      canvas.drawCircle(c, r * .14, Paint()..color = const Color(0xFF9AA3A9));
    }
  }

  /// Head and tail lamps in the shape of their time: swept teardrops or slim LED strips.
  void _lamps(Canvas canvas, _Spec s, _At at, _Era era) {
    final len = s.length, h = s.hoodY, t = h + .06;
    final head = Paint()..color = const Color(0xFFF2F5F7);
    final tail = Paint()..color = const Color(0xFFD32F2F);
    Path shape(List<(double, double)> p) => _polygon([for (final (x, y) in p) at(x, y)]);
    switch (era) {
      case _Era.noughties:
        canvas.drawPath(
          shape([(len - .52, h - .03), (len - .06, h - .08), (len, h - .22), (len - .30, h - .18)]),
          head,
        );
        canvas.drawPath(shape([(0, t), (.30, t + .02), (.33, t - .10), (0, t - .17)]), tail);
      case _Era.tens:
        canvas.drawPath(
          shape([(len - .62, h - .03), (len - .04, h - .09), (len, h - .15), (len - .46, h - .08)]),
          head,
        );
        canvas.drawPath(shape([(0, t + .02), (.52, t + .04), (.52, t - .02), (0, t - .06)]), tail);
    }
  }

  @override
  bool shouldRepaint(CarPainter old) => old.body != body || old.color != color || old.brightness != brightness;
}

/// [CarPainter] sized to [width].
class CarDrawing extends StatelessWidget {
  const CarDrawing({super.key, required this.body, required this.color, required this.width});

  final BodyType body;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, width / CarPainter.aspectRatio),
    painter: CarPainter(body: body, color: color, brightness: Theme.of(context).brightness),
  );
}
