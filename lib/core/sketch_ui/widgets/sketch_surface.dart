import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_painters.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';

class SketchSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? fillColor;
  final Color? strokeColor;
  final Color? hachureColor;
  final SketchShape shape;
  final double radius;
  final int seed;
  final bool hachure;

  const SketchSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.fillColor,
    this.strokeColor,
    this.hachureColor,
    this.shape = SketchShape.roundedRect,
    this.radius = 12,
    this.seed = 1,
    this.hachure = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return CustomPaint(
      painter: SketchBorderPainter(
        theme: theme,
        strokeColor: strokeColor,
        fillColor: fillColor ?? theme.panel,
        hachureColor: hachureColor,
        shape: shape,
        radius: radius,
        seed: seed,
        hachure: hachure,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
