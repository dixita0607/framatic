import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_icons.dart';
import 'package:framatic/core/sketch_ui/sketch_painters.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';
import 'package:framatic/core/sketch_ui/widgets/sketch_surface.dart';

class SketchIconButton extends StatelessWidget {
  final SketchIconType icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final bool filled;
  final bool danger;
  final bool primary;
  final bool borderless;

  const SketchIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 48,
    this.filled = false,
    this.danger = false,
    this.primary = false,
    this.borderless = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final enabled = onPressed != null;
    final color = danger
        ? theme.danger
        : primary
        ? theme.primary
        : theme.ink;
    final fill = filled
        ? primary
              ? theme.primary
              : theme.paper
        : theme.panel;
    final iconColor = filled
        ? primary
              ? theme.primaryInk
              : theme.paperInk
        : color;
    return Semantics(
      button: true,
      label: tooltip,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: SizedBox.square(
            dimension: size,
            child: borderless
                ? Center(
                    child: SketchIcon(
                      type: icon,
                      size: size * 0.52,
                      color: color,
                    ),
                  )
                : SketchSurface(
                    shape: SketchShape.circle,
                    fillColor: fill,
                    strokeColor: enabled ? color : theme.disabled,
                    seed: icon.index + 40,
                    child: Center(
                      child: SketchIcon(
                        type: icon,
                        size: size * 0.48,
                        color: iconColor,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
