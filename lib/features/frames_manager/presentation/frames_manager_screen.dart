import 'package:flutter/material.dart';
import 'package:framatic/features/frames_manager/presentation/frame_provider.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/frame_list_item.dart';
import 'package:framatic/features/frames_manager/presentation/widgets/manage_frame_dialog.dart';
import 'package:provider/provider.dart';

class FramesManagerScreen extends StatelessWidget {
  const FramesManagerScreen({super.key});

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

          return ReorderableListView.builder(
            itemCount: allFrames.length,
            onReorder: (oldIndex, newIndex) async =>
                await frameProvider.orderFrames(oldIndex, newIndex),
            itemBuilder: (context, index) {
              final frame = allFrames[index];
              return FrameListItem(
                key: ValueKey(frame.id),
                frame: frame,
                order: index,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const ManageFrameDialog(),
        ),
        tooltip: 'Add Custom Frame',
        child: const Icon(Icons.add),
      ),
    );
  }
}
