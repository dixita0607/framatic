import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

class DeleteFrameDialog extends StatelessWidget {
  final Frame frame;
  final Function(int frameId) onDelete;

  const DeleteFrameDialog({
    super.key,
    required this.frame,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return SketchDialog(
      title: 'Delete Frame',
      actions: [
        SketchButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        SketchButton(
          label: 'Delete',
          danger: true,
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              await onDelete(frame.id!);
              if (context.mounted) {
                SketchToast.show(context, 'Frame deleted');
              }
            } on AppError catch (e) {
              if (context.mounted) {
                context.showErrorToast(e);
              }
            }
          },
        ),
      ],
      child: Text(
        'Are you sure you want to delete "${frame.title}"?',
        style: theme.bodyStyle,
      ),
    );
  }
}
