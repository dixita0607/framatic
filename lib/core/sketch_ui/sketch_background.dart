import 'package:flutter/widgets.dart';

import 'sketch_theme.dart';

class SketchPageBackground extends StatelessWidget {
  final Widget child;

  const SketchPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final background = SketchTheme.backgroundOf(context);
    return CustomPaint(
      painter: _SketchPageBackgroundPainter(
        theme: theme,
        background: background,
      ),
      child: child,
    );
  }
}

class _SketchPageBackgroundPainter extends CustomPainter {
  final SketchThemeData theme;
  final SketchBackgroundData background;

  const _SketchPageBackgroundPainter({
    required this.theme,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = theme.background
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, fill);

    final dotPaint = Paint()
      ..color = theme.mutedInk.withValues(alpha: background.opacity)
      ..style = PaintingStyle.fill;
    final ySpacing = background.secondarySpacing == 0
        ? background.spacing * 0.86
        : background.secondarySpacing;
    var row = 0;
    for (var y = ySpacing; y < size.height; y += ySpacing) {
      final offset = row.isEven ? 0.0 : background.spacing / 2;
      for (
        var x = background.spacing + offset;
        x < size.width;
        x += background.spacing
      ) {
        canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
      }
      row += 1;
    }
  }

  @override
  bool shouldRepaint(_SketchPageBackgroundPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.background != background;
}
