import 'package:flutter/material.dart';
import 'package:framatic/models/frame.dart';
import 'package:framatic/screens/frames_manager/delete_frame_dialog.dart';
import 'package:framatic/screens/frames_manager/manage_frame_dialog.dart';

class FrameListItem extends StatelessWidget {
  final Frame frame;
  final int order;

  const FrameListItem({super.key, required this.frame, required this.order});

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      key: ValueKey(frame.id),
      index: order,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_handle),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: FittedBox(
                fit: BoxFit.contain,
                child: ColoredBox(
                  color: Colors.grey.withValues(alpha: 0.3),
                  child: SizedBox(width: frame.aspectRatio * 100, height: 100),
                ),
              ),
            ),
          ],
        ),
        title: Text(frame.title),
        subtitle: Text(frame.formattedRatio),
        trailing: frame.isCustom
            ? MenuAnchor(
                builder: (context, controller, child) => IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => controller.isOpen
                      ? controller.close()
                      : controller.open(),
                ),
                menuChildren: <Widget>[
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.edit),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => ManageFrameDialog(frame: frame),
                    ),
                    child: const Text('edit'),
                  ),
                  MenuItemButton(
                    leadingIcon: const Icon(Icons.delete),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => DeleteFrameDialog(frame: frame),
                    ),
                    child: const Text('delete'),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
