import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/delete_frame_dialog.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

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
    final ink = SketchyTheme.of(context).inkColor;
    final primary = SketchyTheme.of(context).primaryColor;
    return ReorderableDragStartListener(
      key: ValueKey(frame.id),
      index: order,
      child: SketchyListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: ink),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: FittedBox(
                fit: BoxFit.contain,
                child: ColoredBox(
                  color: primary.withValues(alpha: 0.35),
                  child: SizedBox(width: frame.aspectRatio * 100, height: 100),
                ),
              ),
            ),
          ],
        ),
        title: Text(frame.title),
        subtitle: Text(frame.formattedRatio),
        trailing: frame.isCustom
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SketchyIconButton(
                    icon: Icon(Icons.edit, color: ink),
                    iconSize: 40,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) =>
                          ManageFrameDialog(frame: frame, onSave: onEdit),
                    ),
                  ),
                  SketchyIconButton(
                    icon: Icon(Icons.delete, color: ink),
                    iconSize: 40,
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) =>
                          DeleteFrameDialog(frame: frame, onDelete: onDelete),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
