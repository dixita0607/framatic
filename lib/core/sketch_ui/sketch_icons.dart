import 'dart:math' as math;

import 'package:flutter/widgets.dart';

enum SketchIconType {
  add,
  check,
  close,
  delete,
  drag,
  edit,
  error,
  flipCamera,
  more,
  settings,
}

class SketchIcon extends StatelessWidget {
  final SketchIconType type;
  final double size;
  final Color? color;

  const SketchIcon({super.key, required this.type, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SketchIconPainter(type: type, color: color),
    );
  }
}

class _SketchIconPainter extends CustomPainter {
  final SketchIconType type;
  final Color? color;

  _SketchIconPainter({required this.type, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = color ?? const Color(0xFFF4EFE2);
    final paint = Paint()
      ..color = c
      ..strokeWidth = math.max(1.8, size.width / 12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = c
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    Offset p(double x, double y) => Offset(w * x, h * y);

    switch (type) {
      case SketchIconType.add:
        canvas.drawLine(p(0.5, 0.18), p(0.5, 0.82), paint);
        canvas.drawLine(p(0.18, 0.5), p(0.82, 0.5), paint);
      case SketchIconType.check:
        final path = Path()
          ..moveTo(w * 0.18, h * 0.52)
          ..lineTo(w * 0.42, h * 0.76)
          ..lineTo(w * 0.84, h * 0.25);
        canvas.drawPath(path, paint);
      case SketchIconType.close:
        canvas.drawLine(p(0.22, 0.22), p(0.78, 0.78), paint);
        canvas.drawLine(p(0.78, 0.22), p(0.22, 0.78), paint);
      case SketchIconType.delete:
        canvas.drawLine(p(0.25, 0.32), p(0.75, 0.32), paint);
        canvas.drawLine(p(0.38, 0.22), p(0.62, 0.22), paint);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.3, h * 0.36, w * 0.4, h * 0.46),
            Radius.circular(w * 0.05),
          ),
          paint,
        );
        canvas.drawLine(p(0.43, 0.46), p(0.43, 0.72), paint);
        canvas.drawLine(p(0.57, 0.46), p(0.57, 0.72), paint);
      case SketchIconType.drag:
        for (final y in [0.32, 0.5, 0.68]) {
          canvas.drawLine(p(0.22, y), p(0.78, y), paint);
        }
      case SketchIconType.edit:
        final body = Path()
          ..moveTo(w * 0.24, h * 0.72)
          ..lineTo(w * 0.62, h * 0.34)
          ..lineTo(w * 0.75, h * 0.47)
          ..lineTo(w * 0.37, h * 0.85)
          ..close();
        canvas.drawPath(body, paint);
        canvas.drawLine(p(0.58, 0.31), p(0.68, 0.21), paint);
        canvas.drawLine(p(0.68, 0.21), p(0.84, 0.37), paint);
        canvas.drawLine(p(0.84, 0.37), p(0.75, 0.47), paint);
        final tip = Path()
          ..moveTo(w * 0.24, h * 0.72)
          ..lineTo(w * 0.18, h * 0.92)
          ..lineTo(w * 0.37, h * 0.85)
          ..close();
        canvas.drawPath(tip, paint);
        canvas.drawCircle(p(0.21, 0.88), w * 0.025, fill);
      case SketchIconType.error:
        canvas.drawCircle(p(0.5, 0.5), w * 0.34, paint);
        canvas.drawLine(p(0.5, 0.28), p(0.5, 0.56), paint);
        canvas.drawCircle(p(0.5, 0.72), w * 0.025, fill);
      case SketchIconType.flipCamera:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.2, h * 0.3, w * 0.6, h * 0.44),
            Radius.circular(w * 0.08),
          ),
          paint,
        );
        canvas.drawLine(p(0.36, 0.3), p(0.44, 0.2), paint);
        canvas.drawLine(p(0.44, 0.2), p(0.6, 0.2), paint);
        canvas.drawArc(
          Rect.fromCircle(center: p(0.5, 0.52), radius: w * 0.18),
          0.2,
          math.pi * 1.4,
          false,
          paint,
        );
        canvas.drawLine(p(0.64, 0.48), p(0.75, 0.48), paint);
        canvas.drawLine(p(0.75, 0.48), p(0.69, 0.38), paint);
      case SketchIconType.more:
        for (final y in [0.3, 0.5, 0.7]) {
          canvas.drawCircle(p(0.5, y), w * 0.055, fill);
        }
      case SketchIconType.settings:
        final gear = Path();
        for (var i = 0; i < 16; i++) {
          final angle = -math.pi / 2 + i * math.pi / 8;
          final radius = i.isEven ? 0.39 : 0.31;
          final point = p(
            0.5 + math.cos(angle) * radius,
            0.5 + math.sin(angle) * radius,
          );
          if (i == 0) {
            gear.moveTo(point.dx, point.dy);
          } else {
            gear.lineTo(point.dx, point.dy);
          }
        }
        gear.close();
        canvas.drawPath(gear, paint);
        canvas.drawCircle(p(0.5, 0.5), w * 0.14, paint);
        canvas.drawCircle(p(0.5, 0.5), w * 0.035, fill);
    }
  }

  @override
  bool shouldRepaint(_SketchIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
