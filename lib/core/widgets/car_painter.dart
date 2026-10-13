import 'package:flutter/material.dart';

import '../model/enums.dart';

/// Side-view outline of one body type in a 100×44 box, facing right, wheels on y = [wheelY].
class _Profile {
  const _Profile({
    required this.body,
    required this.glass,
    required this.wheels,
    required this.head,
    required this.tail,
    this.wheelR = 7,
    this.wheelY = 35,
    this.pillars = const [],
    this.lines = const [],
  });

  /// Upper outline from the rear bottom to the front bottom; closed along the sill.
  final List<Offset> body;
  final List<Offset> glass;

  /// Centres of the headlight and the tail light.
  final Offset head;
  final Offset tail;

  /// X of the rear and front wheel centres.
  final (double, double) wheels;
  final double wheelR;
  final double wheelY;

  /// X positions where the side glass is split.
  final List<double> pillars;

  /// Extra panel lines (e.g. a pickup's bed).
  final List<(Offset, Offset)> lines;
}

const _profiles = <BodyType, _Profile>{
  BodyType.sedan: _Profile(
    body: [
      Offset(3, 35), Offset(3, 26), Offset(6, 23), Offset(22, 21), Offset(32, 13), Offset(37, 11.5), //
      Offset(57, 11.5), Offset(68, 20), Offset(90, 22), Offset(96, 25), Offset(97, 30), Offset(97, 35),
    ],
    glass: [Offset(32.5, 20.5), Offset(37.5, 14), Offset(55, 14), Offset(64, 20.5)],
    wheels: (22, 79),
    head: Offset(94, 25.5),
    tail: Offset(4.5, 25),
    pillars: [47],
  ),
  BodyType.hatchback: _Profile(
    body: [
      Offset(5, 35), Offset(4, 24), Offset(7, 15), Offset(13, 11.5), Offset(52, 11.5), Offset(64, 20), //
      Offset(86, 22), Offset(92, 25), Offset(93, 30), Offset(93, 35),
    ],
    glass: [Offset(9, 20.5), Offset(13.5, 14), Offset(51, 14), Offset(60, 20.5)],
    wheels: (21, 76),
    head: Offset(90, 25.5),
    tail: Offset(5.5, 22),
    pillars: [34],
  ),
  BodyType.wagon: _Profile(
    body: [
      Offset(3, 35), Offset(3, 23), Offset(5, 13), Offset(10, 11), Offset(56, 11), Offset(68, 20), //
      Offset(90, 22), Offset(96, 25), Offset(97, 30), Offset(97, 35),
    ],
    glass: [Offset(6.5, 20.5), Offset(10.5, 13.5), Offset(55, 13.5), Offset(64, 20.5)],
    wheels: (22, 79),
    head: Offset(94, 25.5),
    tail: Offset(4.5, 22),
    pillars: [25, 45],
  ),
  BodyType.coupe: _Profile(
    body: [
      Offset(3, 35), Offset(3, 27), Offset(8, 24), Offset(26, 22.5), Offset(38, 14), Offset(44, 12.5), //
      Offset(54, 12.5), Offset(68, 21), Offset(90, 23), Offset(96, 26), Offset(97, 31), Offset(97, 35),
    ],
    glass: [Offset(36, 21.5), Offset(42, 15), Offset(53, 15), Offset(63, 21.5)],
    wheels: (23, 79),
    head: Offset(94, 26.5),
    tail: Offset(4.5, 26.5),
  ),
  BodyType.suv: _Profile(
    body: [
      Offset(3, 33), Offset(3, 19), Offset(6, 9), Offset(11, 7), Offset(58, 7), Offset(69, 17), //
      Offset(91, 19), Offset(96, 22), Offset(97, 27), Offset(97, 33),
    ],
    glass: [Offset(7, 17.5), Offset(11, 10), Offset(57, 10), Offset(65, 17.5)],
    wheels: (22, 78),
    head: Offset(94, 22.5),
    tail: Offset(4.5, 18),
    wheelR: 8,
    wheelY: 34,
    pillars: [27, 44],
    lines: [(Offset(14, 6.2), Offset(52, 6.2))],
  ),
  BodyType.pickup: _Profile(
    body: [
      Offset(2, 33), Offset(2, 20), Offset(42, 20), Offset(43, 8), Offset(60, 8), Offset(70, 18), //
      Offset(91, 20), Offset(96, 23), Offset(97, 28), Offset(97, 33),
    ],
    glass: [Offset(46, 17), Offset(47, 11), Offset(59, 11), Offset(66, 17)],
    wheels: (20, 79),
    head: Offset(94, 23.5),
    tail: Offset(3.5, 22.5),
    wheelR: 8,
    wheelY: 34,
    lines: [(Offset(41, 20), Offset(41, 31))],
  ),
  BodyType.van: _Profile(
    body: [
      Offset(2, 34), Offset(2, 6), Offset(4, 4), Offset(68, 4), Offset(82, 15), Offset(93, 19), //
      Offset(97, 23), Offset(97, 34),
    ],
    glass: [Offset(6, 14), Offset(6, 8), Offset(70, 8), Offset(78, 14.5)],
    wheels: (18, 80),
    head: Offset(95, 23.5),
    tail: Offset(3.5, 20),
    wheelR: 7.5,
    wheelY: 35,
    pillars: [26, 48, 66],
  ),
};

