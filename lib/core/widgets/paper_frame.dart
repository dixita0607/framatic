import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class PaperFrame extends StatelessWidget {
  static const paperColor = Color(0xFFFFFDF7);
  static const pencilColor = Color(0xFF575149);

  final double imageWidth;
  final double imageHeight;
  final double borderWidth;
  final double bottomBorderWidth;
  final String ratioLabel;
  final Widget child;

  const PaperFrame({
    super.key,
    required this.imageWidth,
    required this.imageHeight,
    required this.borderWidth,
    required this.bottomBorderWidth,
    required this.ratioLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final totalWidth = imageWidth + (borderWidth * 2);
    final totalHeight = imageHeight + borderWidth + bottomBorderWidth;

    return Semantics(
      image: true,
      label: 'Paper cutout frame, $ratioLabel',
      child: RepaintBoundary(
        child: SizedBox(
          width: totalWidth,
          height: totalHeight,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  key: const ValueKey('paper-frame-background'),
                  painter: _PaperBackgroundPainter(borderWidth: borderWidth),
                ),
              ),
              Positioned(
                left: borderWidth,
                top: borderWidth,
                width: imageWidth,
                height: imageHeight,
                child: child,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    key: const ValueKey('paper-frame-finish'),
                    painter: _PaperFinishPainter(
                      imageWidth: imageWidth,
                      imageHeight: imageHeight,
                      borderWidth: borderWidth,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: borderWidth + imageHeight,
                height: bottomBorderWidth,
                child: ExcludeSemantics(
                  child: Center(
                    child: Text(
                      ratioLabel,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        color: const Color(0xFF000000),
                        fontSize: math.min(
                          14,
                          math.max(2, bottomBorderWidth * 0.42),
                        ),
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaperBackgroundPainter extends CustomPainter {
  final double borderWidth;

  const _PaperBackgroundPainter({required this.borderWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..color = PaperFrame.paperColor
        ..style = PaintingStyle.fill,
    );

    // The saved JPEG has a straight silhouette with a faint irregular pencil
    // contour just inside it. Keep the live viewfinder identical rather than
    // clipping the paper itself into a torn shape.
    final contourRect = rect.deflate(0.55);
    final outerPath = _softCutRectPath(
      contourRect,
      amplitude: math.min(0.42, math.max(0.18, borderWidth * 0.03)),
      seed: 19,
    );

    canvas.save();
    canvas.clipRect(rect);
    final random = math.Random(3901);
    final grainPaint = Paint()
      ..color = PaperFrame.pencilColor.withValues(alpha: 0.045)
      ..strokeWidth = 0.45
      ..strokeCap = StrokeCap.round;
    final grainCount = (size.width * size.height / 950).round().clamp(18, 85);
    for (var i = 0; i < grainCount; i++) {
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawLine(
        start,
        start.translate(0.8 + random.nextDouble() * 1.8, 0.15),
        grainPaint,
      );
    }
    canvas.restore();

    canvas.drawPath(
      outerPath,
      Paint()
        ..color = PaperFrame.pencilColor.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PaperBackgroundPainter oldDelegate) =>
      oldDelegate.borderWidth != borderWidth;
}

class _PaperFinishPainter extends CustomPainter {
  final double imageWidth;
  final double imageHeight;
  final double borderWidth;

  const _PaperFinishPainter({
    required this.imageWidth,
    required this.imageHeight,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final imageRect = Rect.fromLTWH(
      borderWidth,
      borderWidth,
      imageWidth,
      imageHeight,
    );
    final seamPath = _softCutRectPath(
      imageRect,
      amplitude: math.min(0.55, math.max(0.2, borderWidth * 0.03)),
      seed: 47,
    );

    canvas.save();
    canvas.clipPath(seamPath);
    canvas.drawPath(
      seamPath,
      Paint()
        ..color = const Color(0x30000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.min(3.2, math.max(2.4, borderWidth * 0.14))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.55),
    );
    canvas.restore();
    canvas.drawPath(
      seamPath,
      Paint()
        ..color = PaperFrame.pencilColor.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.65
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_PaperFinishPainter oldDelegate) =>
      oldDelegate.imageWidth != imageWidth ||
      oldDelegate.imageHeight != imageHeight ||
      oldDelegate.borderWidth != borderWidth;
}

Path _softCutRectPath(
  Rect rect, {
  required double amplitude,
  required int seed,
}) {
  final path = Path();
  const segments = 18;

  double wave(int index) {
    return amplitude *
        ((math.sin((index + seed) * 1.73) * 0.62) +
            (math.sin((index + seed) * 0.59) * 0.38));
  }

  path.moveTo(rect.left, rect.top + wave(0));
  var index = 1;
  for (var i = 1; i <= segments; i++, index++) {
    path.lineTo(
      rect.left + (rect.width * i / segments),
      rect.top + wave(index),
    );
  }
  for (var i = 1; i <= segments; i++, index++) {
    path.lineTo(
      rect.right + wave(index),
      rect.top + (rect.height * i / segments),
    );
  }
  for (var i = 1; i <= segments; i++, index++) {
    path.lineTo(
      rect.right - (rect.width * i / segments),
      rect.bottom + wave(index),
    );
  }
  for (var i = 1; i <= segments; i++, index++) {
    path.lineTo(
      rect.left + wave(index),
      rect.bottom - (rect.height * i / segments),
    );
  }
  return path..close();
}
