import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/core/widgets/filled_sketchy_button.dart';
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
    final typography = SketchyTheme.of(context).typography;
    return SketchyDialog(
      child: DefaultTextStyle(
        style: typography.body.copyWith(color: const Color(0xFF1A1A1A)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Frame',
              style: typography.body.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 12),
            Text('Are you sure you want to delete "${frame.title}"?', style: typography.body.copyWith(color: const Color(0xFF1A1A1A))),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SketchyButton(
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
      ),
    ),
  );
  }
}
