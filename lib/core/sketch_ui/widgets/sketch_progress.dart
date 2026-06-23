import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';

class SketchProgress extends StatefulWidget {
  final double size;
  final Color? color;

  const SketchProgress({super.key, this.size = 28, this.color});

  @override
  State<SketchProgress> createState() => _SketchProgressState();
}

class _SketchProgressState extends State<SketchProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * math.pi * 2,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _SketchProgressPainter(widget.color ?? theme.ink),
          ),
        );
      },
    );
  }
}

class _SketchProgressPainter extends CustomPainter {
  final Color color;

  const _SketchProgressPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Offset.zero & size,
      -math.pi / 2,
      math.pi * 1.45,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.12),
      Offset(size.width * 0.86, size.height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(_SketchProgressPainter oldDelegate) =>
      oldDelegate.color != color;
}
