import 'package:flutter/widgets.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

/// Paints a uniform dot grid on top of whatever is below it, then renders
/// [child] on top. Optionally paints [backgroundColor] first (useful when
/// replacing a ColoredBox).
class DottedBackground extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const DottedBackground({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final ink = SketchyTheme.of(context).inkColor;
    return Stack(
      children: [
        if (backgroundColor != null)
          Positioned.fill(child: ColoredBox(color: backgroundColor!)),
        Positioned.fill(child: CustomPaint(painter: _DotGridPainter(ink))),
        child,
      ],
    );
  }
}

/// Wraps [SketchyScaffold] and places a [DottedBackground] inside the body
/// so dots appear on the paper-coloured scaffold background.
class DottedScaffold extends StatelessWidget {
  final Widget body;
  final SketchyAppBar? appBar;
  final Widget? floatingActionButton;
  final SketchyFabLocation? floatingActionButtonLocation;

  const DottedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SketchyScaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: DottedBackground(child: body),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color ink;
  const _DotGridPainter(this.ink);

  static const double _spacing = 22.0;
  static const double _radius = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ink.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    for (double y = _spacing; y < size.height; y += _spacing) {
      for (double x = _spacing; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), _radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.ink != ink;
}
