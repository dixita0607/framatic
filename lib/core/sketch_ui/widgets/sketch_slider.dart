import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_painters.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';

class SketchSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String? semanticLabel;

  const SketchSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Semantics(
      slider: true,
      label: semanticLabel,
      value: '${(value * 100).round()}%',
      increasedValue: '${((value + 0.1).clamp(0.0, 1.0) * 100).round()}%',
      decreasedValue: '${((value - 0.1).clamp(0.0, 1.0) * 100).round()}%',
      onIncrease: () => onChanged((value + 0.1).clamp(0.0, 1.0)),
      onDecrease: () => onChanged((value - 0.1).clamp(0.0, 1.0)),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _update(details.localPosition.dx, context),
        onHorizontalDragUpdate: (details) =>
            _update(details.localPosition.dx, context),
        child: SizedBox(
          height: 36,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, 36),
                painter: SketchSliderPainter(theme: theme, value: value),
              );
            },
          ),
        ),
      ),
    );
  }

  void _update(double dx, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 1;
    const inset = SketchSliderPainter.horizontalInset;
    final usableWidth = (width - inset * 2).clamp(1.0, double.infinity);
    onChanged(((dx - inset) / usableWidth).clamp(0.0, 1.0));
  }
}
