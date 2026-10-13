import 'dart:math';

import 'package:flutter/material.dart';

import '../model/enums.dart';

/// Side view of one body type in a 100×44 box, facing right. Outlines are SVG-style paths
/// (absolute M L C Q A Z) so they can be tuned in any SVG editor.
class _Profile {
  const _Profile({
    required this.body,
    required this.glass,
    required this.wheels,
    required this.head,
    required this.tail,
    this.r = 7.5,
    this.wheelY = 34.5,
    this.pillars = const [],
    this.lines = const [],
  });

  final String body;
  final String glass;

  /// X of the rear and front wheel centres; [body] has arches cut around them.
  final (double, double) wheels;
  final double r;
  final double wheelY;

  /// Centres of the headlight and the tail light.
  final Offset head;
  final Offset tail;

  /// X positions where the side glass is split.
  final List<double> pillars;

  /// Extra strokes: roof rails, a pickup's bed seam.
  final List<String> lines;
}

/// Path of a wheel arch: straight along the sill to the arch, then over the wheel.
String _arch(double cx, double sill, double radius, {double wheelY = 34.5}) {
  final dy = sill - wheelY;
  final half = sqrt(radius * radius - dy * dy);
  return 'L ${cx - half} $sill A $radius $radius 0 1 1 ${cx + half} $sill';
}

