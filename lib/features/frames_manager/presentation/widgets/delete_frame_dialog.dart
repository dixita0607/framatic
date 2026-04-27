import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

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
    return SketchyDialog(
      child: Column(
        children: [
          const SketchyText('Delete Frame'),
          SketchyText('Are you sure you want to delete "${frame.title}"?'),
          Row(
            children: [
              SketchyButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const SketchyText('Cancel'),
              ),
              SketchyButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await onDelete(frame.id!);
                    if (context.mounted) {
                      SketchySnackBar.show(context, message: 'Frame deleted');
                    }
                  } on AppError catch (e) {
                    if (context.mounted) {
                      context.showErrorSnackBar(e);
                    }
                  }
                },
                child: const SketchyText('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
