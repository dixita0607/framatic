import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

class FramePreview extends StatelessWidget {
  final double aspectRatio;
  final double maxWidth;
  final double maxHeight;

  const FramePreview({
    super.key,
    required this.aspectRatio,
    this.maxWidth = 52,
    this.maxHeight = 44,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final widthConstrainedHeight = maxWidth / aspectRatio;
    final (width, height) = widthConstrainedHeight <= maxHeight
        ? (maxWidth, widthConstrainedHeight)
        : (maxHeight * aspectRatio, maxHeight);

    return SizedBox(
      width: width,
      height: height,
      child: SketchSurface(
        fillColor: theme.paper.withValues(alpha: 0.18),
        strokeColor: theme.mutedInk,
        hachure: true,
        hachureColor: theme.mutedInk.withValues(alpha: 0.24),
        shape: SketchShape.rect,
        seed: 1,
        child: const SizedBox.expand(),
      ),
    );
  }
}
