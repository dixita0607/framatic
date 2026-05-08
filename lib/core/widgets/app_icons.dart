import 'dart:math';

import 'package:flutter/widgets.dart';

class PencilIcon extends StatelessWidget {
  final Color color;
  final double size;

  const PencilIcon({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _PencilPainter(color));
}

class RotateCameraIcon extends StatelessWidget {
  final Color color;
  final double size;

  const RotateCameraIcon({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _RotateCameraPainter(color));
}

class ErrorOutlineIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ErrorOutlineIcon({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _ErrorOutlinePainter(color));
}

class _PencilPainter extends CustomPainter {
  final Color color;
  const _PencilPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final paint = Paint()
      ..color = color
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Pencil body at ~45°, tip at bottom-left, eraser at top-right.
    // Left edge: (0.22, 0.78) → (0.72, 0.28)
    // Right edge: (0.42, 0.78) → (0.92, 0.28)
    final path = Path()
      ..moveTo(s * 0.22, s * 0.78) // body left, near tip
      ..lineTo(s * 0.72, s * 0.28) // body left, eraser end
      ..lineTo(s * 0.82, s * 0.18) // eraser cap left
      ..lineTo(s * 0.92, s * 0.28) // eraser cap right
      ..lineTo(s * 0.42, s * 0.78) // body right, near tip
      ..lineTo(s * 0.32, s * 0.88) // tip base right
      ..lineTo(s * 0.12, s * 0.88) // sharp tip
      ..close();
    canvas.drawPath(path, paint);

    // Eraser divider at 82% along the body from tip end
    canvas.drawLine(
      Offset(s * 0.63, s * 0.37),
      Offset(s * 0.83, s * 0.37),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PencilPainter old) => old.color != color;
}

class _RotateCameraPainter extends CustomPainter {
  final Color color;
  const _RotateCameraPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2, cy = s / 2;
    final r = s * 0.34;
    final arrowLen = s * 0.18;

    final paint = Paint()
      ..color = color
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);

    // Two opposing 120° arcs, each with an arrowhead at the end.
    // drawArc sweepAngle > 0 is clockwise in Flutter's y-down canvas.
    canvas.drawArc(rect, 210 * pi / 180, 120 * pi / 180, false, paint);
    canvas.drawArc(rect, 30 * pi / 180, 120 * pi / 180, false, paint);

    // Clockwise tangent at angle θ: direction vector = (-sinθ, cosθ)
    // atan2(y, x) = atan2(cosθ, -sinθ)
    void drawArrowhead(double endDeg) {
      final endRad = endDeg * pi / 180;
      final tip = Offset(cx + r * cos(endRad), cy + r * sin(endRad));
      final tangentAngle = atan2(cos(endRad), -sin(endRad));
      final backAngle = tangentAngle + pi;
      const spread = pi / 5;
      canvas.drawLine(
        tip,
        tip + Offset(cos(backAngle + spread) * arrowLen, sin(backAngle + spread) * arrowLen),
        paint,
      );
      canvas.drawLine(
        tip,
        tip + Offset(cos(backAngle - spread) * arrowLen, sin(backAngle - spread) * arrowLen),
        paint,
      );
    }

    drawArrowhead(330); // end of top arc
    drawArrowhead(150); // end of bottom arc
  }

  @override
  bool shouldRepaint(_RotateCameraPainter old) => old.color != color;
}

class _ErrorOutlinePainter extends CustomPainter {
  final Color color;
  const _ErrorOutlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final cx = s / 2, cy = s / 2;
    final r = s * 0.44;

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Sketchy circle: 4 bezier segments where the cardinal endpoints are
    // slightly perturbed so the circle looks hand-drawn rather than perfect.
    const k = 0.552; // bezier handle ratio for circle approximation
    final right  = Offset(cx + r * 1.01,  cy + r * 0.02);
    final bottom = Offset(cx + r * 0.02,  cy + r * 1.01);
    final left   = Offset(cx - r * 1.02,  cy - r * 0.01);
    final top    = Offset(cx - r * 0.01,  cy - r * 1.02);

    final circle = Path()
      ..moveTo(top.dx, top.dy)
      ..cubicTo(cx + k * r, cy - r,    cx + r, cy - k * r,    right.dx,  right.dy)
      ..cubicTo(cx + r, cy + k * r,    cx + k * r, cy + r,    bottom.dx, bottom.dy)
      ..cubicTo(cx - k * r, cy + r,    cx - r, cy + k * r,    left.dx,   left.dy)
      ..cubicTo(cx - r, cy - k * r,    cx - k * r, cy - r,    top.dx,    top.dy);
    canvas.drawPath(circle, strokePaint);

    // Exclamation body: slight cubic curve for a hand-drawn feel
    final exclamPath = Path()
      ..moveTo(cx + s * 0.03, cy - r * 0.48)
      ..cubicTo(
        cx - s * 0.04, cy - r * 0.15,
        cx + s * 0.04, cy + r * 0.05,
        cx, cy + r * 0.12,
      );
    canvas.drawPath(exclamPath, strokePaint);

    // Exclamation dot (filled)
    canvas.drawCircle(
      Offset(cx, cy + r * 0.46),
      s * 0.055,
      Paint()..color = color..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_ErrorOutlinePainter old) => old.color != color;
}
