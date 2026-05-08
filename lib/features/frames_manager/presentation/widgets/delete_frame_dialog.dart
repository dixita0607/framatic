import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/widgets/filled_sketchy_button.dart';
import 'package:framatic/core/widgets/sketchy_underline.dart';
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
    final secondary = SketchyTheme.of(context).secondaryColor;
    final ink = SketchyTheme.of(context).inkColor;
    return SketchyDialog(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delete Frame',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            SketchyUnderline(color: ink),
            const SizedBox(height: 16),
            Text('Are you sure you want to delete "${frame.title}"?'),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledSketchyButton(
                  fillColor: secondary,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledSketchyButton(
                  fillColor: const Color(0xFFc0392b),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    try {
                      await onDelete(frame.id!);
                      if (context.mounted) {
                        SketchySnackBar.show(context, message: 'Frame deleted');
                      }
                    } on AppError catch (e) {
                      if (context.mounted) context.showErrorSnackBar(e);
                    }
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
      ),
    );
  }
}