// Wheelbases differ on purpose so the type reads at a glance:
// hatchback 45 < coupe 52 < sedan 56 = SUV < wagon 60 < van 63 < pickup 64.
final _profiles = <BodyType, _Profile>{
  BodyType.sedan: _Profile(
    body: 'M 6 36 ${_arch(22, 36, 9)} ${_arch(78, 36, 9)} L 94 36 Q 97.5 36 97.5 33 L 97.5 29 '
        'C 97.5 26 96 24.5 92 23.6 C 84 22 76 21.5 70 20.5 C 62 15 56 11.5 47 11 C 38 10.8 31 13 24 19.5 '
        'C 20 20.8 12 21 7 21.6 C 4 22 3 24 3 27 L 3 33 Q 3 36 6 36 Z',
    glass: 'M 27 20.2 C 33 14.5 38 12.6 46.5 12.6 C 53 12.6 58 14.8 64 20.2 Z',
    wheels: (22, 78),
    pillars: [45],
    head: const Offset(94.5, 25.6),
    tail: const Offset(3.8, 24.5),
  ),
  BodyType.hatchback: _Profile(
    body: 'M 13.5 36 ${_arch(27, 36, 9)} ${_arch(72, 36, 9)} L 83.5 36 Q 87 36 87 33 L 87 29.5 '
        'C 87 26.5 85.6 25 82 24 C 76 22.6 70 21.8 64 20.8 C 58 15.5 53 12 45 11.4 C 35 11 25 11.2 19.5 12.8 '
        'C 15.5 14 13 17.5 12.4 22.5 L 11.6 33 Q 11.6 36 13.5 36 Z',
    glass: 'M 16 20.2 C 17 16.5 18.6 14.3 21.6 13.6 C 29 12.9 37 12.7 45 13.2 C 51 13.6 55.4 16.1 60 20.2 Z',
    wheels: (27, 72),
    pillars: [36],
    head: const Offset(84, 26),
    tail: const Offset(12.6, 22.5),
  ),
  BodyType.wagon: _Profile(
    body: 'M 5 36 ${_arch(19, 36, 9)} ${_arch(79, 36, 9)} L 94.5 36 Q 98 36 98 33 L 98 29 '
        'C 98 26 96.5 24.5 92.5 23.6 C 85 22 77.5 21.5 71.5 20.5 C 63.5 15 57.5 11.5 48.5 11 '
        'C 36 10.6 18 10.6 8.5 11.4 C 4.5 11.8 2.6 15 2.2 20 L 2 33 Q 2 36 5 36 Z',
    glass: 'M 5 20.2 C 5.4 16.5 6.8 14 10 13.4 C 22 12.7 36 12.6 48.5 13 C 54.5 13.4 59.5 15.6 65.5 20.2 Z',
    wheels: (19, 79),
    pillars: [25, 45],
    head: const Offset(95, 25.6),
    tail: const Offset(2.8, 22),
  ),
  BodyType.coupe: _Profile(
    body: 'M 6 36 ${_arch(24, 36, 9)} ${_arch(76, 36, 9)} L 94 36 Q 97.5 36 97.5 33 L 97.5 29.8 '
        'C 97.5 27 96 25.6 92 24.8 C 83 23.4 74 22.8 66 22 C 60 16.8 55 13.8 47.5 13.6 C 40 13.5 33 15.5 25 21.2 '
        'C 19 22.8 9 23.2 5.5 23.8 C 3.6 24.3 3 25.6 3 28 L 3 33 Q 3 36 6 36 Z',
    glass: 'M 31.5 21.4 C 36.5 17 40.5 15.3 47 15.3 C 52.5 15.3 56.5 17.3 60.5 21.4 Z',
    wheels: (24, 76),
    head: const Offset(94.5, 26.8),
    tail: const Offset(3.6, 26.2),
  ),
  BodyType.suv: _Profile(
    body: 'M 6 34.5 ${_arch(22, 34.5, 10, wheelY: 34.2)} ${_arch(78, 34.5, 10, wheelY: 34.2)} L 94 34.5 '
        'Q 97.5 34.5 97.5 31 L 97.5 26 C 97.5 22.5 96 21 92 20.2 C 85 19 77 18.4 70 17.6 C 64 12 59 8.2 51 7.6 '
        'C 38 7 22 7 11 7.6 C 6.5 8 4.5 11 3.8 16 L 3 31 Q 3 34.5 6 34.5 Z',
    glass: 'M 6.5 16.8 C 6.8 13 8.4 10.2 11.5 9.8 C 24 9.2 38 9.2 51 9.8 C 57 10.3 61 13 65 16.8 Z',
    wheels: (22, 78),
    r: 8.3,
    wheelY: 34.2,
    pillars: [25, 45],
    head: const Offset(94.5, 22.4),
    tail: const Offset(3.6, 18),
    lines: ['M 13 6.2 C 25 5.6 40 5.6 50 6.2'],
  ),
  BodyType.pickup: _Profile(
    body: 'M 4 34.5 ${_arch(17, 34.5, 10, wheelY: 34.2)} ${_arch(81, 34.5, 10, wheelY: 34.2)} L 95 34.5 '
        'Q 98.5 34.5 98.5 31 L 98.5 26 C 98.5 22.5 97 21 93 20.2 C 86 19 78 18.4 71 17.6 C 65 12.4 60 8.6 53 8.2 '
        'L 47 8.2 C 44.5 8.2 43.2 9.5 43 12 L 42.5 19.5 L 3 19.5 C 2 19.5 1.5 20.2 1.5 21.5 L 1.5 31.5 '
        'Q 1.5 34.5 4 34.5 Z',
    glass: 'M 46 16.6 L 46.3 11.8 C 46.4 10.6 47 10.2 48.5 10.2 L 53 10.2 C 58.5 10.6 62.5 13.3 66.5 16.6 Z',
    wheels: (17, 81),
    r: 8.3,
    wheelY: 34.2,
    head: const Offset(95.5, 22.4),
    tail: const Offset(2.2, 22),
    lines: ['M 42.6 20 L 42.6 30'],
  ),
  BodyType.van: _Profile(
    body: 'M 5 35 ${_arch(17.5, 35, 9.5)} ${_arch(80.5, 35, 9.5)} L 94 35 Q 97.5 35 97.5 31.5 L 97.5 26.5 '
        'C 97.5 22.8 96 21.4 92.5 20.4 C 87 18.6 83 16 77 9.6 C 74.5 6.8 71.5 5 66 4.8 C 48 4.4 22 4.4 7 4.8 '
        'C 4 4.9 2.6 6.5 2.5 9.5 L 2.5 32 Q 2.5 35 5 35 Z',
    glass: 'M 6 15 L 6 9.5 C 6 8.2 6.7 7.6 8 7.6 L 66 7.6 C 70 7.7 72.5 9 75.2 11.6 L 79 15 Z',
    wheels: (17.5, 80.5),
    r: 8,
    pillars: [25, 46, 66],
    head: const Offset(94.8, 23),
    tail: const Offset(3.2, 21),
  ),
};

final _pathCache = <String, Path>{};

