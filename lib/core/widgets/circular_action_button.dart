import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

/// Circular action button with icon and label
/// Displays an icon in a circular container with a label below it
class CircularActionButton extends StatelessWidget {
  final SketchIconType icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool filled;
  final bool primary;

  const CircularActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.filled = false,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final enabled = onPressed != null && !isLoading;
    return Semantics(
      button: true,
      label: label,
      enabled: enabled,
      value: isLoading ? 'Loading' : null,
      child: Column(
        mainAxisSize: .min,
        children: [
          SizedBox.square(
            dimension: 66,
            child: SketchSurface(
              shape: SketchShape.circle,
              fillColor: primary
                  ? theme.primary
                  : filled
                  ? theme.paper
                  : theme.panel,
              strokeColor: primary ? theme.primary : theme.ink,
              seed: label.hashCode,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? onPressed : null,
                child: Center(
                  child: isLoading
                      ? const SketchProgress(size: 24)
                      : SketchIcon(
                          type: icon,
                          color: primary
                              ? theme.primaryInk
                              : filled
                              ? theme.paperInk
                              : theme.ink,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.labelStyle.copyWith(color: theme.ink)),
        ],
      ),
    );
  }
}
