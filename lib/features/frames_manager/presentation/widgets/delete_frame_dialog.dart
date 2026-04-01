import 'package:flutter/material.dart';
import 'package:framatic/core/models/frame.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:provider/provider.dart';

class DeleteFrameDialog extends StatelessWidget {
  final Frame frame;

  const DeleteFrameDialog({super.key, required this.frame});

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
              await context.read<FrameProvider>().deleteFrame(frame.id!);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Frame deleted')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete frame: ${e.toString()}'),
                  ),
                );
              }
            }
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
