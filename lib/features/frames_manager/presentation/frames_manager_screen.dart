import 'package:flutter/material.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';

class FramesManagerScreen extends StatelessWidget {
  const FramesManagerScreen({super.key});

  void _showAddFrameDialog(BuildContext context, FrameProvider frameProvider) {
    showDialog(
      context: context,
      builder: (context) => ManageFrameDialog(
        onSave: (newFrame) async {
          await frameProvider.createFrame(newFrame);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Frames')),
      body: Consumer<FrameProvider>(
        builder: (context, frameProvider, child) {
          if (frameProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allFrames = frameProvider.frames;

          return Scaffold(
            body: ReorderableListView.builder(
              itemCount: allFrames.length,
              onReorder: (oldIndex, newIndex) async =>
                  await frameProvider.orderFrames(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final frame = allFrames[index];
                return FrameListItem(
                  key: ValueKey(frame.id),
                  frame: frame,
                  order: index,
                  onEdit: (updatedFrame) async {
                    await frameProvider.updateFrame(updatedFrame);
                  },
                  onDelete: (frameId) async {
                    await frameProvider.deleteFrame(frameId);
                  },
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddFrameDialog(context, frameProvider),
              tooltip: 'Add Custom Frame',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
