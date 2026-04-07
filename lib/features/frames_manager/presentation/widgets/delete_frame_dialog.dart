import 'package:flutter/material.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/models/frame.dart';

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
    return AlertDialog(
      title: const Text('Delete Frame'),
      content: Text('Are you sure you want to delete "${frame.title}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            try {
              await onDelete(frame.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Frame deleted')));
              }
            } on AppError catch (e) {
              if (context.mounted) {
                context.showErrorSnackBar(e);
              }
            }
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
