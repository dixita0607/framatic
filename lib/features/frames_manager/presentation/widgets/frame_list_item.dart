import 'package:flutter/widgets.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/utils/dialog_utils.dart';
import 'package:framatic/core/widgets/app_icons.dart';
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SketchySymbol(symbol: SketchySymbols.menu, color: ink),
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
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frame.title,
                    style: TextStyle(
                      color: ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    frame.formattedRatio,
                    style: TextStyle(color: ink, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (frame.isCustom)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SketchyIconButton(
                    icon: PencilIcon(color: ink),
                    iconSize: 40,
                    onPressed: () => showSketchyDialog(
                      context: context,
                      builder: (_) =>
                          ManageFrameDialog(frame: frame, onSave: onEdit),
                    ),
                  ),
                  SketchyIconButton(
                    icon: SketchySymbol(symbol: SketchySymbols.x, color: ink),
                    iconSize: 40,
                    onPressed: () => showSketchyDialog(
                      context: context,
                      builder: (_) =>
                          DeleteFrameDialog(frame: frame, onDelete: onDelete),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
