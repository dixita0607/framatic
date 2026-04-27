import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/delete_frame_dialog.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class DraggableFrameListItem extends StatelessWidget {
  final Frame frame;
  final int order;
  final Function(Frame) onEdit;
  final Function(int frameId) onDelete;

  const DraggableFrameListItem({
    super.key,
    required this.frame,
    required this.order,
    required this.onEdit,
    required this.onDelete,
  });

  void handleDragEnd(DraggableDetails details) {
    if (details.wasAccepted) print(details.offset);
  }

  void handleDrop(details) => print('Dragging item index: ${details.data}');

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onAcceptWithDetails: handleDrop,
      builder:
          (
            BuildContext context,
            List<Object?> candidateData,
            List<dynamic> rejectedData,
          ) {
            return Draggable(
              data: order,
              onDragEnd: handleDragEnd,
              feedback: SketchyFrame(
                fillColor: SketchyColors.blue,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Row(
                    children: [
                      const SketchySymbol(symbol: .menu),
                      const SizedBox(width: 8),
                      FramePreview(frame: frame),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          SketchyText(frame.title),
                          SketchyText(
                            frame.formattedRatio,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.5,
                child: FrameListItem(
                  frame: frame,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
              ),
              child: FrameListItem(
                frame: frame,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            );
          },
    );
  }
}

class FrameListItem extends StatelessWidget {
  const FrameListItem({
    super.key,
    required this.frame,
    required this.onEdit,
    required this.onDelete,
  });

  final Frame frame;
  final Function(Frame) onEdit;
  final Function(int frameId) onDelete;

  @override
  Widget build(BuildContext context) {
    return SketchyListTile(
      leading: Row(
        mainAxisSize: .min,
        children: [
          const SketchySymbol(symbol: .menu),
          const SizedBox(width: 8),
          FramePreview(frame: frame),
        ],
      ),
      title: SketchyText(frame.title),
      subtitle: SketchyText(frame.formattedRatio),
      trailing: frame.isCustom
          ? Row(
              children: [
                SketchyButton(
                  child: SketchySymbol(symbol: .gear),
                  onPressed: () => unawaited(
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (_, _, _) => SketchyDialog(
                        child: ManageFrameDialog(frame: frame, onSave: onEdit),
                      ),
                    ),
                  ),
                ),
                SketchyButton(
                  child: const SketchySymbol(symbol: .x),
                  onPressed: () => unawaited(
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (_, _, _) => SketchyDialog(
                        child: DeleteFrameDialog(
                          frame: frame,
                          onDelete: onDelete,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}

class FramePreview extends StatelessWidget {
  const FramePreview({super.key, required this.frame});

  final Frame frame;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FittedBox(
        fit: .contain,
        child: ColoredBox(
          color: SketchyTheme.of(context).secondaryColor,
          child: SizedBox(width: frame.aspectRatio * 100, height: 100),
        ),
      ),
    );
  }
}