/// Parses the absolute SVG path subset used by the profiles.
Path _svg(String d) => _pathCache.putIfAbsent(d, () {
      final path = Path();
      final tokens = RegExp(r'[MLCQAZ]|-?\d*\.?\d+').allMatches(d).map((m) => m.group(0)!).toList();
      var i = 0;
      double n() => double.parse(tokens[i++]);
      var cmd = 'M';
      while (i < tokens.length) {
        if ('MLCQAZ'.contains(tokens[i])) cmd = tokens[i++];
        switch (cmd) {
          case 'M':
            path.moveTo(n(), n());
            cmd = 'L';
          case 'L':
            path.lineTo(n(), n());
          case 'C':
            path.cubicTo(n(), n(), n(), n(), n(), n());
          case 'Q':
            path.quadraticBezierTo(n(), n(), n(), n());
          case 'A':
            final rx = n(), ry = n(), rotation = n(), large = n() != 0, sweep = n() != 0;
            path.arcToPoint(Offset(n(), n()),
                radius: Radius.elliptical(rx, ry), rotation: rotation, largeArc: large, clockwise: sweep);
          case 'Z':
            path.close();
        }
      }
      return path;
    });

/// A small schematic side view of a car in the vehicle's colour.
class CarPainter extends CustomPainter {
  const CarPainter({required this.body, required this.color, required this.brightness});

  final BodyType body;
  final Color color;
  final Brightness brightness;

  /// Width / height of the drawing.
  static const aspectRatio = 100 / 44;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _profiles[body]!;
    final dark = brightness == Brightness.dark;
    final scale = size.width / 100;
    canvas.save();
    canvas.translate(0, (size.height - 44 * scale) / 2);
    canvas.scale(scale);

    final hsl = HSLColor.fromColor(color);
    final l = hsl.lightness;
    // Dark paint gets a lighter outline so a black car stays visible on a dark background.
    final outline = (l < .3 ? hsl.withLightness(l + .3) : hsl.withLightness((l - .22).clamp(0, 1))).toColor();
    final top = hsl.withLightness((l + .14).clamp(0, .98)).toColor();
    final bottom = hsl.withLightness((l - .1).clamp(0, 1)).toColor();

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 42.2), width: 92, height: 2.6),
      Paint()
        ..color = Colors.black.withValues(alpha: dark ? .5 : .16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );

    // Wheels sit under the body and show through the arches.
    for (final x in [p.wheels.$1, p.wheels.$2]) {
      final c = Offset(x, p.wheelY);
      final rim = Rect.fromCircle(center: c, radius: p.r * .6);
      canvas.drawCircle(c, p.r, Paint()..color = const Color(0xFF1F2427));
      canvas.drawCircle(
        c,
        p.r * .6,
        Paint()..shader = const RadialGradient(colors: [Color(0xFFD5DBE0), Color(0xFF98A3AB)]).createShader(rim),
      );
      canvas.drawCircle(c, p.r * .2, Paint()..color = const Color(0xFF616B72));
    }

    final bodyPath = _svg(p.body);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, color, bottom],
          stops: const [0, .5, 1],
        ).createShader(bodyPath.getBounds()),
    );
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9
        ..strokeJoin = StrokeJoin.round,
    );

    final glass = _svg(p.glass);
    final gb = glass.getBounds();
    final tint = dark ? const [Color(0xFFC3D4E3), Color(0xFF7890A6)] : const [Color(0xFFE8F2FA), Color(0xFF9FBAD2)];
    canvas.drawPath(
      glass,
      Paint()..shader = LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: tint).createShader(gb),
    );
    final pillar = Paint()
      ..color = color
      ..strokeWidth = 1.6;
    for (final x in p.pillars) {
      canvas.drawLine(Offset(x, gb.top - 1), Offset(x, gb.bottom + 1), pillar);
    }
    // Shoulder crease under the windows.
    canvas.drawLine(
      Offset(gb.left + 1, gb.bottom + 3),
      Offset(p.head.dx - 6, gb.bottom + 3),
      Paint()
        ..color = (l > .75 ? Colors.black : Colors.white).withValues(alpha: .12)
        ..strokeWidth = .7
        ..strokeCap = StrokeCap.round,
    );
    final line = Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    for (final d in p.lines) {
      canvas.drawPath(_svg(d), line);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: p.head, width: 5, height: 1.8), const Radius.circular(.9)),
      Paint()..color = const Color(0xFFFFF5D6),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: p.tail, width: 1.6, height: 3.4), const Radius.circular(.8)),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.restore();
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