/// A small schematic side view of a car in the vehicle's colour.
class CarPainter extends CustomPainter {
  const CarPainter({required this.body, required this.color, required this.background, required this.brightness});

  final BodyType body;
  final Color color;

  /// Colour behind the car; separates the wheels from the body.
  final Color background;
  final Brightness brightness;

  /// Width / height of the drawing.
  static const aspectRatio = 100 / 44;

  @override
  void paint(Canvas canvas, Size size) {
    final p = _profiles[body]!;
    final scale = size.width / 100;
    canvas.save();
    canvas.translate(0, (size.height - 44 * scale) / 2);
    canvas.scale(scale);

    final hsl = HSLColor.fromColor(color);
    final outline = hsl.withLightness((hsl.lightness - .22).clamp(0, 1)).toColor();
    final glass = brightness == Brightness.dark ? const Color(0xFF9DB4C8) : const Color(0xFFD3E6F5);

    // Soft ground shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(50, p.wheelY + p.wheelR), width: 92, height: 3),
      Paint()..color = Colors.black.withValues(alpha: brightness == Brightness.dark ? .35 : .15),
    );

    final bodyPath = Path()..addPolygon(p.body, true);
    canvas.drawPath(bodyPath, Paint()..color = color);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(Path()..addPolygon(p.glass, true), Paint()..color = glass);
    final pillar = Paint()
      ..color = color
      ..strokeWidth = 2;
    final glassTop = p.glass.map((o) => o.dy).reduce((a, b) => a < b ? a : b);
    final glassBottom = p.glass.map((o) => o.dy).reduce((a, b) => a > b ? a : b);
    for (final x in p.pillars) {
      canvas.drawLine(Offset(x, glassTop - 1), Offset(x, glassBottom + 1), pillar);
    }
    final line = Paint()
      ..color = outline
      ..strokeWidth = 1;
    for (final (a, b) in p.lines) {
      canvas.drawLine(a, b, line..strokeWidth = a.dy == b.dy ? 1.6 : 1);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: p.head, width: 4, height: 2.4), const Radius.circular(1)),
      Paint()..color = const Color(0xFFFFF3C4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: p.tail, width: 2.2, height: 3.2), const Radius.circular(1)),
      Paint()..color = const Color(0xFFE53935),
    );

    for (final x in [p.wheels.$1, p.wheels.$2]) {
      final c = Offset(x, p.wheelY);
      canvas.drawCircle(c, p.wheelR + 1.6, Paint()..color = background);
      canvas.drawCircle(c, p.wheelR, Paint()..color = const Color(0xFF263238));
      canvas.drawCircle(c, p.wheelR * .45, Paint()..color = const Color(0xFFB0BEC5));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CarPainter old) =>
      old.body != body || old.color != color || old.background != background || old.brightness != brightness;
}

/// [CarPainter] sized to [width], on a given background.
class CarDrawing extends StatelessWidget {
  const CarDrawing({super.key, required this.body, required this.color, required this.width, required this.background});

  final BodyType body;
  final Color color;
  final double width;
  final Color background;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(width, width / CarPainter.aspectRatio),
        painter: CarPainter(body: body, color: color, background: background, brightness: Theme.of(context).brightness),
      );
}
