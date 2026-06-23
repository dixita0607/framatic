import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_painters.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';
import 'package:framatic/core/sketch_ui/widgets/sketch_surface.dart';

class SketchButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool danger;
  final bool filled;
  final bool primary;
  final Size minSize;
  final EdgeInsetsGeometry padding;

  const SketchButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
    this.filled = false,
    this.primary = false,
    this.minSize = const Size(64, 42),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  State<SketchButton> createState() => _SketchButtonState();
}

class _SketchButtonState extends State<SketchButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final enabled = widget.onPressed != null;
    final stroke = !enabled
        ? theme.disabled
        : widget.danger
        ? theme.danger
        : widget.primary
        ? theme.primary
        : theme.ink;
    final fill = widget.filled
        ? widget.danger
              ? theme.danger
              : widget.primary
              ? theme.primary
              : theme.paper
        : theme.panel;
    final textColor = widget.filled
        ? widget.danger
              ? theme.primaryInk
              : widget.primary
              ? theme.primaryInk
              : theme.paperInk
        : stroke;

    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 80),
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.minSize.width,
                minHeight: widget.minSize.height,
              ),
              child: SketchSurface(
                fillColor: fill,
                strokeColor: stroke,
                shape: SketchShape.roundedRect,
                radius: 4,
                seed: widget.label.hashCode,
                padding: widget.padding,
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    widget.label,
                    style: theme.bodyText.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
