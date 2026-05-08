import 'package:flutter/widgets.dart';

class SketchyUnderline extends StatelessWidget {
  final Color color;

  const SketchyUnderline({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: CustomPaint(painter: _UnderlinePainter(color)),
    );
  }
}

class _UnderlinePainter extends CustomPainter {
  final Color color;
  const _UnderlinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.3, size.height * 0.1,
        size.width * 0.65, size.height * 0.95,
        size.width, size.height * 0.45,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_UnderlinePainter old) => old.color != color;
}
