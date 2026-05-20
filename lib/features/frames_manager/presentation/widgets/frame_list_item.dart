import 'package:flutter/widgets.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/delete_frame_dialog.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';

class FrameListItem extends StatelessWidget {
  final Frame frame;
  final int order;
  final Function(Frame) onEdit;
  final Function(int frameId) onDelete;

  const FrameListItem({
    super.key,
    required this.frame,
    required this.order,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Padding(
      key: ValueKey(frame.id),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: order,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: SketchIcon(
                type: SketchIconType.drag,
                color: theme.mutedInk,
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            height: 44,
            child: Center(
              child: _FrameRatioPreview(
                aspectRatio: frame.aspectRatio,
                seed: (frame.id ?? order) + 10,
                theme: theme,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frame.title,
                  style: theme.bodyStyle.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(frame.formattedRatio, style: theme.labelStyle),
              ],
            ),
          ),
          if (frame.isCustom)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SketchIconButton(
                  icon: SketchIconType.edit,
                  onPressed: () => showSketchDialog(
                    context: context,
                    builder: (_) =>
                        ManageFrameDialog(frame: frame, onSave: onEdit),
                  ),
                  tooltip: 'Edit Frame',
                  size: 34,
                  borderless: true,
                ),
                const SizedBox(width: 2),
                SketchIconButton(
                  icon: SketchIconType.delete,
                  danger: true,
                  onPressed: () => showSketchDialog(
                    context: context,
                    builder: (_) =>
                        DeleteFrameDialog(frame: frame, onDelete: onDelete),
                  ),
                  tooltip: 'Delete Frame',
                  size: 34,
                  borderless: true,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FrameRatioPreview extends StatelessWidget {
  final double aspectRatio;
  final int seed;
  final SketchThemeData theme;

  const _FrameRatioPreview({
    required this.aspectRatio,
    required this.seed,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    const maxWidth = 52.0;
    const maxHeight = 44.0;
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
        seed: seed,
        child: const SizedBox.expand(),
      ),
    );
  }
}
