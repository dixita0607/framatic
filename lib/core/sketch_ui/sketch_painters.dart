import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'sketch_theme.dart';

enum SketchShape { rect, roundedRect, pill, circle }

class SketchBorderPainter extends CustomPainter {
  final SketchThemeData theme;
  final Color? strokeColor;
  final Color? fillColor;
  final Color? hachureColor;
  final SketchShape shape;
  final double radius;
  final int seed;
  final bool hachure;

  const SketchBorderPainter({
    required this.theme,
    this.strokeColor,
    this.fillColor,
    this.hachureColor,
    this.shape = SketchShape.roundedRect,
    this.radius = 10,
    this.seed = 1,
    this.hachure = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final innerRect = rect.deflate(theme.strokeWidth * 2);
    final fill = fillColor;

    if (fill != null) {
      final fillPaint = Paint()
        ..color = fill
        ..style = PaintingStyle.fill;
      canvas.drawPath(_cleanShapePath(rect), fillPaint);
    }

    if (hachure && innerRect.width > 0 && innerRect.height > 0) {
      canvas.save();
      canvas.clipPath(_cleanShapePath(innerRect));
      _drawHachure(canvas, innerRect);
      canvas.restore();
    }

    final strokePaint = Paint()
      ..color = strokeColor ?? theme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final random = math.Random(seed);
    for (var pass = 0; pass < 2; pass++) {
      final path = _roughPath(rect.deflate(theme.strokeWidth), random);
      canvas.drawPath(path, strokePaint);
    }
  }

  Path _cleanShapePath(Rect rect) {
    switch (shape) {
      case SketchShape.circle:
        return Path()..addOval(rect);
      case SketchShape.pill:
        return Path()..addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.height / 2)),
        );
      case SketchShape.roundedRect:
        return Path()
          ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      case SketchShape.rect:
        return Path()..addRect(rect);
    }
  }

  Path _roughPath(Rect rect, math.Random random) {
    switch (shape) {
      case SketchShape.circle:
        return _roughOval(rect, random);
      case SketchShape.pill:
        return _roughRRect(rect, rect.height / 2, random);
      case SketchShape.roundedRect:
        return _roughRRect(rect, radius, random);
      case SketchShape.rect:
        return _roughPolygon([
          rect.topLeft,
          rect.topRight,
          rect.bottomRight,
          rect.bottomLeft,
        ], random);
    }
  }

  Path _roughRRect(Rect rect, double cornerRadius, math.Random random) {
    final effectiveRadius = cornerRadius.clamp(
      0.0,
      math.min(rect.width, rect.height) / 2,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(effectiveRadius),
    );
    final path = Path()..addRRect(rrect);
    return _jitterPath(path, random);
  }

  Path _roughOval(Rect rect, math.Random random) {
    final path = Path();
    const points = 28;
    for (var i = 0; i <= points; i++) {
      final angle = (math.pi * 2 * i) / points;
      final jitter = _jitterOffset(random);
      final x = rect.center.dx + math.cos(angle) * (rect.width / 2 + jitter.dx);
      final y =
          rect.center.dy + math.sin(angle) * (rect.height / 2 + jitter.dy);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path..close();
  }

  Path _roughPolygon(List<Offset> points, math.Random random) {
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final point = points[i] + _jitterOffset(random);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Path _jitterPath(Path source, math.Random random) {
    final bounds = source.getBounds();
    final points = <Offset>[
      bounds.topLeft,
      bounds.topCenter,
      bounds.topRight,
      bounds.centerRight,
      bounds.bottomRight,
      bounds.bottomCenter,
      bounds.bottomLeft,
      bounds.centerLeft,
    ];
    return _roughPolygon(points, random);
  }

  Offset _jitterOffset(math.Random random) {
    final amount = theme.roughness;
    return Offset(
      (random.nextDouble() * 2 - 1) * amount,
      (random.nextDouble() * 2 - 1) * amount,
    );
  }

  void _drawHachure(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = hachureColor ?? theme.hachure
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var x = rect.left - rect.height; x < rect.right; x += 9) {
      canvas.drawLine(
        Offset(x, rect.bottom),
        Offset(x + rect.height, rect.top),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SketchBorderPainter oldDelegate) =>
      oldDelegate.theme != theme ||
      oldDelegate.strokeColor != strokeColor ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.hachureColor != hachureColor ||
      oldDelegate.shape != shape ||
      oldDelegate.radius != radius ||
      oldDelegate.seed != seed ||
      oldDelegate.hachure != hachure;
}

class SketchSliderPainter extends CustomPainter {
  static const double horizontalInset = 14;

  final SketchThemeData theme;
  final double value;

  const SketchSliderPainter({required this.theme, required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final trackStart = horizontalInset;
    final trackEnd = math.max(trackStart, size.width - horizontalInset);
    final activeX = trackStart + (trackEnd - trackStart) * value.clamp(0, 1);
    final random = math.Random(732);
    final inactivePaint = Paint()
      ..color = theme.mutedInk.withValues(alpha: 0.45)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final activePaint = Paint()
      ..color = theme.ink
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (var pass = 0; pass < 2; pass++) {
      canvas.drawPath(
        _roughTrackPath(trackStart, trackEnd, y, random),
        inactivePaint,
      );
      canvas.drawPath(
        _roughTrackPath(trackStart, activeX, y, random),
        activePaint,
      );
    }

    final thumbCenter = Offset(activeX, y);
    canvas.drawPath(
      _roughOvalPath(thumbCenter, 10, random),
      Paint()
        ..color = theme.paper
        ..style = PaintingStyle.fill,
    );

    final hachurePaint = Paint()
      ..color = theme.accent.withValues(alpha: 0.28)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    for (var x = thumbCenter.dx - 8; x < thumbCenter.dx + 8; x += 5) {
      canvas.drawLine(
        Offset(x, thumbCenter.dy + 7),
        Offset(x + 8, thumbCenter.dy - 7),
        hachurePaint,
      );
    }

    final thumbStroke = Paint()
      ..color = theme.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(_roughOvalPath(thumbCenter, 10, random), thumbStroke);
    canvas.drawPath(_roughOvalPath(thumbCenter, 8.4, random), thumbStroke);
  }

  Path _roughTrackPath(
    double startX,
    double endX,
    double y,
    math.Random random,
  ) {
    final path = Path();
    const segments = 8;
    final span = endX - startX;
    for (var i = 0; i <= segments; i++) {
      final x = startX + (span * i / segments);
      final point = Offset(x, y + _jitter(random, 1.15));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path;
  }

  Path _roughOvalPath(Offset center, double radius, math.Random random) {
    final path = Path();
    const points = 18;
    for (var i = 0; i <= points; i++) {
      final angle = math.pi * 2 * i / points;
      final r = radius + _jitter(random, 1.25);
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  double _jitter(math.Random random, double amount) {
    return (random.nextDouble() * 2 - 1) * amount * theme.roughness;
  }

  @override
  bool shouldRepaint(SketchSliderPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.value != value;
}
