import 'package:flutter/widgets.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/delete_frame_dialog.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_preview.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';

class FrameListItem extends StatelessWidget {
  final Frame frame;
  final int order;
  final Future<void> Function(Frame frame) onEdit;
  final Future<void> Function(int frameId) onDelete;

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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: 'Reorder ${frame.title}',
            hint: 'Drag to change camera quick-access order',
            child: ReorderableDragStartListener(
              index: order,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Center(
                  child: SketchIcon(
                    type: SketchIconType.drag,
                    color: theme.mutedInk,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            height: 44,
            child: Center(child: FramePreview(aspectRatio: frame.aspectRatio)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  frame.title,
                  style: theme.bodyText.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(frame.formattedRatio, style: theme.label),
              ],
            ),
          ),
          if (frame.isCustom)
            _FrameRowActions(
              frameId: frame.id,
              onEdit: () => showSketchDialog(
                context: context,
                builder: (_) => ManageFrameDialog(frame: frame, onSave: onEdit),
              ),
              onDelete: () => showSketchDialog(
                context: context,
                builder: (_) =>
                    DeleteFrameDialog(frame: frame, onDelete: onDelete),
              ),
            )
          else
            SketchSurface(
              shape: SketchShape.pill,
              fillColor: theme.panelStrong,
              strokeColor: theme.mutedInk,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              seed: frame.title.hashCode,
              child: Text('Built-in', style: theme.label),
            ),
        ],
      ),
    );
  }
}

class _FrameRowActions extends StatelessWidget {
  final int? frameId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FrameRowActions({
    required this.frameId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    const iconSize = 26.0;
    const hitSize = 48.0;

    return SizedBox(
      width: 104,
      height: hitSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _FrameRowActionIcon(
            key: ValueKey('edit_custom_frame_${frameId ?? 'new'}'),
            icon: SketchIconType.edit,
            label: 'Edit Frame',
            color: theme.ink,
            iconSize: iconSize,
            onPressed: onEdit,
          ),
          _FrameRowActionIcon(
            key: ValueKey('delete_custom_frame_${frameId ?? 'new'}'),
            icon: SketchIconType.delete,
            label: 'Delete Frame',
            color: theme.danger,
            iconSize: iconSize,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _FrameRowActionIcon extends StatelessWidget {
  final SketchIconType icon;
  final String label;
  final Color color;
  final double iconSize;
  final VoidCallback onPressed;

  const _FrameRowActionIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 48,
          child: Align(
            alignment: Alignment.topRight,
            child: SketchIcon(type: icon, size: iconSize, color: color),
          ),
        ),
      ),
    );
  }
}
