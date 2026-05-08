import 'package:flutter/widgets.dart';
import 'package:framatic/core/utils/color_utils.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

/// A sketch-style button with a solid colored fill.
/// Use for primary actions (primary color) or destructive actions (red).
class FilledSketchyButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color fillColor;

  const FilledSketchyButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SketchyFrame(
        fill: SketchyFill.solid,
        fillColor: fillColor,
        strokeColor: fillColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: onColor(fillColor)),
            child: child,
          ),
        ),
      ),
    );
  }
}
