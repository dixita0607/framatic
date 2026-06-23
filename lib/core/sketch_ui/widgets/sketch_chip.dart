import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_painters.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';
import 'package:framatic/core/sketch_ui/widgets/sketch_surface.dart';

class SketchChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final String? semanticLabel;

  const SketchChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel ?? label,
      child: GestureDetector(
        onTap: onSelected,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: SketchSurface(
            shape: SketchShape.roundedRect,
            radius: 5,
            fillColor: theme.panel,
            strokeColor: selected ? theme.accent : theme.mutedInk,
            hachure: selected,
            hachureColor: theme.accent.withValues(alpha: 0.26),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            seed: label.hashCode,
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                style: theme.label.copyWith(
                  color: theme.ink,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
